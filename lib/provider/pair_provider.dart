import 'dart:async';
import 'package:collection/collection.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/utils/logger.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part "pair_provider.g.dart";

@riverpod
class PairNotifier extends _$PairNotifier {
  @override
  Future<List<Pair>> build() async {
    return _getPairs();
  }

  Future<List<String>> _allPairs() async {
    try {
      final allPairsLength = await factory.allPairsLength();
      List<String> pairs = [];

      for (int i = 0; i < allPairsLength.toInt(); i++) {
        try {
          final pair = await factory.allPairs(BigInt.from(i));
          pairs.add(pair);
        } catch (e) {
          print('Error fetching pair at index $i: $e');
        }
      }

      return pairs;
    } catch (e) {
      print('Error fetching all pairs: $e');
      return [];
    }
  }

  Future<List<UniswapV2Pair>> _pairContracts() async {
    final pairs = await _allPairs();
    final contracts = pairs.map((pair) {
      return UniswapV2Pair(
        rpc: rpc,
        contractAddress: pair,
      );
    }).toList();

    return contracts;
  }

  Future<Pair> _getPairData(UniswapV2Pair pair) async {
    final tokenZeroAddress = await pair.token0();
    final tokenOneAddress = await pair.token1();
    final reserves = await pair.getReserves();

    //TODO: Fetch token data from WEbonkit
    final assets = <EthBasedTokenEntity>[];

    EthBasedTokenEntity? token0 = assets.singleWhereOrNull(
      (asset) => asset.contractAddress == tokenZeroAddress,
    );
    EthBasedTokenEntity? token1 = assets.singleWhereOrNull(
      (asset) => asset.contractAddress == tokenOneAddress,
    );

    token0 ??= await getTokenInfo(contractAddress: tokenZeroAddress, rpc: rpc)
        .then((token) {
      if (token == null) {
        return null;
      }
      return EthBasedTokenEntity(
        name: token.name,
        symbol: token.symbol,
        decimals: token.decimals,
        contractAddress: token.contractAddress,
        chainID: rpc.type.chainId,
      );
    });

    token1 ??= await getTokenInfo(contractAddress: tokenOneAddress, rpc: rpc)
        .then((token) {
      if (token == null) {
        return null;
      }
      return EthBasedTokenEntity(
        name: token.name,
        symbol: token.symbol,
        decimals: token.decimals,
        contractAddress: token.contractAddress,
        chainID: rpc.type.chainId,
      );
    });

    if (token0 == null || token1 == null) {
      throw Exception('Error fetching token data');
    }

    ref.read(assetNotifierProvider).addToken(token0);
    ref.read(assetNotifierProvider).addToken(token1);

    EthBasedTokenEntity wToken;
    EthBasedTokenEntity token;
    BigInt reserveWZENIQ;
    BigInt reserveToken;

    if (token0.symbol == "WZENIQ") {
      wToken = token0;
      token = token1;
      reserveToken = reserves.$2;
      reserveWZENIQ = reserves.$1;
    } else {
      wToken = token1;
      token = token0;
      reserveToken = reserves.$1;
      reserveWZENIQ = reserves.$2;
    }

    double? tvl;
    try {
      tvl = await _calculateTVL(
          wtoken: wToken,
          token1: token,
          reserveWZENIQ: reserveWZENIQ,
          reserveToken: reserveToken);
    } catch (e) {
      Logger.logError(e, hint: 'Error calculating TVL');
    }
    return Pair(
      token0: token0,
      token1: token1,
      contract: pair,
      reserves: reserves,
      tvl: tvl,
    );
  }

  Future<List<Pair>> _getPairs() async {
    final contracts = await _pairContracts();

    List<Pair> pairsData = [];

    try {
      pairsData = await Future.wait(contracts.map((pair) {
        return _getPairData(pair);
      }));
    } catch (e) {
      print('Error fetching pair data: $e');
      return [];
    }
    return pairsData;
  }

//Todo: Implement this function the right way. Need to get the ratio of the reserves
  Future<double?> _calculateTVL({
    required EthBasedTokenEntity wtoken,
    required EthBasedTokenEntity token1,
    required BigInt reserveWZENIQ,
    required BigInt reserveToken,
  }) async {
    final zeniqPrice =
        await ref.read(assetNotifierProvider).fetchSingelPrice(wtoken);
    final amountWZENIQ =
        Amount.from(value: reserveWZENIQ.toInt(), decimals: wtoken.decimals);
    final amountToken =
        Amount.from(value: reserveToken.toInt(), decimals: token1.decimals);
    final wzeniqValue = amountWZENIQ.displayDouble * zeniqPrice;
    final tokenValue = amountToken.displayDouble * zeniqPrice;
    final tvl = wzeniqValue + tokenValue;
    return tvl;
  }
}

class Pair {
  EthBasedTokenEntity token0;
  EthBasedTokenEntity token1;
  UniswapV2Pair contract;
  (BigInt, BigInt) reserves;
  double? tvl;

  Pair({
    required this.token0,
    required this.token1,
    required this.contract,
    required this.reserves,
    this.tvl,
  });
}
