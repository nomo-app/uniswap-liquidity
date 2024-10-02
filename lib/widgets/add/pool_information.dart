import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/widgets/pool_view.dart';

class PoolInfromation extends ConsumerWidget {
  final Pair pair;
  const PoolInfromation({required this.pair, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyNotifier = ref.watch(assetNotifierProvider).currencyNotifier;

    return ListenableBuilder(
      listenable: currencyNotifier,
      builder: (context, child) {
        final currency = currencyNotifier.value;

        return NomoCard(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: NomoText(
                  "Pool Information",
                  style: context.theme.typography.b1,
                ),
              ),
              8.vSpacing,
              NomoCard(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                backgroundColor: context.theme.colors.background2,
                borderRadius: BorderRadius.circular(24),
                child: PoolView(
                    pair: pair, currency: currency, initialyExpanded: true),
              ),
            ],
          ),
        );
      },
    );
  }
}
