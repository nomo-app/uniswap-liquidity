import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';

class RemoveLiquiditySlider extends HookConsumerWidget {
  final ValueNotifier<double> sliderValue;

  const RemoveLiquiditySlider({required this.sliderValue, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        NomoText("Amount", style: context.typography.b2),
        12.vSpacing,
        NomoText(
          "${sliderValue.value}%",
          style: context.typography.b2,
        ),
        Slider(
          value: sliderValue.value,
          divisions: 100,
          onChanged: (value) {
            sliderValue.value = value.floor().toDouble();
          },
          min: 0,
          max: 100,
          inactiveColor: context.theme.colors.primary,
          activeColor: context.theme.colors.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PrimaryNomoButton(
              padding: EdgeInsets.all(8),
              width: 64,
              textStyle: context.typography.b1,
              onPressed: () {
                sliderValue.value = 25;
              },
              text: "25%",
            ),
            PrimaryNomoButton(
              width: 64,
              textStyle: context.typography.b1,
              padding: EdgeInsets.all(8),
              onPressed: () {
                sliderValue.value = 50;
              },
              text: "50%",
            ),
            PrimaryNomoButton(
              width: 64,
              textStyle: context.typography.b1,
              padding: EdgeInsets.all(8),
              onPressed: () {
                sliderValue.value = 75;
              },
              text: "75%",
            ),
            PrimaryNomoButton(
              width: 64,
              textStyle: context.typography.b1,
              padding: EdgeInsets.all(8),
              onPressed: () {
                sliderValue.value = 100;
              },
              text: "Max",
            ),
          ],
        ),
      ],
    );
  }
}
