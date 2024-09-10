import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/provider/remove_liquidity_form_hook.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_price_display.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_token_display.dart';

class RemoveLiquidityValue extends HookConsumerWidget {
  final Pair selectedPool;
  final ValueNotifier<double> sliderValue;

  const RemoveLiquidityValue({
    required this.sliderValue,
    required this.selectedPool,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formStateNotifier = useRemoveLiquidityFormHook(
      sliderValue: sliderValue,
      selectedPool: selectedPool,
      position: selectedPool.position!,
    );
    final imageZeniq = ref
        .watch(assetNotifierProvider)
        .imageNotifierForToken(selectedPool.tokeWZeniq)!;
    final imageToken = ref
        .watch(assetNotifierProvider)
        .imageNotifierForToken(selectedPool.token)!;
    return ListenableBuilder(
      listenable: Listenable.merge([
        imageToken,
        imageZeniq,
        formStateNotifier.tokenAmount,
        formStateNotifier.zeniqAmount,
        formStateNotifier.needsApproval,
        formStateNotifier.liquidityState,
      ]),
      builder: (context, child) {
        final tokenImage = imageToken.value;
        final zeniqImage = imageZeniq.value;
        final tokenAmount = formStateNotifier.tokenAmount.value;
        final zeniqAmount = formStateNotifier.zeniqAmount.value;
        final needsApproval = formStateNotifier.needsApproval.value;
        final liquidityState = formStateNotifier.liquidityState.value;
        final roundedTokenAmount = double.parse(tokenAmount)
            .toMaxPrecisionWithoutScientificNotation(6);
        final roundedZeniqAmount = double.parse(zeniqAmount)
            .toMaxPrecisionWithoutScientificNotation(6);

        return Column(
          children: [
            RemoveTokenDisplay(
              tokenAmount: roundedTokenAmount,
              zeniqAmount: roundedZeniqAmount,
              tokenImage: tokenImage,
              zeniqImage: zeniqImage,
              tokenSymbol: selectedPool.token.symbol,
            ),
            12.vSpacing,
            RemovePriceDisplay(
              pair: selectedPool,
            ),
            16.vSpacing,
            Row(
              children: [
                Expanded(
                  child: PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    height: 52,
                    expandToConstraints: true,
                    textStyle: context.typography.b1,
                    backgroundColor: needsApproval == ApprovalState.approved
                        ? Colors.green.lighten(0.1)
                        : null,
                    enabled: needsApproval == ApprovalState.needsApproval &&
                        zeniqAmount.toString() == "0.0" &&
                        tokenAmount.toString() == "0.0",
                    type: getActionTypeApprove(
                        needsApproval, zeniqAmount, tokenAmount),
                    text: needsApproval == ApprovalState.approved
                        ? "Approved"
                        : "Approve",
                    onPressed: () async {
                      print("approved pressed");
                      await formStateNotifier.approveLiquidityValue();
                    },
                  ),
                ),
                12.hSpacing,
                Expanded(
                  child: PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    expandToConstraints: true,
                    height: 52,
                    textStyle: context.typography.b1,
                    text: sliderValue.value == 0 ? "Enter Value" : "Remove",
                    enabled: needsApproval == ApprovalState.approved &&
                        tokenAmount != "0.0" &&
                        zeniqAmount != "0.0",
                    type: needsApproval != ApprovalState.approved
                        ? ActionType.disabled
                        : getActionTypeRemove(
                            liquidityState, zeniqAmount, tokenAmount),
                    onPressed: () async {
                      await formStateNotifier.removeLiquidity();
                      ref
                          .read(pairNotifierProvider.notifier)
                          .updatePosition(selectedPool);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  ActionType getActionTypeApprove(
      ApprovalState approvalState, String zeniqAmount, String tokenAmount) {
    switch (approvalState) {
      case ApprovalState.needsApproval:
        if (zeniqAmount == "0.0" && tokenAmount == "0.0") {
          return ActionType.disabled;
        }
        return ActionType.def;
      case ApprovalState.approved:
        return ActionType.def;
      case ApprovalState.loading:
        return ActionType.loading;
      case ApprovalState.idel:
        return ActionType.disabled;
      case ApprovalState.error:
        return ActionType.danger;
    }
  }

  ActionType getActionTypeRemove(
      LiquidityState liquidityState, String zeniqAmount, String tokenAmount) {
    switch (liquidityState) {
      case LiquidityState.loading:
        return ActionType.loading;
      case LiquidityState.idel:
        if (zeniqAmount == "0.0" && tokenAmount == "0.0") {
          return ActionType.disabled;
        }
        return ActionType.def;
      case LiquidityState.error:
        return ActionType.danger;
    }
  }
}
