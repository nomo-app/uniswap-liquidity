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
import 'package:uniswap_liquidity/widgets/add/liquidity_input_field.dart';
import 'package:uniswap_liquidity/widgets/success_dialog.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class AddPairBox extends HookConsumerWidget {
  final Pair selectedPool;
  const AddPairBox({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formStateNotifier =
        useAddPairFormHook(zeniqBalance.displayDouble, selectedPool);
    final slippage = useState("0.5");
    final liquidityProvider = ref.watch(liquidityNotifierProvider);

    final zeniqHasValue = useState(false);

    useEffect(() {
      void listener() {
        zeniqHasValue.value =
            formStateNotifier.zeniqNotifier.value.isNotEmpty &&
                double.tryParse(formStateNotifier.zeniqNotifier.value) != 0;
      }

      formStateNotifier.zeniqNotifier.addListener(listener);
      return () => formStateNotifier.zeniqNotifier.removeListener(listener);
    }, [formStateNotifier]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LiquidityInputField(
          isZeniq: true,
          token: selectedPool.tokeWZeniq,
          balance: zeniqBalance,
          errorNotifier: formStateNotifier.zeniqErrorNotifier,
          valueNotifier: formStateNotifier.zeniqNotifier,
          fiatBlance: selectedPool.fiatZeniqBalance,
        ),
        12.vSpacing,
        Icon(
          Icons.add_circle_outline_outlined,
          color: context.theme.colors.onDisabled,
          size: 24,
        ),
        12.vSpacing,
        LiquidityInputField(
          isZeniq: false,
          token: selectedPool.token,
          balance: selectedPool.balanceToken ?? Amount.zero,
          errorNotifier: formStateNotifier.tokenErrorNotifier,
          valueNotifier: formStateNotifier.tokenNotifier,
          fiatBlance: selectedPool.fiatBlanceToken,
        ),
        12.vSpacing,
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.wzeniqApprovalState,
            formStateNotifier.zeniqErrorNotifier,
            formStateNotifier.zeniqNotifier,
          ]),
          builder: (context, child) {
            final wzeniqApprovalState =
                formStateNotifier.wzeniqApprovalState.value;
            final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
            final zeniqValue = formStateNotifier.zeniqNotifier.value;

            final showButton =
                wzeniqApprovalState == ApprovalState.needsApproval &&
                    zeniqError == null &&
                    zeniqValue.isNotEmpty &&
                    double.tryParse(zeniqValue) != 0;

            if (showButton || wzeniqApprovalState == ApprovalState.loading) {
              return Column(
                children: [
                  PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    enabled: wzeniqApprovalState != ApprovalState.loading,
                    expandToConstraints: true,
                    height: 52,
                    type: wzeniqApprovalState == ApprovalState.loading
                        ? ActionType.loading
                        : ActionType.def,
                    text: "Approve ZENIQ",
                    textStyle: context.typography.b2,
                    onPressed: () async {
                      Amount zeniqAmount = Amount.convert(
                        value: double.tryParse(zeniqValue) ?? 0,
                        decimals: selectedPool.tokeWZeniq.decimals,
                      );
                      await formStateNotifier.approveToken(
                        selectedPool.tokeWZeniq.contractAddress,
                        zeniqAmount.value,
                      );
                    },
                  ),
                  12.vSpacing,
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.tokenApprovalState,
            formStateNotifier.tokenErrorNotifier,
            formStateNotifier.tokenNotifier,
          ]),
          builder: (context, child) {
            final tokenApprovalState =
                formStateNotifier.tokenApprovalState.value;
            final tokenError = formStateNotifier.tokenErrorNotifier.value;
            final tokenValue = formStateNotifier.tokenNotifier.value;

            final showButton =
                tokenApprovalState == ApprovalState.needsApproval &&
                    tokenError == null &&
                    tokenValue.isNotEmpty &&
                    double.tryParse(tokenValue) != 0;

            if (showButton || tokenApprovalState == ApprovalState.loading) {
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
                      Amount tokenAmount = Amount.convert(
                        value: double.tryParse(tokenValue) ?? 0,
                        decimals: selectedPool.token.decimals,
                      );
                      await formStateNotifier.approveToken(
                        selectedPool.token.contractAddress,
                        tokenAmount.value,
                      );
                    },
                  ),
                  12.vSpacing,
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.canAddLiquidity,
            formStateNotifier.wzeniqApprovalState,
            formStateNotifier.tokenApprovalState,
          ]),
          builder: (context, child) {
            final canAddLiquidity = formStateNotifier.canAddLiquidity.value;
            final wzeniqApproved =
                formStateNotifier.wzeniqApprovalState.value ==
                    ApprovalState.approved;
            final tokenApproved = formStateNotifier.tokenApprovalState.value ==
                ApprovalState.approved;
            final bothApproved = wzeniqApproved && tokenApproved;

            return Column(
              children: [
                PrimaryNomoButton(
                  enabled: (canAddLiquidity || bothApproved) &&
                      (liquidityProvider != LiquidityState.loading),
                  type: (canAddLiquidity || bothApproved) &&
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
                        .addLiquidity(liquidity);
                    if (txHash != null) {
                      print("Liquidity added: $txHash");
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SuccessDialog(
                            messageHex: txHash,
                          );
                        },
                      );
                    }
                  },
                  text:
                      zeniqHasValue.value == false ? "Enter Amount" : "Supply",
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
