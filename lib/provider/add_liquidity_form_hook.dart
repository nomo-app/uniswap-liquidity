import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddLiquidityFormState {
  final String zeniq;
  final String token;
  final String? zeniqError;
  final String? tokenError;

  AddLiquidityFormState({
    required this.zeniq,
    required this.token,
    this.zeniqError,
    this.tokenError,
  });

  AddLiquidityFormState copyWith({
    String? zeniq,
    String? token,
    String? zeniqError,
    String? tokenError,
  }) {
    return AddLiquidityFormState(
      zeniq: zeniq ?? this.zeniq,
      token: token ?? this.token,
      zeniqError: zeniqError ?? this.zeniqError,
      tokenError: tokenError ?? this.tokenError,
    );
  }
}

class AddLiquidityFormController {
  final ValueNotifier<String> zeniqNotifier;
  final ValueNotifier<String> tokenNotifier;
  final ValueNotifier<String?> zeniqErrorNotifier;
  final ValueNotifier<String?> tokenErrorNotifier;

  AddLiquidityFormController(double zeniqBalance, double tokenBalance)
      : zeniqNotifier = ValueNotifier(""),
        tokenNotifier = ValueNotifier(""),
        zeniqErrorNotifier = ValueNotifier(null),
        tokenErrorNotifier = ValueNotifier(null) {
    zeniqNotifier.addListener(() {
      _validateInputs(zeniqBalance, tokenBalance);
    });

    tokenNotifier.addListener(() {
      _validateInputs(zeniqBalance, tokenBalance);
    });
  }

  void _validateInputs(double zeniqBalance, double tokenBalance) {
    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? -1;
    final tokenInput = double.tryParse(tokenNotifier.value) ?? -1;

    if (zeniqInput != -1 && zeniqInput > zeniqBalance) {
      zeniqErrorNotifier.value = "Insufficient balance";
    } else {
      zeniqErrorNotifier.value = null;
    }

    if (tokenInput != -1 && tokenInput > tokenBalance) {
      tokenErrorNotifier.value = "Insufficient balance";
    } else {
      tokenErrorNotifier.value = null;
    }
  }
}

AddLiquidityFormController useAddLiquidityForm(
    double zeniqBalance, double tokenBalance) {
  final controller = useMemoized(
      () => AddLiquidityFormController(zeniqBalance, tokenBalance),
      [zeniqBalance, tokenBalance]);

  return controller;
}
