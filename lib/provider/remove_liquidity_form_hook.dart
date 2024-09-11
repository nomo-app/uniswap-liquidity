import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/model/position.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

class RemoveLiquidityFormHook {
  final ValueNotifier<double> sliderValue;
  final Pair selectedPool;
  final ValueNotifier<String> zeniqAmount;
  final ValueNotifier<String> tokenAmount;
  final Position position;
  final ValueNotifier<ApprovalState> needsApproval;
  final ValueNotifier<LiquidityState> liquidityState;
  final ValueNotifier<String> approveError;
  final ValueNotifier<String> removeError;
  final ValueNotifier<String?> tokenErrorNotifier;
  final ValueNotifier<String?> zeniqErrorNotifier;

  RemoveLiquidityFormHook({
    required this.sliderValue,
    required this.selectedPool,
    required this.position,
  })  : zeniqAmount = ValueNotifier(""),
        tokenAmount = ValueNotifier(""),
        approveError = ValueNotifier(""),
        removeError = ValueNotifier(""),
        tokenErrorNotifier = ValueNotifier(null),
        zeniqErrorNotifier = ValueNotifier(null),
        liquidityState = ValueNotifier(LiquidityState.idel),
        needsApproval = ValueNotifier(
          ApprovalState.needsApproval,
        ) {
    sliderValue.addListener(_onSliderChanged);
    zeniqAmount.addListener(_onZeniqAmountChanged);
    tokenAmount.addListener(_onTokenAmountChanged);
  }

  bool _isUpdating = false;

  Future<BigInt> checkAllowance() async {
    BigInt allowance = BigInt.zero;

    try {
      allowance = await selectedPool.contract.allowance(
        owner: address,
        spender: zeniqSwapRouter.contractAddress,
      );
    } catch (e) {
      print("Error checking allowance");
    }

    return allowance;
  }

  void _onSliderChanged() {
    if (!_isUpdating) {
      _isUpdating = true;
      _calculateReceiveTokens();
      _clearErrors();

      _isUpdating = false;
    }
  }

  void _onZeniqAmountChanged() {
    if (!_isUpdating) {
      _isUpdating = true;
      if (zeniqAmount.value.isEmpty) {
        _resetInputs();
      } else if (_isValidZeniqAmount()) {
        _calculateTokenAndSliderFromZeniq();
        zeniqErrorNotifier.value = null;
      } else {
        zeniqErrorNotifier.value = "Insufficient ZENIQ amount";
        tokenAmount.value = "";
        sliderValue.value = 0;
      }
      _isUpdating = false;
    }
  }

  void _onTokenAmountChanged() {
    if (!_isUpdating) {
      _isUpdating = true;
      if (tokenAmount.value.isEmpty) {
        _resetInputs();
      } else if (_isValidTokenAmount()) {
        _calculateZeniqAndSliderFromToken();
        tokenErrorNotifier.value = null;
      } else {
        tokenErrorNotifier.value = "Insufficient token amount";
        zeniqAmount.value = "";
        sliderValue.value = 0;
      }
      _isUpdating = false;
    }
  }

  void _resetInputs() {
    zeniqAmount.value = "";
    tokenAmount.value = "";
    sliderValue.value = 0;
    _clearErrors();
  }

  bool _isValidZeniqAmount() {
    final zeniqAmountBigInt =
        parseFromString(zeniqAmount.value, selectedPool.tokeWZeniq.decimals);
    return zeniqAmountBigInt != null &&
        zeniqAmountBigInt <= position.zeniqValue.value;
  }

  bool _isValidTokenAmount() {
    final tokenAmountBigInt =
        parseFromString(tokenAmount.value, selectedPool.token.decimals);
    return tokenAmountBigInt != null &&
        tokenAmountBigInt <= position.tokenValue.value;
  }

  void _clearErrors() {
    zeniqErrorNotifier.value = null;
    tokenErrorNotifier.value = null;
  }

  void _calculateTokenAndSliderFromZeniq() {
    final zeniqAmountBigInt =
        parseFromString(zeniqAmount.value, selectedPool.tokeWZeniq.decimals);
    if (zeniqAmountBigInt == null) return;

    final percentageToRemove =
        (zeniqAmountBigInt * BigInt.from(100)) ~/ position.zeniqValue.value;
    sliderValue.value = percentageToRemove.toDouble();

    final tokenRemoveValue =
        (position.tokenValue.value * percentageToRemove) ~/ BigInt.from(100);
    final tokenAmountToRemove = Amount(
      value: tokenRemoveValue,
      decimals: selectedPool.token.decimals,
    );

    tokenAmount.value = tokenAmountToRemove.displayValue;
  }

  void _calculateZeniqAndSliderFromToken() {
    final tokenAmountBigInt =
        parseFromString(tokenAmount.value, selectedPool.token.decimals);
    if (tokenAmountBigInt == null) return;

    final percentageToRemove =
        (tokenAmountBigInt * BigInt.from(100)) ~/ position.tokenValue.value;
    sliderValue.value = percentageToRemove.toDouble();

    final zeniqRemoveValue =
        (position.zeniqValue.value * percentageToRemove) ~/ BigInt.from(100);
    final zeniqAmountToRemove = Amount(
      value: zeniqRemoveValue,
      decimals: selectedPool.tokeWZeniq.decimals,
    );

    zeniqAmount.value = zeniqAmountToRemove.displayValue;
  }

  void _calculateReceiveTokens() {
    final percentageToRemove = sliderValue.value / 100;

    final zeniqRemoveValue = (position.zeniqValue.value *
            BigInt.from((percentageToRemove * 100).toInt())) ~/
        BigInt.from(100);
    final tokenRemoveValue = (position.tokenValue.value *
            BigInt.from((percentageToRemove * 100).toInt())) ~/
        BigInt.from(100);

    final zeniqAmountToRemove = Amount(
      value: zeniqRemoveValue,
      decimals: selectedPool.tokeWZeniq.decimals,
    );

    final tokenAmountToRemove = Amount(
      value: tokenRemoveValue,
      decimals: selectedPool.token.decimals,
    );

    zeniqAmount.value = zeniqAmountToRemove.displayValue;
    tokenAmount.value = tokenAmountToRemove.displayValue;
  }

  Future<void> approveLiquidityValue() async {
    approveError.value = "";
    needsApproval.value = ApprovalState.loading;
    try {
      final rawTx = await selectedPool.contract.approveTx(
        sender: address,
        spender: zeniqSwapRouter.contractAddress,
        value: position.liquidity.value,
      );
      final signedTxHash =
          await WebonKitDart.signTransaction(rawTx.serializedTransactionHex);

      final txHash = await rpc.sendRawTransaction(signedTxHash);

      final approved = await rpc.waitForTxConfirmation(txHash);

      if (approved) {
        needsApproval.value = ApprovalState.approved;
      } else {
        throw Exception("Approval failed");
      }

      print("messagehex of approve token: ${txHash}");
    } catch (e) {
      needsApproval.value = ApprovalState.needsApproval;
      approveError.value = "Error approving";
      print("Error approving");
    }
  }

  Future<String?> removeLiquidity() async {
    removeError.value = "";
    liquidityState.value = LiquidityState.loading;

    final tokenAmountToRemove =
        parseFromString(tokenAmount.value, selectedPool.token.decimals)!;

    final zeniqAmountToRemove =
        parseFromString(zeniqAmount.value, selectedPool.tokeWZeniq.decimals)!;

    final now = DateTime.now();
    final deadline = now.add(
      Duration(minutes: 10),
    );

    final zeniqAmountWithPoolRatio =
        (zeniqAmountToRemove * BigInt.from(10).pow(18)) *
            BigInt.from(10).pow(18) ~/
            position.reserveAmountZeniq.value;
    final tokenAmountWithPoolRatio =
        (tokenAmountToRemove * BigInt.from(10).pow(18)) *
            BigInt.from(10).pow(18) ~/
            position.reserveAmountToken.value;

    final smallerRatio = zeniqAmountWithPoolRatio < tokenAmountWithPoolRatio
        ? zeniqAmountWithPoolRatio
        : tokenAmountWithPoolRatio;

    final liquidityToRemoveliquidityToRemoveWithoutRightBigInt =
        (smallerRatio * position.totalSupply.value) ~/ BigInt.from(10).pow(18);

    final liquidityToRemove = discardRightBigInt(
        liquidityToRemoveliquidityToRemoveWithoutRightBigInt, 18);

    print("Liquidity to remove: ${liquidityToRemove}");

    try {
      final rawTx = await zeniqSwapRouter.removeLiquidityETHTx(
        sender: address,
        liquidity: liquidityToRemove,
        amountTokenMin: calculateMinAmount(
            tokenAmountToRemove, "0.5", selectedPool.token.decimals),
        amountETHMin: calculateMinAmount(
            zeniqAmountToRemove, "0.5", selectedPool.tokeWZeniq.decimals),
        deadline: BigInt.from(deadline.millisecondsSinceEpoch ~/ 1000),
        to: address,
        token: selectedPool.token.contractAddress,
      );

      final signedTxHash =
          await WebonKitDart.signTransaction(rawTx.serializedTransactionHex);

      final txHash = await rpc.sendRawTransaction(signedTxHash);

      final approved = await rpc.waitForTxConfirmation(txHash);

      if (approved) {
        liquidityState.value = LiquidityState.idel;
        return txHash;
      } else {
        throw Exception("Approval failed");
      }
    } catch (e, s) {
      liquidityState.value = LiquidityState.idel;
      removeError.value = "Error removing liquidity $e";
      print("Error removing liquidity$e$s");
    }
    return null;
  }
}

RemoveLiquidityFormHook useRemoveLiquidityFormHook(
    {required ValueNotifier<double> sliderValue,
    required Pair selectedPool,
    required Position position}) {
  final controller = useState<RemoveLiquidityFormHook?>(null);

  useEffect(() {
    final hook = RemoveLiquidityFormHook(
      sliderValue: sliderValue,
      selectedPool: selectedPool,
      position: position,
    );

    // Call the checkAllowance() function and set the needsApproval state
    hook.checkAllowance().then((allowance) {
      hook.needsApproval.value = allowance < position.liquidity.value
          ? ApprovalState.needsApproval
          : ApprovalState.approved;
    });

    controller.value = hook;
    return null;
  }, [
    sliderValue,
    selectedPool,
    position,
  ]);

  return controller.value!;
}
