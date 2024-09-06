import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/provider/position_provider.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';

class PositionBox extends ConsumerWidget {
  final Pair pair;
  const PositionBox({required this.pair, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionNotifierProvider);
    return position.when(
      data: (data) {
        final position = data.firstWhere((element) =>
            element.pair.token.contractAddress == pair.token.contractAddress);

        return NomoCard(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: NomoText(
                  "Your position",
                  style: context.theme.typography.b1,
                ),
              ),
              8.vSpacing,
              NomoCard(
                padding: EdgeInsets.all(16),
                backgroundColor: context.theme.colors.background2,
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NomoText(
                          "WZENIQ/${position.pair.token.symbol}",
                          style: context.theme.typography.b1,
                        ),
                        NomoText(
                          position.liquidity.displayDouble
                              .toMaxPrecisionWithoutScientificNotation(5),
                          style: context.theme.typography.b1,
                        ),
                      ],
                    ),
                    8.vSpacing,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NomoText("WZENIQ", style: context.theme.typography.b1),
                        NomoText(
                          position.zeniqValue.displayDouble
                              .toMaxPrecisionWithoutScientificNotation(5),
                          style: context.theme.typography.b1,
                        ),
                      ],
                    ),
                    8.vSpacing,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NomoText(
                          position.pair.token.symbol,
                          style: context.theme.typography.b1,
                        ),
                        NomoText(
                          position.tokenValue.displayDouble
                              .toMaxPrecisionWithoutScientificNotation(5),
                          style: context.theme.typography.b1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => CircularProgressIndicator(),
    );
  }
}
