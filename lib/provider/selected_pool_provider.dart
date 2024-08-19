import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';

part 'selected_pool_provider.g.dart';

@riverpod
class SelectedPool extends _$SelectedPool {
  @override
  Pair? build() {
    return null;
  }

  void addPool(Pair pair) {
    state = pair;
  }
}
