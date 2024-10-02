import 'package:flutter/material.dart';
import 'package:nomo_ui_kit/components/expandable/expandable.dart';
import 'package:nomo_ui_kit/components/loading/shimmer/loading_shimmer.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';

class PoolView extends StatelessWidget {
  const PoolView({
    this.initialyExpanded = false,
    super.key,
    required this.pair,
    required this.currency,
  });

  final Pair pair;
  final Currency currency;
  final bool initialyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expandable(
          initiallyExpanded: initialyExpanded,
          splashRadius: 0,
          titlePadding: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.symmetric(vertical: 4),
          iconColor: context.colors.foreground1,
          iconSize: 22,
          title: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NomoText(
                  "Total Value Locked ",
                  style: context.typography.b1,
                  fontWeight: FontWeight.w600,
                ),
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
                        "${pair.tvl.formatDouble(2)} ${currency.symbol}",
                        style: context.typography.b1,
                      ),
              ],
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NomoText(
                  "ZENIQ",
                  style: context.typography.b1,
                ),
                Row(
                  children: [
                    NomoText(
                      pair.zeniqValue.displayDouble
                          .toMaxPrecisionWithoutScientificNotation(4),
                      style: context.typography.b1,
                    ),
                    4.hSpacing,
                    Icon(
                      Icons.compare_arrows_rounded,
                      color: context.colors.foreground1,
                    ),
                    4.hSpacing,
                    NomoText(
                      "${pair.zeniqFiatValue.formatDouble(2)} ${currency.symbol}",
                      style: context.typography.b1,
                    ),
                  ],
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
                Row(
                  children: [
                    NomoText(
                      pair.tokenValue.displayDouble
                          .toMaxPrecisionWithoutScientificNotation(4),
                      style: context.typography.b1,
                    ),
                    4.hSpacing,
                    Icon(
                      Icons.compare_arrows_rounded,
                      color: context.colors.foreground1,
                    ),
                    4.hSpacing,
                    NomoText(
                      "${pair.tokenFiatValue.formatDouble(2)} ${currency.symbol}",
                      style: context.typography.b1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (pair.position != null)
          Expandable(
            initiallyExpanded: initialyExpanded,
            splashRadius: 0,
            titlePadding: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            iconColor: context.colors.foreground1,
            iconSize: 22,
            title: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NomoText(
                    "My Value Locked",
                    style: context.typography.b1,
                    fontWeight: FontWeight.w600,
                  ),
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
                          "${pair.position?.valueLocked.formatDouble(2)} ${currency.symbol}",
                          style: context.typography.b1,
                        ),
                ],
              ),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NomoText(
                    "ZENIQ",
                    style: context.typography.b1,
                  ),
                  Row(
                    children: [
                      NomoText(
                        pair.position?.zeniqValue.displayDouble
                                .toMaxPrecisionWithoutScientificNotation(4) ??
                            "",
                        style: context.typography.b1,
                      ),
                      4.hSpacing,
                      Icon(
                        Icons.compare_arrows_rounded,
                        color: context.colors.foreground1,
                      ),
                      4.hSpacing,
                      NomoText(
                        "${pair.position?.zeniqFiatValue.formatDouble(2) ?? 0} ${currency.symbol}",
                        style: context.typography.b1,
                      ),
                    ],
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
                  Row(
                    children: [
                      NomoText(
                        pair.position?.tokenValue.displayDouble
                                .toMaxPrecisionWithoutScientificNotation(4) ??
                            "",
                        style: context.typography.b1,
                      ),
                      4.hSpacing,
                      Icon(
                        Icons.compare_arrows_rounded,
                        color: context.colors.foreground1,
                      ),
                      4.hSpacing,
                      NomoText(
                        "${pair.position?.tokenFiatValue.formatDouble(2) ?? 0} ${currency.symbol}",
                        style: context.typography.b1,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NomoText(
                    "Pool share",
                    style: context.theme.typography.b1,
                  ),
                  8.hSpacing,
                  NomoText(
                    "${pair.position!.share.displayDouble.formatPriceImpact().$1}%",
                    style: context.theme.typography.b1,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
