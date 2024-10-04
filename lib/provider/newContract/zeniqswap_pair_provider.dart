import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/model/position.dart';
import 'package:uniswap_liquidity/provider/oldContract/pair_provider.dart';
import 'package:uniswap_liquidity/utils/logger.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'zeniqswap_pair_provider.g.dart';

@Riverpod(keepAlive: true)
class ZeniqswapNotifier extends _$ZeniqswapNotifier {
  @override
  Future<List<Pair>> build() async {
    final oldPairsWithPosition = await ref.watch(pairNotifierProvider.future);
    final newPairs = await _getPairs();

    // Combine old and new pairs, ensuring no duplicates
    final allPairs = [...oldPairsWithPosition, ...newPairs];

    return allPairs;
  }

  Future<void> periodicUpdate() async {
    final updatedPairs = await _getPairs();
    state.whenData((currentPairs) {
      final mergedPairs = _mergePairsPreservingOld(currentPairs, updatedPairs);
      state = AsyncValue.data(mergedPairs);
    });
  }

  Future<void> softUpdate() async {
    state.whenData((List<Pair> currentPairs) {
      state = AsyncValue.data(currentPairs
          .map<Pair>((Pair pair) => pair.copyWith(isUpdating: true))
          .toList());
    });
    final updatedPairs = await _getPairs();
    state.whenData((currentPairs) {
      final mergedPairs = _mergePairsPreservingOld(currentPairs, updatedPairs);
      state = AsyncValue.data(mergedPairs);
    });
  }

  List<Pair> _mergePairsPreservingOld(
      List<Pair> currentPairs, List<Pair> updatedPairs) {
    final mergedPairs = <Pair>[];
    final updatedPairMap = {
      for (var pair in updatedPairs) pair.contract.contractAddress: pair
    };
    final processedContracts = <String>{};

    for (var currentPair in currentPairs) {
      final contractAddress = currentPair.contract.contractAddress;
      if (processedContracts.contains(contractAddress)) continue;

      if (currentPair.position?.oldPosition == true) {
        // Preserve pairs with oldPosition true
        mergedPairs.add(currentPair);
      } else {
        final updatedPair = updatedPairMap[contractAddress];
        if (updatedPair != null) {
          // Update pairs without oldPosition
          mergedPairs.add(updatedPair.copyWith(
            position: currentPair.position ?? updatedPair.position,
          ));
        } else {
          // Keep current pair if not in updated list
          mergedPairs.add(currentPair);
        }
      }
      processedContracts.add(contractAddress);
      updatedPairMap.remove(contractAddress);
    }

    // Add any new pairs from the updated list
    mergedPairs.addAll(updatedPairMap.values);

    return mergedPairs;
  }

  Future<List<String>> _allPairs() async {
    try {
      final allPairsLength = await factoryZeniqSwap.allPairsLength();
      List<String> pairs = [];

      for (int i = 0; i < allPairsLength.toInt(); i++) {
        try {
          final pair = await factoryZeniqSwap.allPairs(BigInt.from(i));
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

  Future<List<ZeniqswapV2Pair>> _pairContracts() async {
    final pairs = await _allPairs();
    final contracts = pairs.map((pair) {
      return ZeniqswapV2Pair(
        rpc: rpc,
        contractAddress: pair,
      );
    }).toList();

    return contracts;
  }

  Future<Pair> _getPairData(ZeniqswapV2Pair pair) async {
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
    final assets = <ERC20Entity>[];

    ERC20Entity? token0 = assets.singleWhereOrNull(
      (asset) => asset.contractAddress == tokenZeroAddress,
    );
    ERC20Entity? token1 = assets.singleWhereOrNull(
      (asset) => asset.contractAddress == tokenOneAddress,
    );

    token0 ??= await getTokenInfo(contractAddress: tokenZeroAddress, rpc: rpc)
        .then((token) {
      if (token == null) {
        return null;
      }
      return ERC20Entity(
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
      return ERC20Entity(
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

    ERC20Entity wToken;
    ERC20Entity token;

    (BigInt, BigInt) orderedReserves;

    if (token0.symbol == "ZENIQ") {
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
        oldPosition: false,
      );
    }

    final fiatBalanceZeniq = zeniqBalance.displayDouble * zeniqPrice;
    final fiatBalanceToken = tokenBalance.displayDouble * tokenPrice;

    return Pair(
      volume24h: null,
      apr: null,
      fees24h: null,
      tokeWZeniq: wToken,
      token: token,
      contract: UniswapV2PairOrZeniqSwapPair.zeniqSwap(pair),
      reserves: orderedReserves,
      tvl: tvlInfo["tvl"],
      zeniqFiatValue: tvlInfo["zeniqFiatValue"],
      tokenFiatValue: tvlInfo["tokenFiatValue"],
      tokenPrice: tokenPrice,
      zeniqPrice: zeniqPrice,
      tokenPerZeniq: tvlInfo["tokenPerZeniq"],
      zeniqPerToken: tvlInfo["zeniqPerToken"],
      balanceToken: tokenBalance,
      fiatBlanceToken: fiatBalanceToken,
      fiatZeniqBalance: fiatBalanceZeniq,
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
      final liquidity = pair.contract.isUniswap
          ? await pair.contract.asUniswap.balanceOf(address)
          : await pair.contract.asZeniqSwap.balanceOf(address);
      final totalSupply = pair.contract.isUniswap
          ? await pair.contract.asUniswap.totalSupply()
          : await pair.contract.asZeniqSwap.totalSupply();

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

      print("Position before update: ${pair.position}");

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
        oldPosition: false,
      );
      final index = pairs.indexWhere(
          (p) => p.contract.contractAddress == pair.contract.contractAddress);
      print("This is the index of updated pair: $index");

      if (index != -1) {
        // Update the pair if found
        pairs[index] = pairs[index].copyWith(position: updatedPosition);

        print("Position after update: ${pairs[index].position}");
        state = AsyncValue.data(pairs);

        print("Pair updated successfully");
      } else {
        // If the pair is not found, add it to the list
        print("Pair not found in the list. Adding it.");
        state = AsyncValue.data(
            [...pairs, pair.copyWith(position: updatedPosition)]);
      }
    } catch (e, s) {
      print(
          'Error updating position for pair ${pair.contract.contractAddress}: $e');
      state = AsyncValue.error(e, s);
    }
  }

  Future<double?> _fetchTokenPrice(ERC20Entity token) async {
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
    required ERC20Entity wtoken,
    required ERC20Entity token1,
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
