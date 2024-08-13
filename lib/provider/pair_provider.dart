import 'dart:async';
import 'package:collection/collection.dart';
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

    return Pair(
      token0: token0,
      token1: token1,
      contract: pair,
      reserves: reserves,
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
}

class Pair {
  EthBasedTokenEntity token0;
  EthBasedTokenEntity token1;
  UniswapV2Pair contract;
  (BigInt, BigInt) reserves;

  Pair(
      {required this.token0,
      required this.token1,
      required this.contract,
      required this.reserves});
}
