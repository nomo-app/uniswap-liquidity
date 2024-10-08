import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/text/nomo_text_button.dart';
import 'package:nomo_ui_kit/components/input/textInput/nomo_input.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class LiquidityInputField extends HookConsumerWidget {
  final ERC20Entity? token;
  final Amount? balance;
  final ValueNotifier<String?> errorNotifier;
  final ValueNotifier<String> valueNotifier;
  final double? fiatBlance;
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
    final tokenImage =
        ref.read(assetNotifierProvider).imageNotifierForToken(token!)!;

    final assetNotifier = ref.watch(assetNotifierProvider).currencyNotifier;

    final symbol = token?.symbol == "WZENIQ" ? "ZENIQ" : token?.symbol;

    return ListenableBuilder(
        listenable: tokenImage,
        builder: (context, child) {
          final image = tokenImage.value;
          return NomoInput(
            scrollable: true,
            errorNotifier: errorNotifier,
            border: Border.fromBorderSide(
              BorderSide(color: context.theme.colors.onDisabled, width: 2),
            ),
            errorBorder: Border.fromBorderSide(
              BorderSide(color: context.theme.colors.error, width: 2),
            ),
            borderRadius: BorderRadius.circular(16),
            valueNotifier: valueNotifier,
            maxLines: 1,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            selectedBorder: Border.fromBorderSide(
              BorderSide(color: context.theme.colors.primary, width: 2),
            ),
            inputFormatters: [
              CustomNumberInputFormatter(decimals: token!.decimals),
            ],
            background: context.theme.colors.background1,
            placeHolder: "0.0",
            placeHolderStyle: context.typography.b3,
            style: context.typography.b3,
            trailling: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                image.when(
                  data: (data) => ClipOval(
                    child: Image.network(
                      data.small,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    error.toString(),
                  ),
                  loading: () => CircularProgressIndicator(
                    color: context.theme.colors.primary,
                  ),
                ),
                8.hSpacing,
                NomoText(
                  symbol ?? "nav",
                  style: context.typography.b2,
                ),
              ],
            ),
            bottom: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NomoText(
                    "Balance",
                    style: context.typography.b1,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.wallet,
                        color: context.theme.colors.foreground1,
                        size: 16,
                      ),
                      4.hSpacing,
                      NomoText(
                        balance?.displayDouble.formatTokenBalance() ?? "0.00",
                        style: context.typography.b1,
                      ),
                      if (fiatBlance != null) ...[
                        8.hSpacing,
                        ValueListenableBuilder(
                          valueListenable: assetNotifier,
                          builder: (context, value, child) => NomoText(
                            "≈ ${formatValueWithCurrency(value, fiatBlance ?? 0)}",
                            style: context.typography.b1,
                          ),
                        ),
                      ],
                      8.hSpacing,
                      NomoTextButton(
                        text: "Max",
                        textStyle: context.typography.b1.copyWith(
                          color: context.theme.colors.primary,
                        ),
                        onPressed: () {
                          valueNotifier.value =
                              balance?.displayDouble.toString() ?? "0.00";
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
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
