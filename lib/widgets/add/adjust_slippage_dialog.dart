import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/dialog/nomo_dialog.dart';
import 'package:nomo_ui_kit/components/divider/nomo_divider.dart';
import 'package:nomo_ui_kit/components/dropdownmenu/drop_down_item.dart';
import 'package:nomo_ui_kit/components/dropdownmenu/dropdownmenu.dart';
import 'package:nomo_ui_kit/components/input/textInput/nomo_input.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';
import 'package:uniswap_liquidity/widgets/add/liquidity_input_field.dart';

class SlippageDialog extends HookConsumerWidget {
  final Pair pair;
  final ValueNotifier<String> slippageNotifier;

  const SlippageDialog(
      {required this.pair, required this.slippageNotifier, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetNotifier = ref.watch(assetNotifierProvider);
    final slippageProvider = slippageNotifier;

    return NomoDialog(
      maxWidth: 480,
      widthRatio: 0.9,
      leading: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NomoText("Settings", style: context.typography.h1),
          8.vSpacing,
          NomoText(
            "Adjust to your personal preference",
            style: context.typography.b1,
            color: Colors.white54,
          ),
        ],
      ),
      backgroundColor: context.colors.background2,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(16),
      content: Column(
        children: [
          const NomoDivider(),
          16.vSpacing,
          Row(
            children: [
              NomoText("Currency", style: context.typography.b2),
              const Spacer(),
              SizedBox(
                width: 200,
                child: NomoDropDownMenu(
                  backgroundColor: context.colors.background1,
                  dropdownColor: context.colors.background1,
                  borderRadius: BorderRadius.circular(16),
                  itemPadding: const EdgeInsets.symmetric(horizontal: 24),
                  valueNotifer: assetNotifier.currencyNotifier,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  iconColor: context.colors.foreground1,
                  height: 48,
                  onChanged: (_) {},
                  items: [
                    for (final currency in Currency.values)
                      NomoDropDownItemString(
                        value: currency,
                        title: "${currency.displayName} ${currency.symbol} ",
                      )
                  ],
                ),
              ),
            ],
          ),
          32.vSpacing,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NomoText("Slippage Tolerance", style: context.typography.b2),
              16.vSpacing,
              NomoInput(
                background: context.colors.background1,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                trailling: NomoText(
                  "%",
                  style: context.typography.b2,
                ),
                valueNotifier: slippageProvider,
                style: context.typography.b2,
                textAlign: TextAlign.end,
                maxLines: 1,
                inputFormatters: [CustomNumberInputFormatter(decimals: 4)],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final slippage in [0.1, 0.5, 1.0])
                      PrimaryNomoButton(
                        text: "$slippage%",
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color.fromARGB(0, 212, 102, 102),
                        width: 48,
                        height: 32,
                        textStyle: context.typography.b1,
                        margin: const EdgeInsets.only(right: 8),
                        onPressed: () {
                          slippageProvider.value = slippage.toString();
                        },
                      )
                  ],
                ),
              ),
            ],
          ),
          16.vSpacing,
        ],
      ),
    );
  }
}
