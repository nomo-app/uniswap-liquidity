import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';

class PoolOverview extends ConsumerWidget {
  final Pair pair;
  const PoolOverview({super.key, required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image0 =
        ref.read(assetNotifierProvider).imageNotifierForToken(pair.token0)!;
    final image1 =
        ref.read(assetNotifierProvider).imageNotifierForToken(pair.token1)!;

    return ListenableBuilder(
      listenable: Listenable.merge([image0, image1]),
      builder: (context, child) {
        final imageToken0 = image0.value;
        final imageToken1 = image1.value;
        return NomoCard(
          child: Row(
            children: [
              imageToken0.when(
                data: (data) =>
                    Image.network(data.small, width: 40, height: 40),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => CircularProgressIndicator(),
              ),
              imageToken1.when(
                data: (data) =>
                    Image.network(data.small, width: 40, height: 40),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }
}
