import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/dialog/nomo_dialog.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/show_all_pools_provider.dart';

class SuccessDialog extends ConsumerWidget {
  final String messageHex;
  const SuccessDialog({required this.messageHex, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAllPools = ref.read(showAllPoolsProvider);
    return NomoDialog(
      titleWidget: NomoText(
        "Success",
        style: context.typography.h1,
        maxLines: 1,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NomoText("Transaction", style: context.typography.b2),
          8.vSpacing,
          SelectableText(style: context.typography.b2, messageHex),
          16.vSpacing,
        ],
      ),
      actions: [
        Expanded(
          child: PrimaryNomoButton(
            expandToConstraints: true,
            height: 52,
            onPressed: () {
              if (showAllPools) {
                ref.read(showAllPoolsProvider.notifier).toggle();
              }

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: NomoText("View Positions", style: context.typography.b2),
          ),
        ),
      ],
    );
  }
}
