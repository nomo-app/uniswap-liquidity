import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class RemoveLiquiditySlider extends HookConsumerWidget {
  final ValueNotifier<double> sliderValue;
  final ValueNotifier<String> liquidityToRemove;
  final Pair pair;

  const RemoveLiquiditySlider(
      {required this.sliderValue,
      required this.pair,
      required this.liquidityToRemove,
      super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = Amount.convert(
        value: double.parse(liquidityToRemove.value), decimals: 18);

    return NomoCard(
      backgroundColor: context.theme.colors.background2,
      padding: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NomoText("Amount", style: context.typography.b2),
              8.vSpacing,
              Align(
                alignment: Alignment.centerRight,
                child: NomoText(
                  "${value.displayDouble.toMaxPrecisionWithoutScientificNotation(5)} WZENIQ/${pair.token.symbol}",
                  style: context.typography.b2,
                ),
              )
            ],
          ),
          12.vSpacing,
          Slider(
            value: sliderValue.value,
            // divisions: 100,
            label: "${sliderValue.value}%",
            onChanged: (value) {
              sliderValue.value = double.parse(value.toStringAsFixed(2));
            },
            min: 0,
            max: 100,
            inactiveColor: context.theme.colors.primary,
            activeColor: context.theme.colors.primary,
          ),
          12.vSpacing,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrimaryNomoButton(
                  padding: EdgeInsets.all(8),
                  width: 52,
                  textStyle: context.typography.b1,
                  onPressed: () {
                    sliderValue.value = 25;
                  },
                  text: "25%",
                ),
                PrimaryNomoButton(
                  width: 52,
                  textStyle: context.typography.b1,
                  padding: EdgeInsets.all(8),
                  onPressed: () {
                    sliderValue.value = 50;
                  },
                  text: "50%",
                ),
                PrimaryNomoButton(
                  width: 52,
                  textStyle: context.typography.b1,
                  padding: EdgeInsets.all(8),
                  onPressed: () {
                    sliderValue.value = 75;
                  },
                  text: "75%",
                ),
                PrimaryNomoButton(
                  width: 52,
                  textStyle: context.typography.b1,
                  padding: EdgeInsets.all(8),
                  onPressed: () {
                    sliderValue.value = 100;
                  },
                  text: "Max",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
