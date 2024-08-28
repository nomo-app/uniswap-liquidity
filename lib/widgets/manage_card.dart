import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/widgets/add_liquidity_box.dart';
import 'package:uniswap_liquidity/widgets/manage_buttons.dart';

class ManageCard extends HookConsumerWidget {
  const ManageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = useState("Add");
    // final pool = ref.watch(selectedPoolProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: NomoCard(
        margin: EdgeInsets.only(top: 32),
        elevation: 0,
        border: Border.all(
          color: context.theme.colors.onDisabled,
          width: 1,
        ),
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
            12.vSpacing,
            if (position.value == "Add") ...[
              AddLiquidityBox(),
            ],
          ],
        ),
      ),
    );
  }
}
