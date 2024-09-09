import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'position_provider.g.dart';

@Riverpod(keepAlive: true)
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

        final tokenValue = share * reserveAmountToken;

        final position = Position(
          pair: pair,
          liquidity: liquidityAmount,
          zeniqValue: Amount(
              value: discardRightBigInt(zeniqValue.value, 18), decimals: 18),
          totalSupply: totalSupplyAmount,
          share: share,
          tokenValue: Amount(
              value: discardRightBigInt(tokenValue.value, pair.token.decimals),
              decimals: pair.token.decimals),
          reserveAmountZeniq: reserveAmountZeniq,
          reserveAmountToken: reserveAmountToken,
        );
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

  Future<void> updatePosition(Pair pair) async {
    final positions = state.value;
    if (positions == null) return;

    final position = positions.firstWhere((element) =>
        element.pair.token.contractAddress == pair.token.contractAddress);

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

      final tokenValue = share * reserveAmountToken;

      final updatedPosition = Position(
        pair: pair,
        liquidity: liquidityAmount,
        zeniqValue: zeniqValue,
        totalSupply: totalSupplyAmount,
        tokenValue: tokenValue,
        reserveAmountZeniq: reserveAmountZeniq,
        reserveAmountToken: reserveAmountToken,
        share: share,
      );

      final index = positions.indexOf(position);
      positions[index] = updatedPosition;
      state = AsyncValue.data(positions);
    } catch (e, s) {
      print('Error fetching pair at index $pair: $e');
      state = AsyncValue.error(e, s);
    }
  }

  // Position? getPosition(Pair pair) {
  //   final positions = state.value;
  //   if (positions == null) return null;
  //   return positions.firstWhereOrNull((element) => element.pair == pair);
  // }
}

class Position {
  final Amount liquidity;
  final Pair pair;
  final Amount totalSupply;
  final Amount zeniqValue;
  final Amount tokenValue;
  final Amount share;
  final Amount reserveAmountZeniq;
  final Amount reserveAmountToken;

  Position({
    required this.pair,
    required this.liquidity,
    required this.zeniqValue,
    required this.tokenValue,
    required this.totalSupply,
    required this.share,
    required this.reserveAmountZeniq,
    required this.reserveAmountToken,
  });

  @override
  String toString() {
    return 'Position(liquidity: ${liquidity.displayDouble}, zeniqValue: $zeniqValue, tokenValue: $tokenValue)';
  }
}
