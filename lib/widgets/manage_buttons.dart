import 'package:flutter/material.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';

class ManageButtons extends StatelessWidget {
  final String initialValue;
  final void Function(String) onChanged;
  const ManageButtons({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderColor: context.theme.colors.onDisabled,
      borderWidth: 1,
      constraints: BoxConstraints(
        minHeight: 52,
        minWidth: MediaQuery.of(context).size.width / 2 - 24,
      ),
      selectedBorderColor: context.theme.colors.primary,
      selectedColor: context.theme.colors.foreground1,
      color: context.theme.colors.foreground1,
      fillColor: context.theme.colors.primary,
      textStyle: context.typography.b2,
      borderRadius: BorderRadius.circular(16),
      isSelected: initialValue == "Add" ? [true, false] : [false, true],
      onPressed: (index) => onChanged(index == 0 ? "Add" : "Remove"),
      children: const [
        Text(
          "Add",
        ),
        Text(
          "Remove",
        ),
      ],
    );
  }
}
