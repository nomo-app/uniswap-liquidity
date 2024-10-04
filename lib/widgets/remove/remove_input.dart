import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/input/textInput/nomo_input.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/widgets/add/liquidity_input_field.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class RemoveInput extends HookConsumerWidget {
  final ERC20Entity? token;
  final ValueNotifier<String> valueNotifier;
  final ValueNotifier<String?> errorNotifier;
  const RemoveInput({
    super.key,
    required this.token,
    required this.errorNotifier,
    required this.valueNotifier,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenImage =
        ref.read(assetNotifierProvider).imageNotifierForToken(token!)!;

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
        );
      },
    );
  }
}
