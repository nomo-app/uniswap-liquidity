import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/widgets/liquidity_input_field.dart';

class AddLiquidityBox extends ConsumerWidget {
  const AddLiquidityBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        LiquidityInputField(),
        12.vSpacing,
        Icon(
          Icons.add_circle_outline_outlined,
          color: context.theme.colors.onDisabled,
          size: 32,
        ),
        12.vSpacing,
        LiquidityInputField(),
      ],
    );
  }
}
