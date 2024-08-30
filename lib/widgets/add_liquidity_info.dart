import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/divider/nomo_divider.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';

class ADDLiqiuidityInfo extends ConsumerWidget {
  final Pair pair;
  final String slippage;

  const ADDLiqiuidityInfo(
      {required this.pair, required this.slippage, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.theme.colors.onDisabled,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NomoText(
                "Volume 24h",
                style: context.typography.b1,
              ),
              NomoText(
                pair.volume24h?.toString() ?? "nav",
                style: context.typography.b1,
              ),
            ],
          ),
          NomoDivider(
            color: context.theme.colors.onDisabled,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NomoText(
                "Slippage",
                style: context.typography.b1,
              ),
              NomoText(
                slippage,
                // "${pairProvider.slippage}%",
                style: context.typography.b1,
              ),
            ],
          ),
          NomoDivider(
            color: context.theme.colors.onDisabled,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NomoText(
                "Fees 24h",
                style: context.typography.b1,
              ),
              NomoText(
                pair.fees24h?.toString() ?? "nav",
                style: context.typography.b1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
