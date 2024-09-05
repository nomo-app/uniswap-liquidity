import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/provider/position_provider.dart';

class PositionBox extends ConsumerWidget {
  final Position position;
  const PositionBox({required this.position, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final position =
    //     ref.read(positionNotifierProvider.notifier).getPosition(selectedPool);

    return Column(
      children: [
        Text("Position Box"),
        Text("Position: ${position.liquidity.displayValue}"),
        Text("Token: ${position.pair.token.symbol}"),
      ],
    );
  }
}
