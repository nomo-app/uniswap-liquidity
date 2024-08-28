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

    (BigInt, BigInt) orderedReserves;

    if (token0.symbol == "WZENIQ") {
      wToken = token0;
      token = token1;
      orderedReserves = (reserves.$1, reserves.$2);
    } else {
      wToken = token1;
      token = token0;
      orderedReserves = (reserves.$2, reserves.$1);
    }

    Map<String, dynamic> tvlInfo = {};
    try {
      tvlInfo = await _calculateTVL(
        wtoken: wToken,
        token1: token,
        reserveWZENIQ: orderedReserves.$1,
        reserveToken: orderedReserves.$2,
      );
    } catch (e) {
      Logger.logError(e, hint: 'Error calculating data');
    }

    return Pair(
      volume24h: null,
      apr: null,
      fees24h: null,
      tokeWZeniq: wToken,
      token: token,
      contract: pair,
      reserves: orderedReserves,
      tvl: tvlInfo["tvl"],
      zeniqValue: tvlInfo["zeniqValue"],
      tokenValue: tvlInfo["tokenValue"],
      tokenPrice: tvlInfo["tokenPrice"],
      zeniqPrice: tvlInfo["zeniqPrice"],
      balanceToken: null,
      fiatBlanceToken: null,
      fiatZeniqBalance: null,
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

  Future<Map<String, dynamic>> _calculateTVL({
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

    final priceToken1 =
        zeniqPrice * (amountWZENIQ.displayDouble / amountToken.displayDouble);
    final valueWZENIQ = amountWZENIQ.displayDouble * zeniqPrice;
    final valueToken1 = amountToken.displayDouble * priceToken1;
    final tvl = valueToken1 + valueWZENIQ;

    final tvlInfo = {
      'tvl': tvl,
      'zeniqValue': valueWZENIQ,
      'tokenValue': valueToken1,
      'tokenPrice': priceToken1,
      'zeniqPrice': zeniqPrice,
    };

    return tvlInfo;
  }
}

class Pair extends PairInformation {
  EthBasedTokenEntity tokeWZeniq;
  EthBasedTokenEntity token;
  UniswapV2Pair contract;
  (BigInt, BigInt) reserves;

  Pair({
    required this.tokeWZeniq,
    required super.volume24h,
    required super.fees24h,
    required super.apr,
    required this.token,
    required this.contract,
    required this.reserves,
    required super.tvl,
    required super.zeniqValue,
    required super.tokenValue,
    required super.tokenPrice,
    required super.zeniqPrice,
    required super.balanceToken,
    required super.fiatBlanceToken,
    required super.fiatZeniqBalance,
  });

  copyWith({
    EthBasedTokenEntity? tokeWZeniq,
    EthBasedTokenEntity? token,
    UniswapV2Pair? contract,
    (BigInt, BigInt)? reserves,
    double? tvl,
    double? volume24h,
    double? fees24h,
    double? apr,
    double? zeniqValue,
    double? tokenValue,
    double? tokenPrice,
    double? zeniqPrice,
    Amount? balanceToken,
    double? fiatBlanceToken,
    double? fiatZeniqBalance,
  }) {
    return Pair(
      tokeWZeniq: tokeWZeniq ?? this.tokeWZeniq,
      token: token ?? this.token,
      contract: contract ?? this.contract,
      reserves: reserves ?? this.reserves,
      tvl: tvl ?? this.tvl,
      volume24h: volume24h ?? this.volume24h,
      fees24h: fees24h ?? this.fees24h,
      apr: apr ?? this.apr,
      zeniqValue: zeniqValue ?? this.zeniqValue,
      tokenValue: tokenValue ?? this.tokenValue,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      zeniqPrice: zeniqPrice ?? this.zeniqPrice,
      balanceToken: balanceToken ?? this.balanceToken,
      fiatBlanceToken: fiatBlanceToken ?? this.fiatBlanceToken,
      fiatZeniqBalance: fiatZeniqBalance ?? this.fiatZeniqBalance,
    );
  }
}

abstract class PairInformation {
  final double tvl;
  final double? volume24h;
  final double? fees24h;
  final double? apr;
  final double zeniqPrice;
  final double tokenPrice;
  final double tokenValue;
  final double zeniqValue;
  final Amount? balanceToken;
  final double? fiatBlanceToken;
  final double? fiatZeniqBalance;

  PairInformation({
    required this.tvl,
    required this.volume24h,
    required this.fees24h,
    required this.apr,
    required this.zeniqValue,
    required this.tokenValue,
    required this.tokenPrice,
    required this.zeniqPrice,
    required this.balanceToken,
    required this.fiatBlanceToken,
    required this.fiatZeniqBalance,
  });
}
