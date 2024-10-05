import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/loading/shimmer/shimmer.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/widgets/pool_view.dart';

class PoolOverview extends ConsumerWidget {
  final Pair pair;
  const PoolOverview({super.key, required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image0 =
        ref.read(assetNotifierProvider).imageNotifierForToken(pair.tokeWZeniq)!;
    final image1 =
        ref.read(assetNotifierProvider).imageNotifierForToken(pair.token)!;

    final currencyNotifier = ref.watch(assetNotifierProvider).currencyNotifier;

    return ListenableBuilder(
      listenable: Listenable.merge([image0, image1, currencyNotifier]),
      builder: (context, child) {
        final imageToken0 = image0.value;
        final imageToken1 = image1.value;
        final currency = currencyNotifier.value;

        return Shimmer(
          child: NomoCard(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            loading: () => CircularProgressIndicator(
                              color: context.theme.colors.primary,
                            ),
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
                            loading: () => CircularProgressIndicator(
                              color: context.theme.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NomoText(
                          pair.token.symbol,
                          style: context.typography.b1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (pair.position?.oldPosition ?? false) ...[
                              Container(
                                width: 38,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.theme.colors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: NomoText(
                                    "Old",
                                    style: context.typography.b1,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              4.hSpacing,
                            ],
                            Container(
                              width: 64,
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
                                  "0.3% Fee",
                                  style: context.typography.b1,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    PrimaryNomoButton(
                      onPressed: pair.isUpdating
                          ? null
                          : () {
                              if (pair.position == null) {
                                NomoNavigator.of(context)
                                    .push(AddScreenRoute(pair: pair));
                                return;
                              }
                              NomoNavigator.of(context)
                                  .push(DetailsScreenRoute(pair: pair));
                            },
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: NomoText(
                        pair.position == null ? "Enter" : "Mange Position",
                        style: context.typography.b1,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                PoolView(pair: pair, currency: currency),
                4.vSpacing,
                Row(
                  children: [
                    NomoText(
                      "${pair.token.symbol} Balance",
                      style: context.typography.b1,
                      fontWeight: FontWeight.w600,
                    ),
                    Spacer(),
                    Icon(
                      Icons.wallet,
                      color: context.colors.foreground1,
                      size: 18,
                    ),
                    8.hSpacing,
                    NomoText(
                      pair.balanceToken?.displayDouble.formatTokenBalance() ??
                          "",
                      maxLines: 2,
                      fit: true,
                      style: context.typography.b1,
                    ),
                  ],
                ),
              ],
              // ],
            ),
          ),
        );
      },
    );
  }
}
