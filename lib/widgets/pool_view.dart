import 'package:flutter/material.dart';
import 'package:nomo_ui_kit/components/expandable/expandable.dart';
import 'package:nomo_ui_kit/components/loading/shimmer/loading_shimmer.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
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
        _buildExpandable(
          context,
          title: "Total Value Locked",
          value: pair.isUpdating
              ? _buildShimmer(context)
              : NomoText(
                  formatValueWithCurrency(currency, pair.tvl),
                  style: context.typography.b1,
                ),
          children: [
            _buildTokenRow(
              context,
              "ZENIQ",
              pair.zeniqValue.displayDouble.formatTokenBalance(),
              pair.isUpdating
                  ? _buildShimmer(context)
                  : formatValueWithCurrency(currency, pair.zeniqFiatValue),
            ),
            _buildTokenRow(
              context,
              pair.token.symbol,
              pair.tokenValue.displayDouble.formatTokenBalance(),
              pair.isUpdating
                  ? _buildShimmer(context)
                  : formatValueWithCurrency(currency, pair.tokenFiatValue),
            ),
          ],
        ),
        if (pair.position != null)
          _buildExpandable(
            context,
            title: "My Value Locked",
            value: pair.isUpdating
                ? _buildShimmer(context)
                : NomoText(
                    formatValueWithCurrency(
                        currency, pair.position?.valueLocked ?? 0),
                    style: context.typography.b1,
                  ),
            children: [
              _buildTokenRow(
                context,
                "ZENIQ",
                pair.position?.zeniqValue.displayDouble.formatTokenBalance() ??
                    "",
                pair.isUpdating
                    ? _buildShimmer(context)
                    : formatValueWithCurrency(
                        currency, pair.position?.zeniqFiatValue ?? 0),
              ),
              _buildTokenRow(
                context,
                pair.token.symbol,
                pair.position?.tokenValue.displayDouble.formatTokenBalance() ??
                    "",
                pair.isUpdating
                    ? _buildShimmer(context)
                    : formatValueWithCurrency(
                        currency, pair.position?.tokenFiatValue ?? 0),
              ),
              _buildPoolShare(context, pair),
            ],
          ),
      ],
    );
  }

  Widget _buildPoolShare(BuildContext context, Pair pair) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NomoText(
          "Pool share",
          style: context.theme.typography.b1,
        ),
        NomoText(
          "${pair.position!.share.displayDouble.formatPriceImpact().$1}%",
          style: context.theme.typography.b1,
        ),
      ],
    );
  }

  Widget _buildTokenRow(
      BuildContext context, String symbol, String amount, dynamic fiatValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NomoText(
          symbol,
          style: context.typography.b1,
        ),
        Row(
          children: [
            NomoText(
              amount,
              style: context.typography.b1,
            ),
            SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.centerRight,
                child: fiatValue is Widget
                    ? fiatValue
                    : NomoText(
                        fiatValue,
                        style: context.typography.b1,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandable(BuildContext context,
      {required String title,
      required Widget value,
      required List<Widget> children}) {
    return Expandable(
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
              title,
              style: context.typography.b1,
              fontWeight: FontWeight.w600,
            ),
            value,
          ],
        ),
      ),
      children: children,
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        height: 16,
        width: 62,
        decoration: BoxDecoration(
          color: context.colors.background1,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
