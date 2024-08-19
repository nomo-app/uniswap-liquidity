import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/widgets/add_liquidity_box.dart';
import 'package:uniswap_liquidity/widgets/manage_buttons.dart';

class ManageCard extends HookWidget {
  const ManageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final position = useState("Add");

    return NomoCard(
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
          NomoText(
            "Manage your position",
            style: context.typography.b2,
          ),
          12.vSpacing,
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
    );
  }
}
