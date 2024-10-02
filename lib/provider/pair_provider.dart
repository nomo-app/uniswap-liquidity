import 'dart:async';
import 'package:collection/collection.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/model/position.dart';
import 'package:uniswap_liquidity/utils/logger.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part "pair_provider.g.dart";

@Riverpod(keepAlive: true)
class PairNotifier extends _$PairNotifier {
  @override
  Future<List<Pair>> build() async {
    return _getPairs();
  }

  Future<void> softUpdate() async {
    state.whenData((List<Pair> currentPairs) {
      state = AsyncValue.data(currentPairs
          .map<Pair>((Pair pair) => pair.copyWith(isUpdating: true))
          .toList());
    });

    final updatedPairs = await _getPairs();
    state = AsyncValue.data(updatedPairs);
  }

  Future<List<String>> _allPairs() async {
    try {
      final allPairsLength = await factory.allPairsLength();
      List<String> pairs = [];

      for (int i = 0; i < allPairsLength.toInt(); i++) {
        try {
          final pair = await factory.allPairs(BigInt.from(i));
          // if (allowedContracts.contains(pair)) {
          pairs.add(pair);
          // }
        } catch (e) {
          print('Error fetching pair at index $i: $e');
        }
      }

      return pairs;
    } catch (e, s) {
      print('Error fetching all pairs: $e');
      state = AsyncValue.error(e, s);
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
    BigInt? liquidity = BigInt.zero;
    BigInt? totalSupply = BigInt.zero;
    Amount tokenBalance = Amount.zero;

    try {
      liquidity = await pair.balanceOf(address);
      totalSupply = await pair.totalSupply();
    } catch (e) {
      throw Exception('Error fetching position data');
    }

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

    final totalSupplyAmount = Amount(
      value: totalSupply,
      decimals: 18,
    );

    final reserveAmountZeniq = Amount(
      value: orderedReserves.$1,
      decimals: wToken.decimals,
    );
    final reserveAmountToken = Amount(
      value: orderedReserves.$2,
      decimals: token.decimals,
    );

    final liquidityAmount = Amount(
      value: liquidity,
      decimals: 18,
    );

    Position? position;

    final share = liquidityAmount / totalSupplyAmount;

    final zeniqValue = share * reserveAmountZeniq;

    final zeniqAmount = Amount(
      value: discardRightBigInt(zeniqValue.value, 18),
      decimals: 18,
    );

    final tokenValue = share * reserveAmountToken;
    final tokenAmount = Amount(
      value: discardRightBigInt(tokenValue.value, token.decimals),
      decimals: token.decimals,
    );

    try {
      tokenBalance = await rpc.fetchTokenBalance(address, token);
    } catch (e) {
      print('Error fetching token balance: $e');
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

    final double tokenPrice = tvlInfo["tokenPrice"];
    final double zeniqPrice = tvlInfo["zeniqPrice"];

    if (liquidityAmount > Amount.zero) {
      // print("Zeniq Price is: $zeniqPrice");
      // print("Token Price is: $tokenPrice of ${token.symbol}");
      // print("Zeniq Value is: ${zeniqValue.displayDouble}");
      // print("Token Value is: ${tokenValue.displayDouble} of ${token.symbol}");

      final vl = (zeniqAmount.displayDouble * zeniqPrice) +
          (tokenAmount.displayDouble * tokenPrice);

      position = Position(
        valueLocked: vl,
        liquidity: liquidityAmount,
        zeniqValue: zeniqAmount,
        totalSupply: totalSupplyAmount,
        tokenValue: tokenAmount,
        reserveAmountZeniq: reserveAmountZeniq,
        reserveAmountToken: reserveAmountToken,
        tokenFiatValue: tokenPrice * tokenAmount.displayDouble,
        zeniqFiatValue: zeniqPrice * zeniqAmount.displayDouble,
        share: share,
      );
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
      zeniqFiatValue: tvlInfo["zeniqFiatValue"],
      tokenFiatValue: tvlInfo["tokenFiatValue"],
      tokenPrice: tokenPrice,
      zeniqPrice: zeniqPrice,
      tokenPerZeniq: tvlInfo["tokenPerZeniq"],
      zeniqPerToken: tvlInfo["zeniqPerToken"],
      balanceToken: tokenBalance,
      fiatBlanceToken: null,
      fiatZeniqBalance: null,
      position: position,
      tokenValue: tvlInfo["tokenValue"],
      zeniqValue: tvlInfo["zeniqValue"],
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

  Future<void> updatePosition(Pair pair) async {
    final pairs = state.value;
    if (pairs == null) return;
    try {
      final liquidity = await pair.contract.balanceOf(address);
      final totalSupply = await pair.contract.totalSupply();

      final totalSupplyAmount = Amount(
        value: totalSupply,
        decimals: 18,
      );

      final reserveAmountZeniq = Amount(
        value: pair.reserves.$1,
        decimals: pair.tokeWZeniq.decimals,
      );
      final reserveAmountToken = Amount(
        value: pair.reserves.$2,
        decimals: pair.token.decimals,
      );

      final liquidityAmount = Amount(
        value: liquidity,
        decimals: 18,
      );

      final share = liquidityAmount / totalSupplyAmount;

      final zeniqValue = share * reserveAmountZeniq;
      final zeniqAmount = Amount(
        value: discardRightBigInt(zeniqValue.value, 18),
        decimals: 18,
      );

      final tokenValue = share * reserveAmountToken;
      final tokenAmount = Amount(
        value: discardRightBigInt(tokenValue.value, pair.token.decimals),
        decimals: pair.token.decimals,
      );

      final vl = (zeniqAmount.displayDouble * pair.zeniqPrice) +
          (tokenAmount.displayDouble * pair.tokenPrice);

      final updatedPosition = Position(
        liquidity: liquidityAmount,
        zeniqValue: zeniqAmount,
        totalSupply: totalSupplyAmount,
        tokenValue: tokenAmount,
        reserveAmountZeniq: reserveAmountZeniq,
        reserveAmountToken: reserveAmountToken,
        tokenFiatValue: tokenAmount.displayDouble * pair.tokenPrice,
        zeniqFiatValue: zeniqAmount.displayDouble * pair.zeniqPrice,
        valueLocked: vl,
        share: share,
      );
      final index = pairs.indexOf(pair);
      print("This is the index of updated pair: $index");
      pairs[index] = pair.copyWith(position: updatedPosition);
      state = AsyncValue.data(pairs);
    } catch (e, s) {
      print('Error fetching position at index $pair: $e');
      state = AsyncValue.error(e, s);
    }
  }

  Future<double?> _fetchTokenPrice(EthBasedTokenEntity token) async {
    print('Fetching token price for ${token.symbol}');

    try {
      final tokenPrice =
          await ref.read(assetNotifierProvider).fetchSingelPrice(token, false);
      return tokenPrice;
    } catch (e) {
      print('Error fetching token price: $e');
    }

    return null;
  }

  Future<Map<String, dynamic>> _calculateTVL({
    required EthBasedTokenEntity wtoken,
    required EthBasedTokenEntity token1,
    required BigInt reserveWZENIQ,
    required BigInt reserveToken,
  }) async {
    final zeniqPrice =
        await ref.read(assetNotifierProvider).fetchSingelPrice(wtoken, true);
    double? fetchedTokenPrice = await _fetchTokenPrice(token1);
    print('Fetched token price: $fetchedTokenPrice for ${token1.symbol}');
    final zeniqValue = Amount(value: reserveWZENIQ, decimals: wtoken.decimals);
    final tokenValue = Amount(value: reserveToken, decimals: token1.decimals);

    if (fetchedTokenPrice == null) {
      fetchedTokenPrice =
          zeniqPrice * (zeniqValue.displayDouble / tokenValue.displayDouble);
    }

    final zeniqFiatValue = zeniqValue.displayDouble * zeniqPrice;
    final tokenFiatValue = tokenValue.displayDouble * fetchedTokenPrice;
    final tvl = tokenFiatValue + zeniqFiatValue;

    final tokensPerZeniq = tokenValue.displayDouble / zeniqValue.displayDouble;
    final zeniqPerToken = zeniqValue.displayDouble / tokenValue.displayDouble;

    final tvlInfo = {
      'tvl': tvl,
      'zeniqFiatValue': zeniqFiatValue,
      'tokenFiatValue': tokenFiatValue,
      'tokenPrice': fetchedTokenPrice,
      'zeniqPrice': zeniqPrice,
      'tokenPerZeniq': tokensPerZeniq,
      'zeniqPerToken': zeniqPerToken,
      'zeniqValue': zeniqValue,
      'tokenValue': tokenValue,
    };

    return tvlInfo;
  }
}

const allowedContracts = [
  "0x04358de9c80fa9e3e0185e25a513c08f97610720",
  "0x334fead1c662f1aca47313b284077be123a4e2ab",
  "0x7a25ebe2927028d3f2638f181dade503cc45c318",
  "0xb10740f9a0f07cb3541e6d811632a12a0c98898a",
  "0x47341630801dadda02f28827675ad106b525285f",
  "0xdc88ade4eea3c0638f18b0449695071807dbae7e",
  "0xb7a0f230742a357a9f4657f818322bd7c917d35a",
  "0xff7b9ed4785a3caea71a90039908bf4fb7f7dc49",
  "0x103850b1b08a37466148ae816cf8dfbb812162a3",
  "0x2cdc266698a9821718d504ba4a2652388454ae63",
  "0xeda0df58ea3675da3b8d08a2ae91a0b876f2dfaf",
  "0x9c66828a4d82f4b6e0a636fa6d142b82b5fdd523",
];
