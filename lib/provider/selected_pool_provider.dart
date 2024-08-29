import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'selected_pool_provider.g.dart';

@riverpod
class SelectedPool extends _$SelectedPool {
  @override
  ({Pair? pair, String slippage}) build() => (pair: null, slippage: "0.5");

  Future<void> addPool(Pair pair) async {
    state = (pair: pair, slippage: state.slippage);
    print('SelectedPool: Setting initial state - ${pair.token.symbol}');

    try {
      final tokenBalance = await rpc.fetchTokenBalance(address, pair.token);
      print('SelectedPool: Fetched balance - $tokenBalance');
      final zeniqPrice = await _getZeniqPrice();
      final tokenPrice = _getTokenPrice(zeniqPrice);

      final fiatBalanceZeniq = zeniqBalance.displayDouble * zeniqPrice;
      final fiatBalanceToken = tokenBalance.displayDouble * tokenPrice;
      state = (
        pair: pair.copyWith(
          balanceToken: tokenBalance,
          fiatZeniqBalance: fiatBalanceZeniq,
          fiatBlanceToken: fiatBalanceToken,
        ),
        slippage: state.slippage
      );

      print(
          'SelectedPool: Updated state with balance - ${state.pair!.balanceToken}');
    } catch (e) {
      print('SelectedPool: Error updating pool - $e');
    }
  }

  Future<double> _getZeniqPrice() async {
    final price = await ref
        .read(assetNotifierProvider)
        .fetchSingelPrice(state.pair!.tokeWZeniq);

    return price;
  }

  double _getTokenPrice(double zeniqPrice) {
    final amountWZENIQ = Amount.from(
        value: state.pair!.reserves.$1.toInt(),
        decimals: state.pair!.tokeWZeniq.decimals);
    final amountToken = Amount.from(
        value: state.pair!.reserves.$2.toInt(),
        decimals: state.pair!.token.decimals);
    final priceToken1 =
        zeniqPrice * (amountWZENIQ.displayDouble / amountToken.displayDouble);

    return priceToken1;
  }

  void updateSlippage(String value) {
    state = (pair: state.pair, slippage: value);
  }
}
