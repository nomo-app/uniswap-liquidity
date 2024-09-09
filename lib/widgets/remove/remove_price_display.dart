import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/widgets/add/add_liquidity_info.dart';

class RemovePriceDisplay extends ConsumerWidget {
  final Pair pair;
  const RemovePriceDisplay({required this.pair, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NomoCard(
      padding: EdgeInsets.only(
        top: 16,
      ),
      borderRadius: BorderRadius.circular(
        24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: NomoText(
              "Prices",
              style: context.theme.typography.b1,
            ),
          ),
          12.vSpacing,
          NomoCard(
            padding: EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(24),
            backgroundColor: context.theme.colors.background2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                UnitDisplay(
                  token: pair.tokeWZeniq,
                  zeniq: pair.token,
                  isOther: true,
                  value: pair.tokenPerZeniq
                      .toMaxPrecisionWithoutScientificNotation(5),
                ),
                UnitDisplay(
                  value: pair.zeniqPerToken
                      .toMaxPrecisionWithoutScientificNotation(5),
                  token: pair.token,
                  zeniq: pair.tokeWZeniq,
                  isOther: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
