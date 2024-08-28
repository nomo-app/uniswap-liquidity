import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';

part 'selected_pool_provider.g.dart';

@riverpod
class SelectedPool extends _$SelectedPool {
  @override
  Pair? build() => null;

  Future<void> addPool(Pair pair) async {
    state = pair;
    print('SelectedPool: Setting initial state - ${pair.token.symbol}');

    try {
      final tokenBalance = await rpc.fetchTokenBalance(address, pair.token);
      print('SelectedPool: Fetched balance - $tokenBalance');

      state = pair.copyWith(balanceToken: tokenBalance);
      print(
          'SelectedPool: Updated state with balance - ${state?.balanceToken}');
    } catch (e) {
      print('SelectedPool: Error updating pool - $e');
    }
  }
}
