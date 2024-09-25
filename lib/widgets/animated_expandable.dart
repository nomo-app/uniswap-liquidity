import 'package:flutter/material.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';

class AnimatedExpandableRow extends StatelessWidget {
  final bool isExpanded;
  final int lowTVLPoolsCount;
  final VoidCallback onTap;

  const AnimatedExpandableRow({
    super.key,
    required this.isExpanded,
    required this.lowTVLPoolsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isExpanded ? 180 : 0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 3.14159 / 180,
                  child: Icon(
                    Icons.arrow_downward,
                    color: context.theme.colors.primary,
                  ),
                );
              },
            ),
            8.hSpacing,
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: NomoText(
                key: ValueKey<bool>(isExpanded),
                isExpanded ? "Hide pools" : "Show $lowTVLPoolsCount more pools",
                style: context.typography.b2
                    .copyWith(color: context.theme.colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
