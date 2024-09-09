import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/provider/position_provider.dart';
import 'package:uniswap_liquidity/widgets/position_box.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_liquidity_slider.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_liquidity_value.dart';

class RemoveLiquidityBox extends HookConsumerWidget {
  final Pair selectedPool;
  const RemoveLiquidityBox({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(positionNotifierProvider);
    final sliderValue = useState(0.0);

    return positions.when(
      data: (data) {
        final position = data.firstWhere((element) =>
            element.pair.token.contractAddress ==
            selectedPool.token.contractAddress);

        return Column(
          children: [
            PositionBox(pair: selectedPool),
            12.vSpacing,
            RemoveLiquiditySlider(sliderValue: sliderValue),
            12.vSpacing,
            Icon(
              Icons.arrow_downward,
              size: 24,
              color: context.theme.colors.onDisabled,
            ),
            12.vSpacing,
            RemoveLiquidityValue(
              sliderValue: sliderValue,
              selectedPool: selectedPool,
              position: position,
            ),
          ],
        );
      },
      error: (error, stackTrace) => NomoText(error.toString()),
      loading: () => CircularProgressIndicator(),
    );
  }
}
