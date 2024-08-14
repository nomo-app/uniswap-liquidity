import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
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
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 74,
                height: 42,
                child: Stack(
                  children: [
                    imageToken0.when(
                      data: (data) => Positioned(
                        left: 0,
                        child: ClipOval(
                          child: Image.network(
                            data.small,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => Text(
                        error.toString(),
                      ),
                      loading: () => CircularProgressIndicator(),
                    ),
                    imageToken1.when(
                      data: (data) => Positioned(
                        left: 30,
                        child: ClipOval(
                          child: Image.network(
                            data.small,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => Text(
                        error.toString(),
                      ),
                      loading: () => CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NomoText(
                        pair.token0.symbol,
                        style: context.typography.b1,
                      ),
                      NomoText(
                        " / ",
                        style: context.typography.b1,
                        opacity: 0.7,
                      ),
                      NomoText(
                        pair.token1.symbol,
                        style: context.typography.b1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.theme.colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: NomoText(
                            "V2",
                            style: context.typography.b1,
                          ),
                        ),
                      ),
                      6.hSpacing,
                      Container(
                        width: 46,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.theme.colors.background3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: NomoText(
                            "0.3%",
                            style: context.typography.b1,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              if (pair.tvl != null) const Spacer(),
              if (pair.tvl != null)
                NomoText(
                  "TVL: \$${pair.tvl!.toString()}",
                  style: context.typography.b1,
                ),
              NomoText(
                  "Reserve ${pair.reserves.$1.toString()} ${pair.token1.symbol}"),
              NomoText("Reserve ${pair.reserves.$2.toString()} WZENIQ"),
            ],
          ),
        );
      },
    );
  }
}
