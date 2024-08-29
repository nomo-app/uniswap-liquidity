import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/selected_pool_provider.dart';

class ADDLiqiuidityInfo extends ConsumerWidget {
  const ADDLiqiuidityInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairProvider = ref.watch(selectedPoolProvider);
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
                pairProvider.pair?.volume24h.toString() ?? "0",
                style: context.typography.b1,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NomoText(
                  "Slippage",
                  style: context.typography.b1,
                ),
                NomoText(
                  "${pairProvider.slippage}%",
                  style: context.typography.b1,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NomoText(
                  "Fees 24h",
                  style: context.typography.b1,
                ),
                NomoText(
                  pairProvider.pair?.fees24h.toString() ?? "0",
                  style: context.typography.b1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
