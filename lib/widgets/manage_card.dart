import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/widgets/add/add_liquidity_box.dart';
import 'package:uniswap_liquidity/widgets/manage_buttons.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_liquidity_box.dart';

class ManageCard extends HookConsumerWidget {
  final Pair selectedPool;

  const ManageCard({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = useState("Add");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ManageButtons(
              initialValue: position.value,
              onChanged: (value) {
                position.value = value;
              },
            ),
            16.vSpacing,
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: position.value == "Add"
                  ? AddLiquidityBox(selectedPool: selectedPool)
                  : RemoveLiquidityBox(selectedPool: selectedPool),
            ),
          ],
        ),
      ),
    );
  }
}
