import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/dialog/nomo_dialog.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/oldContract/pair_provider.dart';
import 'package:uniswap_liquidity/widgets/add/pair_item.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class SelectDialog extends ConsumerWidget {
  const SelectDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairs = ref.watch(pairNotifierProvider);

    return NomoDialog(
      title: "Select a pool",
      titleStyle: context.typography.b2,
      content: pairs.when(
        data: (data) {
          final hasBlancePairs = data
              .where(
                  (element) => element.balanceToken!.value != Amount.zero.value)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NomoText(
                "Token balance",
                style: context.typography.b1,
              ),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: hasBlancePairs.length,
                  itemBuilder: (context, index) {
                    final pair = hasBlancePairs[index];
                    return Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.pop(context, pair),
                        child: PairItem(pair: pair),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => NomoText(error.toString()),
        loading: () => CircularProgressIndicator(
          color: context.theme.colors.primary,
        ),
      ),
    );
  }
}
