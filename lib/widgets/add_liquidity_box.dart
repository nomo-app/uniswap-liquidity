import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/buttons/secondary/nomo_secondary_button.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/add_liquidity_form_hook.dart';
import 'package:uniswap_liquidity/provider/selected_pool_provider.dart';
import 'package:uniswap_liquidity/widgets/adjust_slippage_dialog.dart';
import 'package:uniswap_liquidity/widgets/liquidity_input_field.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class AddLiquidityBox extends HookConsumerWidget {
  const AddLiquidityBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPool = ref.watch(selectedPoolProvider);

    final formStateNotifier =
        useAddLiquidityForm(zeniqBalance.displayDouble, selectedPool.pair!);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SecondaryNomoButton(
            border: Border.all(
              color: context.theme.colors.onDisabled,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.all(8),
            text: "Slippage tolerance",
            onPressed: () {
              NomoNavigator.of(context).showModal(
                  builder: (context) => SlippageDialog(), context: context);
            },
          ),
        ),
        32.vSpacing,
        LiquidityInputField(
          token: selectedPool.pair!.tokeWZeniq,
          balance: zeniqBalance,
          errorNotifier: formStateNotifier.zeniqErrorNotifier,
          valueNotifier: formStateNotifier.zeniqNotifier,
          fiatBlance: selectedPool.pair!.fiatZeniqBalance,
        ),
        12.vSpacing,
        Icon(
          Icons.add_circle_outline_outlined,
          color: context.theme.colors.onDisabled,
          size: 32,
        ),
        12.vSpacing,
        LiquidityInputField(
          token: selectedPool.pair!.token,
          balance: selectedPool.pair!.balanceToken ?? Amount.zero,
          errorNotifier: formStateNotifier.tokenErrorNotifier,
          valueNotifier: formStateNotifier.tokenNotifier,
          fiatBlance: selectedPool.pair!.fiatBlanceToken,
        ),
        32.vSpacing,
        ValueListenableBuilder(
          valueListenable: formStateNotifier.canAddLiquidity,
          builder: (context, canAddLiquidity, child) {
            return PrimaryNomoButton(
              enabled: canAddLiquidity,
              type: canAddLiquidity ? ActionType.def : ActionType.disabled,
              height: 52,
              expandToConstraints: true,
              onPressed: () {
                print("Add Liquidity pressed");
                // formStateNotifier.addLiquidity();
              },
              text: "Add Liquidity",
              textStyle: context.typography.b2,
            );
          },
        ),
      ],
    );
  }
}
