import 'dart:async';
import 'dart:convert';
import 'package:uniswap_liquidity/utils/http_client.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

abstract class TokenRepository {
  static const String endpoint = "https://webon.info/api/tokens";

  

  static Future<List<ERC20Entity>> fetchFixedTokens() async {


    final response = await HTTPService.client.get(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException("Timeout", REQUEST_TIMEOUT_LIMIT),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "token_repository: Request returned status code ${response.statusCode}",
      );
    }
    final body = jsonDecode(response.body);

    if (body == null && body is! List<dynamic>) {
      throw Exception(
        "token_repository: Request returned null: $endpoint",
      );
    }

    return [
      for (Map<String, dynamic> jsonMap in body)
        () {
          if (jsonMap
              case {
                "name": String _,
                "symbol": String _,
                "decimals": int _,
                "contractAddress": String _,
                "chainId": String chainId,
                "is_nft": false,
                "type": "ZEN-20",
              }) {
            final chainId_i = int.tryParse(chainId);
            if (chainId_i == null) {
              return null;
            }
            return ERC20Entity.fromJson(
              jsonMap,
              allowDeletion: true,
              chainID: chainId_i,
            );
          }
          return null;
        }.call()
    ].whereType<ERC20Entity>().toList();
  }

  static Future<List<ERC20Entity>> fetchTokensWhereNoLiquidty({
    required List<ERC20Entity> allTokens,
    required double minZeniqInPool,
  }) async {
    final allPairs = await Future.wait([
      for (final token in allTokens)
        factoryZeniqSwap
            .getPair(
              tokenA: wrappedZeniqSmart.contractAddress,
              tokenB: token.contractAddress,
            )
            .then(
              (value) => ZeniqswapV2Pair(
                rpc: factoryZeniqSwap.rpc,
                contractAddress: value,
              ),
            )
    ]);

    Future<(ERC20Entity, BigInt)?> fetchTokenWithNoLiquidityFromPair(
        ZeniqswapV2Pair pair) async {
      if (pair.contractAddress ==
          "0x0000000000000000000000000000000000000000") {
        return null;
      }

      final token0 = await pair.token0();
      final token1 = await pair.token1();
      final reserves = await pair.getReserves();

      final token0IsZeniq = token0.toLowerCase() ==
          wrappedZeniqSmart.contractAddress.toLowerCase();

      final nonZeniqToken = allTokens.singleWhere(
        (token) =>
            token.contractAddress.toLowerCase() ==
            (token0IsZeniq ? token1 : token0).toLowerCase(),
      );

      final wZeniqReserves = token0IsZeniq ? reserves.$1 : reserves.$2;

      final reservesAmount = Amount(
        value: wZeniqReserves,
        decimals: wrappedZeniqSmart.decimals,
      );

      if (!(reservesAmount.displayDouble > minZeniqInPool)) {
        return (nonZeniqToken, wZeniqReserves);
      }

      return null;
    }

    final tokensWithLiquidity = await Future.wait(
      [for (final pair in allPairs) fetchTokenWithNoLiquidityFromPair(pair)],
    ).then(
      (value) => value.whereType<(ERC20Entity, BigInt)>().toList(),
    );

    if (tokensWithLiquidity.isEmpty) {
      return allTokens;
    }

    tokensWithLiquidity.sort((a, b) => b.$2.compareTo(a.$2));

    return tokensWithLiquidity.map((e) => e.$1).toList();
  }
}
