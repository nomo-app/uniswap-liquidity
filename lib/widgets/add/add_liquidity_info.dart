import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/widgets/dotted_line.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class ADDLiqiuidityInfo extends HookConsumerWidget {
  final Pair pair;
  final String shareOfPool;

  const ADDLiqiuidityInfo(
      {required this.pair, required this.shareOfPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency =
        useState(ref.watch(assetNotifierProvider).currencyNotifier.value);

    return NomoCard(
      borderRadius: BorderRadius.circular(
        24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: NomoText(
              "Prices and pool share",
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
              borderRadius: BorderRadius.circular(24),
              backgroundColor: context.theme.colors.background2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UnitDisplay(
                    token: pair.token,
                    zeniq: pair.tokeWZeniq,
                    isOther: true,
                    value: pair.tokenPerZeniq
                        .toMaxPrecisionWithoutScientificNotation(5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NomoText(
                        "${pair.token.symbol} price",
                        style: context.theme.typography.b1,
                      ),
                      8.hSpacing,
                      DottedLine(),
                      8.hSpacing,
                      NomoText(
                        "${pair.tokenPrice.formatDouble(2)} ${currency.value.symbol}",
                        style: context.theme.typography.b1,
                      ),
                    ],
                  ),
                  UnitDisplay(
                    value: pair.zeniqPerToken
                        .toMaxPrecisionWithoutScientificNotation(5),
                    token: pair.token,
                    zeniq: pair.tokeWZeniq,
                    isOther: false,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NomoText(
                        "ZENIQ price",
                        style: context.theme.typography.b1,
                      ),
                      8.hSpacing,
                      DottedLine(),
                      8.hSpacing,
                      NomoText(
                        "${pair.zeniqPrice.formatDouble(2)} ${currency.value.symbol}",
                        style: context.theme.typography.b1,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NomoText(
                        "Pool share",
                        style: context.theme.typography.b1,
                      ),
                      8.hSpacing,
                      DottedLine(),
                      8.hSpacing,
                      NomoText(
                        shareOfPool.isEmpty ? "0%" : shareOfPool,
                        style: context.theme.typography.b1,
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class UnitDisplay extends ConsumerWidget {
  final EthBasedTokenEntity token;
  final EthBasedTokenEntity zeniq;
  final bool isOther;
  final String value;

  const UnitDisplay({
    required this.token,
    required this.zeniq,
    required this.isOther,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NomoText(
          isOther ? "${token.symbol} per ZENIQ" : "ZENIQ per ${token.symbol}",
          style: context.theme.typography.b1,
        ),
        8.hSpacing,
        DottedLine(),
        8.hSpacing,
        NomoText(
          value,
          style: context.theme.typography.b1,
        ),
      ],
    );
  }
}
