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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

        return ToggleButtons(
          borderColor: context.theme.colors.onDisabled,
          borderWidth: 2,
          constraints: BoxConstraints.expand(
            width: (width - 6) / 2,
            height: 42,
          ),
          selectedBorderColor: context.theme.colors.primary,
          selectedColor: context.theme.colors.foreground1,
          color: context.theme.colors.foreground1,
          fillColor: context.theme.colors.primary,
          textStyle: context.typography.b1.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
      },
    );
  }
}
