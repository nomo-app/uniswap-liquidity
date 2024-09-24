import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/loading/shimmer/loading_shimmer.dart';
import 'package:nomo_ui_kit/components/loading/shimmer/shimmer.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/widgets/dotted_line.dart';

class PoolOverview extends ConsumerWidget {
  final Pair pair;
  final bool showTVL;
  const PoolOverview({super.key, required this.pair, required this.showTVL});

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
          child: InkWell(
            onTap: pair.isUpdating
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
                        children: [
                          NomoText(
                            pair.token.symbol,
                            style: context.typography.b1,
                          ),

                          // Row(
                          //   children: [
                          //     NomoText(
                          //       "ZENIQ",
                          //       style: context.typography.b1,
                          //     ),
                          //         NomoText(
                          //           " : ",
                          //           style: context.typography.b1,
                          //           opacity: 0.7,
                          //         ),
                          //         NomoText(
                          //           pair.token.symbol,
                          //           style: context.typography.b1,
                          //         ),
                          //   ],
                          // ),
                          const SizedBox(height: 4),
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
                      Spacer(),
                      SizedBox(
                        width: 86,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              pair.position == null
                                  ? "Enter"
                                  : "Mange\nPosition",
                              style: context.typography.b1,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: context.theme.colors.foreground1,
                              size: 26,
                            ),
                          ],
                        ),
                      ),

                      // ),
                    ],
                  ),
                  if (showTVL) ...[
                    16.vSpacing,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              "Total Value Locked",
                              style: context.typography.b1,
                            ),
                            8.hSpacing,
                            DottedLine(),
                            8.hSpacing,
                            pair.isUpdating
                                ? ShimmerLoading(
                                    isLoading: pair.isUpdating,
                                    child: Container(
                                      height: 16,
                                      width: 62,
                                      decoration: BoxDecoration(
                                        color: context.colors.background1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                : NomoText(
                                    "${pair.tvl.toMaxPrecisionWithoutScientificNotation(2)} ${currency.symbol}",
                                    maxLines: 2,
                                    fit: true,
                                    style: context.typography.b1,
                                  ),
                          ],
                        ),
                        if (pair.position != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NomoText(
                                "Value Locked",
                                style: context.typography.b1,
                              ),
                              8.hSpacing,
                              DottedLine(),
                              8.hSpacing,
                              pair.isUpdating
                                  ? ShimmerLoading(
                                      isLoading: pair.isUpdating,
                                      child: Container(
                                        height: 16,
                                        width: 62,
                                        decoration: BoxDecoration(
                                          color: context.colors.background1,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    )
                                  : NomoText(
                                      "${pair.position?.valueLocked.toMaxPrecisionWithoutScientificNotation(2)} ${currency.symbol}",
                                      maxLines: 2,
                                      fit: true,
                                      style: context.typography.b1,
                                    ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NomoText(
                                "ZENIQ",
                                style: context.typography.b1,
                              ),
                              8.hSpacing,
                              DottedLine(),
                              8.hSpacing,
                              NomoText(
                                pair.position?.zeniqValue.displayDouble
                                        .toMaxPrecisionWithoutScientificNotation(
                                            4) ??
                                    "",
                                style: context.typography.b1,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NomoText(
                                pair.token.symbol,
                                style: context.typography.b1,
                              ),
                              8.hSpacing,
                              DottedLine(),
                              8.hSpacing,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              "${pair.token.symbol} Balance",
                              style: context.typography.b1,
                            ),
                            8.hSpacing,
                            DottedLine(),
                            8.hSpacing,
                            NomoText(
                              pair.balanceToken?.displayDouble
                                      .toMaxPrecisionWithoutScientificNotation(
                                          4) ??
                                  "",
                              maxLines: 2,
                              fit: true,
                              style: context.typography.b1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    16.vSpacing,
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              "Total Value Locked",
                              style: context.typography.b1,
                            ),
                            8.hSpacing,
                            DottedLine(),
                            8.hSpacing,
                            pair.isUpdating
                                ? ShimmerLoading(
                                    isLoading: pair.isUpdating,
                                    child: Container(
                                      height: 16,
                                      width: 62,
                                      decoration: BoxDecoration(
                                        color: context.colors.background1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                : NomoText(
                                    "${pair.tvl.toMaxPrecision(2)} ${currency.symbol}",
                                    style: context.typography.b1,
                                  ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              "Value Locked",
                              style: context.typography.b1,
                            ),
                            8.hSpacing,
                            DottedLine(),
                            8.hSpacing,
                            pair.isUpdating
                                ? ShimmerLoading(
                                    isLoading: pair.isUpdating,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: context.colors.background1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      height: 16,
                                      width: 62,
                                    ),
                                  )
                                : NomoText(
                                    "${pair.position?.valueLocked.toMaxPrecision(2)} ${currency.symbol}",
                                    style: context.typography.b1,
                                  ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              "ZENIQ",
                              style: context.typography.b1,
                            ),
                            8.hSpacing,
                            DottedLine(),
                            8.hSpacing,
                            NomoText(
                              pair.position?.zeniqValue.displayDouble
                                      .toMaxPrecisionWithoutScientificNotation(
                                          4) ??
                                  "",
                              style: context.typography.b1,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NomoText(
                              pair.token.symbol,
                              style: context.typography.b1,
                            ),
                            8.hSpacing,
                            DottedLine(),
                            8.hSpacing,
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
          ),
        );
      },
    );
  }
}
