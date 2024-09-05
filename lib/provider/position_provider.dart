import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'position_provider.g.dart';

@riverpod
class PositionNotifier extends _$PositionNotifier {
  @override
  Future<List<Position>> build() async {
    return [];
  }

  void addPositions(List<Pair> pairs) async {
    final positions = <Position>[];

    for (final pair in pairs) {
      try {
        final liquidity = await pair.contract.balanceOf(address);

        final liquidityAmount = Amount(
          value: liquidity,
          decimals: 18,
        );

        final position = Position(
          pair: pair,
          liquidity: liquidityAmount,
          zeniqValue: 0,
          tokenValue: 0,
        );
        print('Position: ${pair.token.symbol} $position');
        positions.add(position);
      } catch (e, s) {
        print('Error fetching pair at index $pair: $e');
        state = AsyncValue.error(e, s);
      }
    }
    if (positions.isEmpty) {
      state = AsyncValue.error('No positions found', StackTrace.current);
      return;
    }
    state = AsyncValue.data(positions);
  }

  Position? getPosition(Pair pair) {
    final positions = state.value;
    if (positions == null) return null;
    return positions.firstWhereOrNull((element) => element.pair == pair);
  }
}

class Position {
  final Amount liquidity;
  final Pair pair;
  final double zeniqValue;
  final double tokenValue;

  Position({
    required this.pair,
    required this.liquidity,
    required this.zeniqValue,
    required this.tokenValue,
  });

  @override
  String toString() {
    return 'Position(liquidity: ${liquidity.displayDouble}, zeniqValue: $zeniqValue, tokenValue: $tokenValue)';
  }
}
