import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';

part 'selected_pool_provider.g.dart';

@riverpod
class SelectedPool extends _$SelectedPool {
  @override
  Future<Pair> build(Pair pair) async {
    return _addPair(pair);
  }

  Future<Pair> _addPair(Pair pair) async {
    try {
      final tokenBalance = pair.balanceToken!;

      final tokenPrice = pair.tokenPrice;

      final fiatBalanceZeniq = zeniqBalance.displayDouble * pair.zeniqPrice;
      final fiatBalanceToken = tokenBalance.displayDouble * tokenPrice;

      final updatedPair = pair.copyWith(
        balanceToken: tokenBalance,
        fiatZeniqBalance: fiatBalanceZeniq,
        fiatBlanceToken: fiatBalanceToken,
      );

      state = AsyncValue.data(pair.copyWith(
        balanceToken: tokenBalance,
        fiatZeniqBalance: fiatBalanceZeniq,
        fiatBlanceToken: fiatBalanceToken,
      ));

      state = AsyncValue.data(updatedPair);
      return updatedPair;
    } catch (e) {
      print('SelectedPool: Error updating pool - $e');
      state = AsyncError(e, StackTrace.current);
    }
    return pair;
  }

  Future<void> updatePair(Pair newPair) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _addPair(newPair));
  }

  // Future<double> _getZeniqPrice(EthBasedTokenEntity tokeWZeniq) async {
  //   final price = await ref
  //       .read(assetNotifierProvider)
  //       .fetchSingelPrice(tokeWZeniq, true);

  //   return price;
  // }

  // double _getTokenPrice(Pair pair, double zeniqPrice) {
  //   final amountWZENIQ = Amount.from(
  //       value: pair.reserves.$1.toInt(), decimals: pair.tokeWZeniq.decimals);
  //   final amountToken = Amount.from(
  //       value: pair.reserves.$2.toInt(), decimals: pair.token.decimals);
  //   final priceToken1 =
  //       zeniqPrice * (amountWZENIQ.displayDouble / amountToken.displayDouble);

  //   return priceToken1;
  // }
}
