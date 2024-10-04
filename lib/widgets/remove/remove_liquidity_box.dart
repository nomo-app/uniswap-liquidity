import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/widgets/position_box.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_liquidity_slider.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_liquidity_value.dart';

class RemoveLiquidityBox extends HookConsumerWidget {
  final Pair selectedPool;
  const RemoveLiquidityBox({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = useState(0.0);
    final liquidityToRemove = useState("0.0");

    return Column(
      children: [
        PositionBox(pair: selectedPool),
        12.vSpacing,
        RemoveLiquiditySlider(
            sliderValue: sliderValue,
            pair: selectedPool,
            liquidityToRemove: liquidityToRemove),
        12.vSpacing,
        Icon(
          Icons.arrow_downward,
          size: 24,
          color: context.theme.colors.onDisabled,
        ),
        12.vSpacing,
        RemoveLiquidityValue(
          liquidityToRemove: liquidityToRemove,
          sliderValue: sliderValue,
          selectedPool: selectedPool,
        ),
      ],
    );
  }
}
