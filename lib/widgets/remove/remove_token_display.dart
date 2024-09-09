import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/utils/image_repository.dart';

class RemoveTokenDisplay extends HookConsumerWidget {
  final AsyncValue<ImageEntity> zeniqImage;
  final AsyncValue<ImageEntity> tokenImage;
  final String tokenAmount;
  final String zeniqAmount;
  final String tokenSymbol;

  const RemoveTokenDisplay(
      {required this.tokenAmount,
      required this.zeniqAmount,
      required this.tokenImage,
      required this.zeniqImage,
      required this.tokenSymbol,
      super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NomoCard(
      borderRadius: BorderRadius.circular(24),
      backgroundColor: context.theme.colors.background2,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NomoText(
                zeniqAmount,
                style: context.typography.b2,
              ),
              Spacer(),
              zeniqImage.when(
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
                loading: () => CircularProgressIndicator(),
              ),
              8.hSpacing,
              NomoText(
                "WZENIQ",
                style: context.typography.b2,
              ),
            ],
          ),
          8.vSpacing,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NomoText(
                tokenAmount,
                style: context.typography.b2,
              ),
              Spacer(),
              tokenImage.when(
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
                loading: () => CircularProgressIndicator(),
              ),
              8.hSpacing,
              NomoText(
                tokenSymbol,
                style: context.typography.b2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
