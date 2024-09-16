import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';

class PoolOverview extends ConsumerWidget {
  final Pair pair;
  const PoolOverview({super.key, required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image0 =
        ref.read(assetNotifierProvider).imageNotifierForToken(pair.tokeWZeniq)!;
    final image1 =
        ref.read(assetNotifierProvider).imageNotifierForToken(pair.token)!;

    return ListenableBuilder(
      listenable: Listenable.merge([image0, image1]),
      builder: (context, child) {
        final imageToken0 = image0.value;
        final imageToken1 = image1.value;

        return InkWell(
          onTap: () {
            if (pair.position == null) {
              NomoNavigator.of(context).push(AddScreenRoute(pair: pair));
              return;
            }
            NomoNavigator.of(context).push(DetailsScreenRoute(pair: pair));
          },
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
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              NomoText(
                                pair.tokeWZeniq.symbol,
                                style: context.typography.b1,
                              ),
                              NomoText(
                                " / ",
                                style: context.typography.b1,
                                opacity: 0.7,
                              ),
                              NomoText(
                                pair.token.symbol,
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
                                    fontSize: 12,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    NomoText(
                      pair.position == null ? "Enter" : "Mange\nPosition",
                      style: context.typography.b1,
                    ),
                    12.vSpacing,
                    // IconButton(
                    //   splashRadius: 2,
                    //   color: context.theme.colors.foreground1,
                    //   onPressed: () {
                    //     NomoNavigator.of(context)
                    //         .push(DetailsScreenRoute(pair: pair));
                    //   },
                    //   icon:
                    Icon(
                      Icons.arrow_forward_ios,
                      color: context.theme.colors.foreground1,
                      size: 26,
                    ),
                    // ),
                  ],
                ),
                if (pair.position == null) ...[
                  16.vSpacing,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          NomoText(
                            "TVL",
                            style: context.typography.b1,
                          ),
                          8.vSpacing,
                          NomoText(
                            pair.tvl.toMaxPrecisionWithoutScientificNotation(4),
                            maxLines: 2,
                            fit: true,
                            style: context.typography.b1,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          NomoText(
                            "${pair.token.symbol} Balance",
                            style: context.typography.b1,
                          ),
                          8.vSpacing,
                          SizedBox(
                            width: 100,
                            child: NomoText(
                              pair.balanceToken?.displayDouble
                                      .toMaxPrecisionWithoutScientificNotation(
                                          4) ??
                                  "",
                              maxLines: 2,
                              fit: true,
                              style: context.typography.b1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  16.vSpacing,
                  16.vSpacing,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          NomoText(
                            "Liquidity",
                            style: context.typography.b1,
                          ),
                          8.vSpacing,
                          NomoText(
                            pair.position?.liquidity.displayDouble
                                    .toMaxPrecisionWithoutScientificNotation(
                                        4) ??
                                "",
                            style: context.typography.b1,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          NomoText(
                            "WZENIQ",
                            style: context.typography.b1,
                          ),
                          8.vSpacing,
                          NomoText(
                            pair.position?.zeniqValue.displayDouble
                                    .toMaxPrecisionWithoutScientificNotation(
                                        4) ??
                                "",
                            style: context.typography.b1,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          NomoText(
                            pair.token.symbol,
                            style: context.typography.b1,
                          ),
                          8.vSpacing,
                          NomoText(
                            pair.position?.tokenValue.displayDouble
                                    .toMaxPrecisionWithoutScientificNotation(
                                        4) ??
                                "",
                            style: context.typography.b1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
