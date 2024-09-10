import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/dialog/nomo_dialog.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';

class SuccessDialog extends ConsumerWidget {
  final String messageHex;
  const SuccessDialog({required this.messageHex, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NomoDialog(
      title: "Liquidity added",
      content: Column(
        children: [
          NomoText("Liquidity added successfully",
              style: context.typography.b3),
          16.vSpacing,
          NomoText("Transaction hash: $messageHex",
              style: context.typography.b3),
        ],
      ),
      actions: [
        Expanded(
          child: PrimaryNomoButton(
            expandToConstraints: true,
            height: 52,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: NomoText("View on explorer", style: context.typography.b2),
          ),
        ),
      ],
    );
  }
}
