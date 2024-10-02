import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/widgets/add/add_liquidity_info.dart';
import 'package:uniswap_liquidity/widgets/dotted_line.dart';

class RemovePriceDisplay extends HookConsumerWidget {
  final Pair pair;
  const RemovePriceDisplay({required this.pair, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency =
        useState(ref.watch(assetNotifierProvider).currencyNotifier.value);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                UnitDisplay(
                  token: pair.token,
                  zeniq: pair.tokeWZeniq,
                  isOther: true,
                  value: pair.tokenPerZeniq.formatTokenBalance(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NomoText(
                      "${pair.token.symbol} price",
                      style: context.theme.typography.b1,
                    ),
                    8.hSpacing,
                    DottedLine(),
                    8.hSpacing,
                    NomoText(
                      "${pair.tokenPrice.formatDouble(2)} ${currency.value.symbol}",
                      style: context.theme.typography.b1,
                    ),
                  ],
                ),
                UnitDisplay(
                  value: pair.zeniqPerToken.formatTokenBalance(),
                  token: pair.token,
                  zeniq: pair.tokeWZeniq,
                  isOther: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NomoText(
                      "ZENIQ price",
                      style: context.theme.typography.b1,
                    ),
                    8.hSpacing,
                    DottedLine(),
                    8.hSpacing,
                    NomoText(
                      "${pair.zeniqPrice.formatDouble(2)} ${currency.value.symbol}",
                      style: context.theme.typography.b1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
