import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/input/textInput/nomo_input.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class LiquidityInputField extends HookConsumerWidget {
  final EthBasedTokenEntity? token;

  const LiquidityInputField({super.key, required this.token});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.theme.colors.onDisabled,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NomoInput(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            selectedBorder: Border.fromBorderSide(
              BorderSide(color: context.theme.colors.surface),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  r'^\d+([.,]?\d{0,' +
                      // (token?.decimals ?? 18).toString() +
                      r'})',
                ),
              ),
            ],
            background: context.theme.colors.surface,
            placeHolder: "0.0",
            placeHolderStyle: context.typography.b3,
            style: context.typography.b3,
            trailling: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  color: Colors.red,
                ),
                8.hSpacing,
                NomoText(
                  token?.symbol ?? "nav",
                  style: context.typography.b2,
                ),
              ],
            ),
            height: 58,
          ),
          8.vSpacing,
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 12,
              right: 16,
            ),
            child: Row(
              children: [
                NomoText(
                  "\$0.00",
                  style: context.typography.b1,
                ),
                const Spacer(),
                Icon(
                  Icons.wallet,
                  color: context.theme.colors.foreground1,
                ),
                8.hSpacing,
                NomoText(
                  "\$0.00",
                  style: context.typography.b1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
