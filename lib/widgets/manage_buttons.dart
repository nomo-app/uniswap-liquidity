import 'package:flutter/material.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';

class ManageButtons extends StatelessWidget {
  final String initalValue;
  final void Function(String) onChanged;
  const ManageButtons({
    required this.initalValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.theme.colors.onDisabled,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryNomoButton(
              elevation: initalValue == "Add" ? 2 : 0,
              backgroundColor:
                  initalValue == "Add" ? null : context.theme.colors.surface,
              onPressed: () => onChanged("Add"),
              text: "Add",
            ),
          ),
          Expanded(
            child: PrimaryNomoButton(
              elevation: initalValue != "Add" ? 2 : 0,
              backgroundColor:
                  initalValue != "Add" ? null : context.theme.colors.surface,
              onPressed: () => onChanged("Remove"),
              text: "Remove",
            ),
          ),
        ],
      ),
    );
  }
}
