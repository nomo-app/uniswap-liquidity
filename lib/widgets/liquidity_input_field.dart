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
  final Amount balance;
  final ValueNotifier<String?> errorNotifier;
  final ValueNotifier<String> valueNotifier;
  final double fiatBlance;
  const LiquidityInputField({
    super.key,
    required this.token,
    required this.balance,
    required this.errorNotifier,
    required this.valueNotifier,
    required this.fiatBlance,
  });
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
            errorBorder: Border.fromBorderSide(
              BorderSide(color: context.theme.colors.error),
            ),
            borderRadius: BorderRadius.circular(8),
            errorNotifier: errorNotifier,
            errorColor: Colors.red,
            valueNotifier: valueNotifier,
            maxLines: 1,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            selectedBorder: Border.fromBorderSide(
              BorderSide(color: context.theme.colors.surface),
            ),
            inputFormatters: [
              CustomNumberInputFormatter(decimals: 7),
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
                  "\$${fiatBlance.toStringAsFixed(2)}",
                  style: context.typography.b1,
                ),
                const Spacer(),
                Icon(
                  Icons.wallet,
                  color: context.theme.colors.foreground1,
                ),
                8.hSpacing,
                NomoText(
                  balance.displayValue,
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

class CustomNumberInputFormatter extends TextInputFormatter {
  final int decimals;

  CustomNumberInputFormatter({required this.decimals});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.text.startsWith('00')) {
      return oldValue;
    }

    final regex = RegExp(
      r'^\d*([.,]?\d{0,' + decimals.toString() + r'})?$',
    );

    if (regex.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}
