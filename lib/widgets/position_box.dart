import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/provider/position_provider.dart';

class PositionBox extends ConsumerWidget {
  final Pair pair;
  const PositionBox({required this.pair, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final position =
    //     ref.read(positionNotifierProvider.notifier).getPosition(selectedPool);
    final position = ref.watch(positionNotifierProvider);

    return position.when(
        data: (data) {
          final position = data.firstWhere((element) => element.pair == pair);

          return Column(
            children: [
              Text("Position Box"),
              Text("Position: ${position.liquidity}"),
              // Text("Token: ${data.pair.token.symbol}"),
            ],
          );
        },
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => CircularProgressIndicator());

    // return Column(
    //   children: [
    //     Text("Position Box"),
    //     Text("Position: ${position.liquidity.displayValue}"),
    //     Text("Token: ${position.pair.token.symbol}"),
    //   ],
    // );
  }
}
