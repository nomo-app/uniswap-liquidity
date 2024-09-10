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

  RemoveLiquidityFormHook({
    required this.sliderValue,
    required this.selectedPool,
    required this.position,
  })  : zeniqAmount = ValueNotifier("0.0"),
        tokenAmount = ValueNotifier("0.0"),
        liquidityState = ValueNotifier(LiquidityState.idel),
        needsApproval = ValueNotifier(
          ApprovalState.needsApproval,
        ) {
    sliderValue.addListener(calculateReceiveTokens);
  }

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

  void calculateReceiveTokens() {
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
      needsApproval.value = ApprovalState.error;
      print("Error approving");
    }
  }

  Future<String?> removeLiquidity() async {
    liquidityState.value = LiquidityState.loading;

    final tokenAmountToRemove = Amount(
      value: parseFromString(tokenAmount.value, selectedPool.token.decimals)!,
      decimals: selectedPool.token.decimals,
    );

    final zeniqAmountToRemove = Amount(
      value:
          parseFromString(zeniqAmount.value, selectedPool.tokeWZeniq.decimals)!,
      decimals: selectedPool.tokeWZeniq.decimals,
    );

    final now = DateTime.now();
    final deadline = now.add(
      Duration(minutes: 10),
    );

    final zeniqAmountWithPoolRatio =
        zeniqAmountToRemove / position.reserveAmountZeniq;
    final tokenAmountWithPoolRatio =
        tokenAmountToRemove / position.reserveAmountToken;

    final smallerRatio = zeniqAmountWithPoolRatio < tokenAmountWithPoolRatio
        ? zeniqAmountWithPoolRatio
        : tokenAmountWithPoolRatio;

    final liquidityToRemoveWithoutRightBigInt =
        smallerRatio * position.totalSupply;

    final liquidityToRemove =
        discardRightBigInt(liquidityToRemoveWithoutRightBigInt.value, 18);

    print("Liquidity to remove: ${liquidityToRemove}");

    try {
      final rawTx = await zeniqSwapRouter.removeLiquidityETHTx(
        sender: address,
        liquidity: liquidityToRemove,
        amountTokenMin: calculateMinAmount(
            tokenAmountToRemove.value, "0.5", selectedPool.token.decimals),
        amountETHMin: calculateMinAmount(
            zeniqAmountToRemove.value, "0.5", selectedPool.tokeWZeniq.decimals),
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
      liquidityState.value = LiquidityState.error;
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
