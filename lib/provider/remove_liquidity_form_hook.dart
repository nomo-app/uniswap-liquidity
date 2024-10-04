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
  final ValueNotifier<String?> totalLiquidityToRemove;

  RemoveLiquidityFormHook(
      {required this.sliderValue,
      required this.selectedPool,
      required this.position,
      required this.totalLiquidityToRemove})
      : zeniqAmount = ValueNotifier(""),
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
      if (selectedPool.contract.isUniswap) {
        allowance = await selectedPool.contract.asUniswap.allowance(
          owner: address,
          spender: zeniqSwapRouter.contractAddress,
        );
      } else {
        allowance = await selectedPool.contract.asZeniqSwap.allowance(
          owner: address,
          spender: zeniqV2SwapRouter.contractAddress,
        );
      }
    } catch (e) {
      print("Error checking allowance");
    }

    return allowance;
  }

  void _onSliderChanged() {
    if (!_isUpdating) {
      _isUpdating = true;
      try {
        _calculateReceiveTokens();
      } finally {
        _isUpdating = false;
      }
    }
  }

  void _onZeniqAmountChanged() {
    if (!_isUpdating) {
      _isUpdating = true;
      try {
        if (zeniqAmount.value.isEmpty) {
          _resetInputs();
        } else {
          _calculateTokenAndSliderFromZeniq();
        }
      } finally {
        _isUpdating = false;
      }
    }
  }

  void _onTokenAmountChanged() {
    if (!_isUpdating) {
      _isUpdating = true;
      try {
        if (tokenAmount.value.isEmpty) {
          _resetInputs();
        } else {
          _calculateZeniqAndSliderFromToken();
        }
      } finally {
        _isUpdating = false;
      }
    }
  }

  void _resetInputs() {
    zeniqAmount.value = "";
    tokenAmount.value = "";
    sliderValue.value = 0;
    _clearErrors();
  }

  void _calculateTotalLiquidityToRemove() {
    final zeniqAmountBigInt =
        parseFromString(zeniqAmount.value, selectedPool.tokeWZeniq.decimals);
    final tokenAmountBigInt =
        parseFromString(tokenAmount.value, selectedPool.token.decimals);

    if (zeniqAmountBigInt == null || tokenAmountBigInt == null) {
      totalLiquidityToRemove.value = "";
      return;
    }

    final zeniqAmountWithPoolRatio = (zeniqAmountBigInt *
            BigInt.from(10).pow(selectedPool.tokeWZeniq.decimals)) ~/
        position.reserveAmountZeniq.value;
    final tokenAmountWithPoolRatio = (tokenAmountBigInt *
            BigInt.from(10).pow(selectedPool.token.decimals)) ~/
        position.reserveAmountToken.value;

    final smallerRatio = zeniqAmountWithPoolRatio < tokenAmountWithPoolRatio
        ? zeniqAmountWithPoolRatio
        : tokenAmountWithPoolRatio;

    final liquidityToRemoveValue =
        (smallerRatio * position.totalSupply.value) ~/ BigInt.from(10).pow(18);

    final liquidityToRemove = Amount(
      value: liquidityToRemoveValue,
      decimals: 18, // Assuming liquidity tokens have 18 decimals
    );

    totalLiquidityToRemove.value = liquidityToRemove.displayValue;
  }

  void _clearErrors() {
    zeniqErrorNotifier.value = null;
    tokenErrorNotifier.value = null;
  }

  void _calculateTokenAndSliderFromZeniq() {
    final zeniqAmountBigInt =
        parseFromString(zeniqAmount.value, selectedPool.tokeWZeniq.decimals);
    if (zeniqAmountBigInt == null ||
        zeniqAmountBigInt > position.zeniqValue.value) {
      zeniqErrorNotifier.value = "Insufficient ZENIQ amount";
      return;
    }

    final percentageToRemove =
        (zeniqAmountBigInt * BigInt.from(1e6)) ~/ position.zeniqValue.value;
    sliderValue.value = (percentageToRemove.toDouble() / 1e4).clamp(0, 100);

    _calculateReceiveTokens(preserveZeniq: true);
    _clearErrors();
  }

  void _calculateZeniqAndSliderFromToken() {
    final tokenAmountBigInt =
        parseFromString(tokenAmount.value, selectedPool.token.decimals);
    if (tokenAmountBigInt == null ||
        tokenAmountBigInt > position.tokenValue.value) {
      tokenErrorNotifier.value = "Insufficient token amount";
      return;
    }

    final percentageToRemove =
        (tokenAmountBigInt * BigInt.from(1e6)) ~/ position.tokenValue.value;
    sliderValue.value = (percentageToRemove.toDouble() / 1e4).clamp(0, 100);

    _calculateReceiveTokens(preserveToken: true);
    _clearErrors();
  }

  void _calculateReceiveTokens(
      {bool preserveZeniq = false, bool preserveToken = false}) {
    final percentageToRemove = sliderValue.value / 100;

    final zeniqRemoveValue = (position.zeniqValue.value *
            BigInt.from((percentageToRemove * 1e6).round())) ~/
        BigInt.from(1e6);
    final tokenRemoveValue = (position.tokenValue.value *
            BigInt.from((percentageToRemove * 1e6).round())) ~/
        BigInt.from(1e6);

    if (!preserveZeniq) {
      final zeniqAmountToRemove = Amount(
        value: zeniqRemoveValue,
        decimals: selectedPool.tokeWZeniq.decimals,
      );
      zeniqAmount.value = zeniqAmountToRemove.displayValue;
    }

    if (!preserveToken) {
      final tokenAmountToRemove = Amount(
        value: tokenRemoveValue,
        decimals: selectedPool.token.decimals,
      );
      tokenAmount.value = tokenAmountToRemove.displayValue;
    }
    _calculateTotalLiquidityToRemove();
    _clearErrors();
  }

  Future<void> approveLiquidityValue() async {
    approveError.value = "";
    needsApproval.value = ApprovalState.loading;
    try {
      final rawTx = selectedPool.contract.isUniswap
          ? await selectedPool.contract.asUniswap.approveTx(
              sender: address,
              spender: zeniqSwapRouter.contractAddress,
              value: position.liquidity.value,
            ) as RawEVMTransactionType0
          : await selectedPool.contract.asZeniqSwap.approveTx(
              sender: address,
              spender: zeniqV2SwapRouter.contractAddress,
              value: position.liquidity.value,
            ) as RawEVMTransactionType0;

      // final rawTx = await selectedPool.contract.approveTx(
      //   sender: address,
      //   spender: zeniqSwapRouter.contractAddress,
      //   value: position.liquidity.value,
      // ) as RawEVMTransactionType0;
      final signedTxHash = await WebonKitDart.signTransaction(
          rawTx.serializedUnsigned(rpc.type.chainId).toHex);

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
      final rawTx = selectedPool.contract.isZeniqswap
          ? await zeniqV2SwapRouter.removeLiquidityTx(
              sender: address,
              liquidity: liquidityToRemove,
              tokenA: selectedPool.tokeWZeniq.contractAddress,
              tokenB: selectedPool.token.contractAddress,
              amountBMin: calculateMinAmount(
                  tokenAmountToRemove, "0.5", selectedPool.token.decimals),
              amountAMin: calculateMinAmount(
                  zeniqAmountToRemove, "0.5", selectedPool.tokeWZeniq.decimals),
              deadline: BigInt.from(deadline.millisecondsSinceEpoch ~/ 1000),
              to: address,
            ) as RawEVMTransactionType0
          : await zeniqSwapRouter.removeLiquidityETHTx(
              sender: address,
              liquidity: liquidityToRemove,
              token: selectedPool.token.contractAddress,
              amountTokenMin: calculateMinAmount(
                  tokenAmountToRemove, "0.5", selectedPool.token.decimals),
              amountETHMin: calculateMinAmount(
                  zeniqAmountToRemove, "0.5", selectedPool.tokeWZeniq.decimals),
              deadline: BigInt.from(deadline.millisecondsSinceEpoch ~/ 1000),
              to: address,
            ) as RawEVMTransactionType0;

      final signedTxHash = await WebonKitDart.signTransaction(
        rawTx.serializedUnsigned(rpc.type.chainId).toHex,
      );

      final txHash = await rpc.sendRawTransaction(signedTxHash);

      print("messagehex of remove liquidity: ${txHash}");

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
    required ValueNotifier<String> liquidityToRemove,
    required Position position}) {
  final controller = useState<RemoveLiquidityFormHook?>(null);

  useEffect(() {
    final hook = RemoveLiquidityFormHook(
      sliderValue: sliderValue,
      selectedPool: selectedPool,
      totalLiquidityToRemove: liquidityToRemove,
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
