import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/add_liquidity_form_hook.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/widgets/add/add_liquidity_info.dart';
import 'package:uniswap_liquidity/widgets/add/liquidity_input_field.dart';
import 'package:uniswap_liquidity/widgets/position_box.dart';
import 'package:uniswap_liquidity/widgets/success_dialog.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class AddLiquidityBox extends HookConsumerWidget {
  final Pair selectedPool;
  const AddLiquidityBox({required this.selectedPool, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formStateNotifier =
        useAddLiquidityForm(zeniqBalance.displayDouble, selectedPool);
    final slippage = useState("0.5");
    final liquidityProvider = ref.watch(liquidityNotifierProvider);

    final zeniqHasValue = useState(false);

    formStateNotifier.zeniqNotifier.addListener(() {
      zeniqHasValue.value = formStateNotifier.zeniqNotifier.value.isNotEmpty &&
          double.tryParse(formStateNotifier.zeniqNotifier.value) != 0;
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedPool.position != null) ...[
          PositionBox(pair: selectedPool),
          12.vSpacing,
        ],
        LiquidityInputField(
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
          token: selectedPool.token,
          balance: selectedPool.balanceToken ?? Amount.zero,
          errorNotifier: formStateNotifier.tokenErrorNotifier,
          valueNotifier: formStateNotifier.tokenNotifier,
          fiatBlance: selectedPool.fiatBlanceToken,
        ),
        12.vSpacing,
        ValueListenableBuilder(
          valueListenable: formStateNotifier.shareOfPool,
          builder: (context, shareOfPool, child) {
            return ADDLiqiuidityInfo(
              pair: selectedPool,
              shareOfPool: shareOfPool,
            );
          },
        ),
        12.vSpacing,
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.zeniqNeedsApproval,
            formStateNotifier.zeniqErrorNotifier,
            formStateNotifier.tokenErrorNotifier,
            formStateNotifier.tokenNeedsApproval,
          ]),
          builder: (context, child) {
            final needsApproval = formStateNotifier.zeniqNeedsApproval.value;
            final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
            final tokenError = formStateNotifier.tokenErrorNotifier.value;
            final tokenApproval = formStateNotifier.tokenNeedsApproval.value;

            final showButton = needsApproval == ApprovalState.needsApproval &&
                needsApproval != ApprovalState.approved &&
                zeniqError == null &&
                tokenError == null &&
                zeniqHasValue.value;

            if (showButton || needsApproval == ApprovalState.loading) {
              return Column(
                children: [
                  PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    enabled: needsApproval != ApprovalState.loading &&
                        tokenApproval != ApprovalState.loading,
                    expandToConstraints: true,
                    height: 52,
                    type: needsApproval == ApprovalState.loading
                        ? ActionType.loading
                        : ActionType.def,
                    text: "Approve ${selectedPool.tokeWZeniq.symbol}",
                    textStyle: context.typography.b2,
                    onPressed: () async {
                      Amount tokenAmount = Amount.convert(
                        value: double.tryParse(
                                formStateNotifier.tokenNotifier.value) ??
                            0,
                        decimals: selectedPool.token.decimals,
                      );
                      await formStateNotifier.approveToken(
                        selectedPool.tokeWZeniq,
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
            formStateNotifier.tokenNeedsApproval,
            formStateNotifier.zeniqNeedsApproval,
            formStateNotifier.zeniqErrorNotifier,
            formStateNotifier.tokenErrorNotifier,
          ]),
          builder: (context, child) {
            final needsApproval = formStateNotifier.tokenNeedsApproval.value;
            final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
            final tokenError = formStateNotifier.tokenErrorNotifier.value;
            final zeniqNeedsApproval =
                formStateNotifier.zeniqNeedsApproval.value;

            final showButton = needsApproval == ApprovalState.needsApproval &&
                needsApproval != ApprovalState.approved &&
                zeniqError == null &&
                tokenError == null &&
                zeniqHasValue.value;

            if (showButton || needsApproval == ApprovalState.loading) {
              return Column(
                children: [
                  PrimaryNomoButton(
                    borderRadius: BorderRadius.circular(16),
                    enabled: needsApproval != ApprovalState.loading &&
                        zeniqNeedsApproval != ApprovalState.loading,
                    expandToConstraints: true,
                    height: 52,
                    type: needsApproval == ApprovalState.loading
                        ? ActionType.loading
                        : ActionType.def,
                    text: "Approve ${selectedPool.token.symbol}",
                    textStyle: context.typography.b2,
                    onPressed: () async {
                      Amount tokenAmount = Amount.convert(
                        value: double.tryParse(
                                formStateNotifier.tokenNotifier.value) ??
                            0,
                        decimals: selectedPool.token.decimals,
                      );
                      await formStateNotifier.approveToken(
                        selectedPool.token,
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
            formStateNotifier.tokenNeedsApproval,
            formStateNotifier.zeniqNeedsApproval,
          ]),
          builder: (context, child) {
            final tokenApproval = formStateNotifier.tokenNeedsApproval.value;
            final zeniqApproval = formStateNotifier.zeniqNeedsApproval.value;
            final canAddLiquidity = formStateNotifier.canAddLiquidity.value;

            final enabeld = canAddLiquidity &&
                (liquidityProvider != LiquidityState.loading) &&
                tokenApproval == ApprovalState.approved &&
                zeniqApproval == ApprovalState.approved;

            return Column(
              children: [
                PrimaryNomoButton(
                  enabled: enabeld,
                  type: enabeld && (liquidityProvider == LiquidityState.idel)
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
                        .addLiquidity(liquidity, null);
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
