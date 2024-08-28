import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/add_liquidity_form_hook.dart';
import 'package:uniswap_liquidity/provider/selected_pool_provider.dart';
import 'package:uniswap_liquidity/widgets/liquidity_input_field.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class AddLiquidityBox extends HookConsumerWidget {
  const AddLiquidityBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pool = ref.watch(selectedPoolProvider);

    final formStateNotifier =
        useAddLiquidityForm(zeniqBalance.displayDouble, pool!);

    return Column(
      children: [
        LiquidityInputField(
          token: pool.tokeWZeniq,
          balance: zeniqBalance,
          errorNotifier: formStateNotifier.zeniqErrorNotifier,
          valueNotifier: formStateNotifier.zeniqNotifier,
          fiatBlance: pool.fiatZeniqBalance,
        ),
        12.vSpacing,
        Icon(
          Icons.add_circle_outline_outlined,
          color: context.theme.colors.onDisabled,
          size: 32,
        ),
        12.vSpacing,
        LiquidityInputField(
          token: pool.token,
          balance: pool.balanceToken ?? Amount.zero,
          errorNotifier: formStateNotifier.tokenErrorNotifier,
          valueNotifier: formStateNotifier.tokenNotifier,
          fiatBlance: pool.fiatBlanceToken,
        ),
        32.vSpacing,
        PrimaryNomoButton(
          height: 52,
          expandToConstraints: true,
          onPressed: () {
            // formStateNotifier.addLiquidity();
          },
          text: "Add Liquidity",
          textStyle: context.typography.b2,
        ),
      ],
    );
  }
}
