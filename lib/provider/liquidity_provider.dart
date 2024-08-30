import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';

part 'liquidity_provider.g.dart';

@riverpod
class LiquidityNotifier extends _$LiquidityNotifier {
  @override
  Future<String> build(Liquidity liquidity) async {
    return addLiquidity(liquidity);
  }

  Future<String> addLiquidity(Liquidity liquidity) async {
    print(
        "tokenValue: ${liquidity.tokenValue} zeniqValue: ${liquidity.zeniqValue} pair: ${liquidity.pair.token.symbol} ${liquidity.pair.tokeWZeniq.symbol} slippage: ${liquidity.slippage}");

    return "Liquidity added";
  }
}

class Liquidity {
  final Pair pair;
  final String slippage;
  final String zeniqValue;
  final String tokenValue;

  Liquidity(
      {required this.pair,
      required this.slippage,
      required this.zeniqValue,
      required this.tokenValue});
}
