import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/widgets/add_liquidity_box.dart';
import 'package:uniswap_liquidity/widgets/manage_buttons.dart';

class ManageCard extends HookConsumerWidget {
  final Pair selectedPool;

  const ManageCard({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = useState("Add");

    return SingleChildScrollView(
      child: NomoCard(
        margin: EdgeInsets.only(top: 32),
        elevation: 0,
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ManageButtons(
              initalValue: position.value,
              onChanged: (value) {
                position.value = value;
              },
            ),
            32.vSpacing,
            if (position.value == "Add") ...[
              AddLiquidityBox(selectedPool: selectedPool),
            ],
          ],
        ),
      ),
    );
  }
}
