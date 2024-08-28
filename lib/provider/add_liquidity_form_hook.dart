import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'dart:math';

class AddLiquidityFormController {
  final ValueNotifier<String> zeniqNotifier;
  final ValueNotifier<String> tokenNotifier;
  final ValueNotifier<String?> zeniqErrorNotifier;
  final ValueNotifier<String?> tokenErrorNotifier;
  final BigInt reserveA;
  final BigInt reserveB;
  final int zeniqDecimals;
  final int tokenDecimals;
  final double zeniqBalance;
  final double tokenBalance;

  AddLiquidityFormController(this.zeniqBalance, this.tokenBalance,
      this.reserveA, this.reserveB, this.zeniqDecimals, this.tokenDecimals)
      : zeniqNotifier = ValueNotifier(""),
        tokenNotifier = ValueNotifier(""),
        zeniqErrorNotifier = ValueNotifier(null),
        tokenErrorNotifier = ValueNotifier(null) {
    zeniqNotifier.addListener(_calculateTokenFromZeniq);
    tokenNotifier.addListener(_calculateZeniqFromToken);
  }

  void _calculateTokenFromZeniq() {
    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? 0;
    final zeniqInputBigInt =
        BigInt.from((zeniqInput * pow(10, zeniqDecimals)).floor());
    if (zeniqInputBigInt > BigInt.zero && reserveA > BigInt.zero) {
      final calculatedTokenBigInt = (zeniqInputBigInt * reserveB) ~/ reserveA;
      final calculatedToken =
          calculatedTokenBigInt.toDouble() / pow(10, tokenDecimals);
      tokenNotifier.removeListener(_calculateZeniqFromToken);
      tokenNotifier.value = calculatedToken.toStringAsFixed(tokenDecimals);
      tokenNotifier.addListener(_calculateZeniqFromToken);
    }
    _validateInputs();
  }

  void _calculateZeniqFromToken() {
    final tokenInput = double.tryParse(tokenNotifier.value) ?? 0;
    final tokenInputBigInt =
        BigInt.from((tokenInput * pow(10, tokenDecimals)).floor());
    if (tokenInputBigInt > BigInt.zero && reserveB > BigInt.zero) {
      final calculatedZeniqBigInt = (tokenInputBigInt * reserveA) ~/ reserveB;
      final calculatedZeniq =
          calculatedZeniqBigInt.toDouble() / pow(10, zeniqDecimals);
      zeniqNotifier.removeListener(_calculateTokenFromZeniq);
      zeniqNotifier.value = calculatedZeniq.toStringAsFixed(zeniqDecimals);
      zeniqNotifier.addListener(_calculateTokenFromZeniq);
    }
    _validateInputs();
  }

  void _validateInputs() {
    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? 0;
    final tokenInput = double.tryParse(tokenNotifier.value) ?? 0;

    zeniqErrorNotifier.value =
        (zeniqInput > zeniqBalance) ? "Insufficient balance" : null;
    tokenErrorNotifier.value =
        (tokenInput > tokenBalance) ? "Insufficient balance" : null;
  }
}

AddLiquidityFormController useAddLiquidityForm(double zeniqBalance, Pair pool) {
  final controller = useState<AddLiquidityFormController?>(null);

  useEffect(() {
    controller.value = AddLiquidityFormController(
        zeniqBalance,
        pool.balanceToken!.displayDouble,
        pool.reserves.$1,
        pool.reserves.$2,
        pool.tokeWZeniq.decimals,
        pool.token.decimals);
    return null;
  }, [zeniqBalance, pool]);

  return controller.value!;
}
