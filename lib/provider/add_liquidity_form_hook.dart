import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'dart:math';

enum LiquidityInputFieldError {
  insufficientBalance("Insufficient balance");

  final String displayName;

  const LiquidityInputFieldError(this.displayName);

  @override
  String toString() => name;
}

class AddLiquidityFormController {
  final ValueNotifier<String> zeniqNotifier;
  final ValueNotifier<String> tokenNotifier;
  final ValueNotifier<String?> zeniqErrorNotifier;
  final ValueNotifier<String?> tokenErrorNotifier;
  final ValueNotifier<bool> canAddLiquidity;
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
        canAddLiquidity = ValueNotifier(false),
        zeniqErrorNotifier = ValueNotifier(null),
        tokenErrorNotifier = ValueNotifier(null) {
    zeniqNotifier.addListener(_calculateTokenFromZeniq);
    tokenNotifier.addListener(_calculateZeniqFromToken);
  }

  void _calculateTokenFromZeniq() {
    final zeniqInput = zeniqNotifier.value;

    if (zeniqInput.isEmpty) {
      tokenNotifier.removeListener(_calculateZeniqFromToken);
      tokenNotifier.value = "";
      tokenNotifier.addListener(_calculateZeniqFromToken);
      _validateInputs();
      return;
    }

    final zeniqInputDouble = double.tryParse(zeniqInput) ?? 0;
    final zeniqInputBigInt =
        BigInt.from((zeniqInputDouble * pow(10, zeniqDecimals)).floor());

    if (zeniqInputBigInt > BigInt.zero && reserveA > BigInt.zero) {
      final calculatedTokenBigInt = (zeniqInputBigInt * reserveB) ~/ reserveA;
      final calculatedToken =
          calculatedTokenBigInt.toDouble() / pow(10, tokenDecimals);
      tokenNotifier.removeListener(_calculateZeniqFromToken);
      tokenNotifier.value = calculatedToken.toStringAsFixed(7);
      tokenNotifier.addListener(_calculateZeniqFromToken);
    } else {
      tokenNotifier.removeListener(_calculateZeniqFromToken);
      tokenNotifier.value = "";
      tokenNotifier.addListener(_calculateZeniqFromToken);
    }

    _validateInputs();
  }

  void _calculateZeniqFromToken() {
    final tokenInput = tokenNotifier.value;

    if (tokenInput.isEmpty) {
      zeniqNotifier.removeListener(_calculateTokenFromZeniq);
      zeniqNotifier.value = "";
      zeniqNotifier.addListener(_calculateTokenFromZeniq);
      _validateInputs();
      return;
    }

    final tokenInputDouble = double.tryParse(tokenInput) ?? 0;
    final tokenInputBigInt =
        BigInt.from((tokenInputDouble * pow(10, tokenDecimals)).floor());

    if (tokenInputBigInt > BigInt.zero && reserveB > BigInt.zero) {
      final calculatedZeniqBigInt = (tokenInputBigInt * reserveA) ~/ reserveB;
      final calculatedZeniq =
          calculatedZeniqBigInt.toDouble() / pow(10, zeniqDecimals);
      zeniqNotifier.removeListener(_calculateTokenFromZeniq);
      zeniqNotifier.value = calculatedZeniq.toStringAsFixed(7);
      zeniqNotifier.addListener(_calculateTokenFromZeniq);
    } else {
      zeniqNotifier.removeListener(_calculateTokenFromZeniq);
      zeniqNotifier.value = "";
      zeniqNotifier.addListener(_calculateTokenFromZeniq);
    }

    _validateInputs();
  }

  void _validateInputs() {
    bool isValid = true;

    if (zeniqNotifier.value.isEmpty || tokenNotifier.value.isEmpty) {
      isValid = false;
    }

    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? 0;
    final tokenInput = double.tryParse(tokenNotifier.value) ?? 0;

    if (zeniqInput > zeniqBalance) {
      zeniqErrorNotifier.value =
          LiquidityInputFieldError.insufficientBalance.displayName;
      isValid = false;
    } else {
      zeniqErrorNotifier.value = null;
    }

    if (tokenInput > tokenBalance) {
      tokenErrorNotifier.value =
          LiquidityInputFieldError.insufficientBalance.displayName;
      isValid = false;
    } else {
      tokenErrorNotifier.value = null;
    }

    canAddLiquidity.value = isValid;
  }
}

AddLiquidityFormController useAddLiquidityForm(double zeniqBalance, Pair pool) {
  final controller = useState<AddLiquidityFormController?>(null);

  useEffect(() {
    controller.value = AddLiquidityFormController(
        zeniqBalance,
        pool.balanceToken?.displayDouble ?? 0,
        pool.reserves.$1,
        pool.reserves.$2,
        pool.tokeWZeniq.decimals,
        pool.token.decimals);
    return null;
  }, [zeniqBalance, pool]);

  return controller.value!;
}
