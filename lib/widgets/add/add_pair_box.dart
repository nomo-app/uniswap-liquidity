import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/add_pool_form_hook.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:uniswap_liquidity/widgets/add/add_liquidity_info.dart';
import 'package:uniswap_liquidity/widgets/add/liquidity_input_field.dart';
import 'package:uniswap_liquidity/widgets/success_dialog.dart';

class AddPairBox extends HookConsumerWidget {
  final Pair selectedPool;
  const AddPairBox({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formStateNotifier =
        useAddPairFormHook(zeniqBalance.displayDouble, selectedPool);
    final slippage = useState("0.5");
    final liquidityProvider = ref.watch(liquidityNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LiquidityInputField(
          token: selectedPool.tokeWZeniq,
          balance: zeniqBalance,
          errorNotifier: formStateNotifier.zeniqErrorNotifier,
          valueNotifier: formStateNotifier.zeniqNotifier,
          fiatBlance: null,
        ),
        12.vSpacing,
        Icon(
          Icons.add_circle_outline_outlined,
          color: context.theme.colors.onDisabled,
          size: 24,
        ),
        LiquidityInputField(
          token: selectedPool.token,
          balance: selectedPool.balanceToken,
          errorNotifier: formStateNotifier.tokenErrorNotifier,
          valueNotifier: formStateNotifier.tokenNotifier,
          fiatBlance: null,
        ),
        12.vSpacing,
        ValueListenableBuilder(
          valueListenable: formStateNotifier.informationPair,
          builder: (context, value, child) {
            return ADDLiqiuidityInfo(
              pair: value,
              shareOfPool: "100%",
            );
          },
        ),
        12.vSpacing,
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.zeniqApprovalState,
            formStateNotifier.zeniqErrorNotifier,
            formStateNotifier.tokenErrorNotifier,
            formStateNotifier.showButtons,
          ]),
          builder: (context, child) {
            final zeniqApprovalState =
                formStateNotifier.zeniqApprovalState.value;
            final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
            final tokenError = formStateNotifier.tokenErrorNotifier.value;
            final showButtons = formStateNotifier.showButtons.value;

            final showZeniqApproveButton =
                zeniqApprovalState == ApprovalState.needsApproval &&
                    zeniqApprovalState != ApprovalState.approved &&
                    tokenError == null &&
                    zeniqError == null &&
                    showButtons;
            if (showZeniqApproveButton ||
                zeniqApprovalState == ApprovalState.loading) {
              return Column(
                children: [
                  PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    enabled: zeniqApprovalState != ApprovalState.loading,
                    expandToConstraints: true,
                    height: 52,
                    type: zeniqApprovalState == ApprovalState.loading
                        ? ActionType.loading
                        : ActionType.def,
                    text: "Approve ${selectedPool.tokeWZeniq.symbol}",
                    textStyle: context.typography.b2,
                    onPressed: () async {
                      await formStateNotifier.approveToken(
                        selectedPool.tokeWZeniq,
                        maxUint256,
                      );
                    },
                  ),
                  12.vSpacing,
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.tokenApprovalState,
            formStateNotifier.zeniqErrorNotifier,
            formStateNotifier.tokenErrorNotifier,
            formStateNotifier.showButtons,
          ]),
          builder: (context, child) {
            final tokenApprovalState =
                formStateNotifier.tokenApprovalState.value;
            final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
            final tokenError = formStateNotifier.tokenErrorNotifier.value;
            final showButtons = formStateNotifier.showButtons.value;

            final showTokenApproveButton =
                tokenApprovalState == ApprovalState.needsApproval &&
                    tokenApprovalState != ApprovalState.approved &&
                    tokenError == null &&
                    zeniqError == null &&
                    showButtons;

            if (showTokenApproveButton ||
                tokenApprovalState == ApprovalState.loading) {
              return Column(
                children: [
                  PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    enabled: tokenApprovalState != ApprovalState.loading,
                    expandToConstraints: true,
                    height: 52,
                    type: tokenApprovalState == ApprovalState.loading
                        ? ActionType.loading
                        : ActionType.def,
                    text: "Approve ${selectedPool.token.symbol}",
                    textStyle: context.typography.b2,
                    onPressed: () async {
                      await formStateNotifier.approveToken(
                        selectedPool.token,
                        maxUint256,
                      );
                    },
                  ),
                  12.vSpacing,
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.canAddLiquidity,
            formStateNotifier.zeniqNotifier,
            formStateNotifier.tokenNotifier,
          ]),
          builder: (context, child) {
            final canAddLiquidity = formStateNotifier.canAddLiquidity.value;
            final zeniqInput = formStateNotifier.zeniqNotifier.value;
            final tokenInput = formStateNotifier.tokenNotifier.value;

            return Column(
              children: [
                PrimaryNomoButton(
                  enabled: canAddLiquidity &&
                      (liquidityProvider != LiquidityState.loading),
                  type: canAddLiquidity &&
                          (liquidityProvider == LiquidityState.idel)
                      ? ActionType.def
                      : liquidityProvider == LiquidityState.loading
                          ? ActionType.loading
                          : ActionType.disabled,
                  height: 52,
                  expandToConstraints: true,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () async {
                    final liquidity = Liquidity(
                      pair: selectedPool,
                      slippage: slippage.value,
                      zeniqValue: formStateNotifier.zeniqNotifier.value,
                      tokenValue: formStateNotifier.tokenNotifier.value,
                    );
                    final txHash = await ref
                        .read(liquidityNotifierProvider.notifier)
                        .addLiquidity(liquidity, false);
                    if (txHash != null) {
                      print("Liquidity added: $txHash");
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) {
                          return SuccessDialog(
                            messageHex: txHash,
                          );
                        },
                      );
                    }
                  },
                  text: zeniqInput == "" || tokenInput == ""
                      ? "Enter Amount"
                      : "Supply",
                  textStyle: context.typography.b2,
                ),
                if (liquidityProvider == LiquidityState.error) ...[
                  16.vSpacing,
                  NomoText("Error adding liquidity",
                      color: Colors.red, style: context.typography.b1),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
