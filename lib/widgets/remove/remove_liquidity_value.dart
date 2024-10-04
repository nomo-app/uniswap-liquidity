import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/newContract/zeniqswap_pair_provider.dart';
import 'package:uniswap_liquidity/provider/oldContract/pair_provider.dart';
import 'package:uniswap_liquidity/provider/remove_liquidity_form_hook.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_input.dart';
import 'package:uniswap_liquidity/widgets/remove/remove_price_display.dart';
import 'package:uniswap_liquidity/widgets/success_dialog.dart';

class RemoveLiquidityValue extends HookConsumerWidget {
  final Pair selectedPool;
  final ValueNotifier<double> sliderValue;
  final ValueNotifier<String> liquidityToRemove;

  const RemoveLiquidityValue({
    required this.sliderValue,
    required this.selectedPool,
    required this.liquidityToRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formStateNotifier = useRemoveLiquidityFormHook(
      sliderValue: sliderValue,
      selectedPool: selectedPool,
      liquidityToRemove: liquidityToRemove,
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
        formStateNotifier.approveError,
        formStateNotifier.removeError,
      ]),
      builder: (context, child) {
        final tokenAmount = formStateNotifier.tokenAmount.value;
        final zeniqAmount = formStateNotifier.zeniqAmount.value;
        final needsApproval = formStateNotifier.needsApproval.value;
        final liquidityState = formStateNotifier.liquidityState.value;
        final approveError = formStateNotifier.approveError.value;
        final removeError = formStateNotifier.removeError.value;
        final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
        final tokenError = formStateNotifier.tokenErrorNotifier.value;

        return Column(
          children: [
            RemoveInput(
              token: selectedPool.tokeWZeniq,
              valueNotifier: formStateNotifier.zeniqAmount,
              errorNotifier: formStateNotifier.zeniqErrorNotifier,
            ),
            12.vSpacing,
            RemoveInput(
              token: selectedPool.token,
              errorNotifier: formStateNotifier.tokenErrorNotifier,
              valueNotifier: formStateNotifier.tokenAmount,
            ),
            12.vSpacing,
            RemovePriceDisplay(
              pair: selectedPool,
            ),
            16.vSpacing,
            if (needsApproval == ApprovalState.needsApproval ||
                needsApproval == ApprovalState.loading) ...[
              PrimaryNomoButton(
                borderRadius: BorderRadius.circular(16),
                height: 52,
                expandToConstraints: true,
                textStyle: context.typography.b1,
                backgroundColor: needsApproval == ApprovalState.approved
                    ? Colors.green.lighten(0.1)
                    : null,
                enabled: needsApproval == ApprovalState.needsApproval,
                //     zeniqAmount.toString() == "0.0" &&
                //     tokenAmount.toString() == "0.0",
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
              12.vSpacing,
              if (approveError.isNotEmpty) ...[
                NomoText(
                  approveError,
                  style: context.theme.typography.b1.copyWith(
                    color: context.theme.colors.error,
                  ),
                ),
                12.vSpacing,
              ],
            ],
            if (removeError.isNotEmpty) ...[
              NomoText(
                removeError,
                style: context.theme.typography.b1.copyWith(
                  color: context.theme.colors.error,
                ),
              ),
              12.vSpacing,
            ],
            PrimaryNomoButton(
              borderRadius: BorderRadius.circular(16),
              expandToConstraints: true,
              height: 52,
              textStyle: context.typography.b2,
              text: sliderValue.value == 0 ? "Enter Value" : "Remove",
              enabled: needsApproval == ApprovalState.approved &&
                  (tokenAmount != "0.0" || tokenAmount.isEmpty) &&
                  (zeniqAmount != "0.0" || zeniqAmount.isEmpty),
              type: needsApproval != ApprovalState.approved
                  ? ActionType.disabled
                  : getActionTypeRemove(liquidityState, zeniqAmount,
                      tokenAmount, zeniqError, tokenError),
              onPressed: () async {
                final messageHex = await formStateNotifier.removeLiquidity();

                if (messageHex != null) {
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => SuccessDialog(messageHex: messageHex),
                  );
                
                  
                  
                  ref
                      .read(zeniqswapNotifierProvider.notifier)
                      .updatePosition(selectedPool);
                }
              },
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
        if ((zeniqAmount == "0.0" && tokenAmount == "0.0") ||
            (zeniqAmount.isEmpty && tokenAmount.isEmpty)) {
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
      LiquidityState liquidityState,
      String zeniqAmount,
      String tokenAmount,
      String? errorZeniq,
      String? errorToken) {
    switch (liquidityState) {
      case LiquidityState.loading:
        return ActionType.loading;
      case LiquidityState.idel:
        if ((zeniqAmount == "0.0" || tokenAmount == "0.0") ||
            (zeniqAmount.isEmpty || tokenAmount.isEmpty) ||
            errorZeniq != null ||
            errorToken != null) {
          return ActionType.disabled;
        }
        return ActionType.def;
      case LiquidityState.error:
        return ActionType.danger;
    }
  }
}
