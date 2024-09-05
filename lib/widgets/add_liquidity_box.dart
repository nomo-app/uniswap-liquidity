import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/dialog/nomo_dialog.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/add_liquidity_form_hook.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/widgets/add_liquidity_info.dart';
import 'package:uniswap_liquidity/widgets/liquidity_input_field.dart';
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
      children: [
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: SecondaryNomoButton(
        //     border: Border.all(
        //       color: context.theme.colors.onDisabled,
        //       width: 1,
        //     ),
        //     borderRadius: BorderRadius.circular(8),
        //     backgroundColor: Colors.transparent,
        //     padding: EdgeInsets.all(8),
        //     text: "Slippage tolerance",
        //     onPressed: () {
        //       NomoNavigator.of(context).showModal(
        //           builder: (context) => SlippageDialog(
        //               pair: selectedPool, slippageNotifier: slippage),
        //           context: context);
        //     },
        //   ),
        // ),
        // 32.vSpacing,
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
          size: 32,
        ),
        12.vSpacing,
        LiquidityInputField(
          token: selectedPool.token,
          balance: selectedPool.balanceToken ?? Amount.zero,
          errorNotifier: formStateNotifier.tokenErrorNotifier,
          valueNotifier: formStateNotifier.tokenNotifier,
          fiatBlance: selectedPool.fiatBlanceToken,
        ),
        32.vSpacing,
        ListenableBuilder(
          listenable: Listenable.merge([
            formStateNotifier.needsApproval,
            formStateNotifier.zeniqErrorNotifier,
            formStateNotifier.tokenErrorNotifier,
          ]),
          builder: (context, child) {
            final needsApproval = formStateNotifier.needsApproval.value;
            final zeniqError = formStateNotifier.zeniqErrorNotifier.value;
            final tokenError = formStateNotifier.tokenErrorNotifier.value;

            final showButton = needsApproval == ApprovalState.needsApproval &&
                needsApproval != ApprovalState.approved &&
                zeniqError == null &&
                tokenError == null &&
                zeniqHasValue.value;

            if (showButton || needsApproval == ApprovalState.loading) {
              return Column(
                children: [
                  PrimaryNomoButton(
                    enabled: needsApproval != ApprovalState.loading,
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
                        selectedPool.token.contractAddress,
                        tokenAmount.value,
                      );
                    },
                  ),
                  32.vSpacing,
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),

        ValueListenableBuilder(
          valueListenable: formStateNotifier.canAddLiquidity,
          builder: (context, canAddLiquidity, child) {
            return Column(
              children: [
                if (canAddLiquidity) ...[
                  ADDLiqiuidityInfo(
                      pair: selectedPool, slippage: slippage.value),
                  32.vSpacing,
                ],
                PrimaryNomoButton(
                  enabled: canAddLiquidity &&
                      (liquidityProvider != LiquidityState.loading ||
                          liquidityProvider != LiquidityState.error),
                  type: canAddLiquidity &&
                          (liquidityProvider == LiquidityState.idel)
                      ? ActionType.def
                      : liquidityProvider == LiquidityState.loading
                          ? ActionType.loading
                          : ActionType.disabled,
                  height: 52,
                  expandToConstraints: true,
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
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) {
                          return NomoDialog(
                            title: "Liquidity added",
                            content: Column(
                              children: [
                                NomoText("Liquidity added successfully",
                                    style: context.typography.b3),
                                16.vSpacing,
                                NomoText("Transaction hash: $txHash",
                                    style: context.typography.b3),
                              ],
                            ),
                            actions: [
                              PrimaryNomoButton(
                                expandToConstraints: true,
                                height: 52,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
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
                      color: Colors.red, style: context.typography.b3),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
