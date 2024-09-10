import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'dart:math';

import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

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
  final ValueNotifier<String> shareOfPool;
  final ValueNotifier<ApprovalState> needsApproval;
  final BigInt reserveA;
  final BigInt reserveB;
  final int zeniqDecimals;
  final int tokenDecimals;
  final double zeniqBalance;
  final double tokenBalance;
  final String tokenContractAddress;
  final double zeniqPerToken;

  AddLiquidityFormController(
    this.zeniqBalance,
    this.tokenBalance,
    this.reserveA,
    this.reserveB,
    this.zeniqDecimals,
    this.tokenDecimals,
    this.tokenContractAddress,
    this.zeniqPerToken,
  )   : zeniqNotifier = ValueNotifier(""),
        tokenNotifier = ValueNotifier(""),
        canAddLiquidity = ValueNotifier(false),
        needsApproval = ValueNotifier(ApprovalState.idel),
        zeniqErrorNotifier = ValueNotifier(null),
        shareOfPool = ValueNotifier(""),
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

    _calculatePoolShare();

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

    _calculatePoolShare();
    _validateInputs();
  }

  void _validateInputs() async {
    bool isValid = true;
    ApprovalState approvalState = ApprovalState.idel;

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

    if (isValid) {
      final allowence = await checkAllowance(tokenContractAddress);

      Amount tokenAmount =
          Amount.convert(value: tokenInput, decimals: tokenDecimals);

      if (allowence < tokenAmount.value) {
        approvalState = ApprovalState.needsApproval;
        isValid = false;
      }
    }

    needsApproval.value = approvalState;
    canAddLiquidity.value = isValid;
  }

  Future<BigInt> checkAllowance(String contracAddress) async {
    BigInt allowance = BigInt.zero;
    ERC20Contract contract = ERC20Contract(
      contractAddress: contracAddress,
      rpc: rpc,
    );
    try {
      allowance = await contract.allowance(
        owner: address,
        spender: zeniqSwapRouter.contractAddress,
      );

      print("Allowance: ${allowance}");
      return allowance;
    } catch (e) {
      print('Error fetching allowance: $e');
    }
    return allowance;
  }

  Future<void> approveToken(String contracAddress, BigInt amount) async {
    needsApproval.value = ApprovalState.loading;
    ERC20Contract contract = ERC20Contract(
      contractAddress: contracAddress,
      rpc: rpc,
    );

    try {
      final rawTx = await contract.approveTx(
        sender: address,
        spender: zeniqSwapRouter.contractAddress,
        value: amount,
      );
      print("Raw approve TX: ${rawTx}");
      final signedTx =
          await WebonKitDart.signTransaction(rawTx.serializedTransactionHex);
      final txHash = await rpc.sendRawTransaction(signedTx);

      final approved = await rpc.waitForTxConfirmation(txHash);

      if (approved) {
        needsApproval.value = ApprovalState.approved;
        canAddLiquidity.value = true;
      } else {
        throw Exception("Approval failed");
      }

      print("messagehex of approve token: ${txHash}");
    } catch (e) {
      needsApproval.value = ApprovalState.error;
      print('Error approving token value: $e');
    }
  }

  //Something is wrong here :D
  void _calculatePoolShare() {
    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? 0;
    final tokenInput = double.tryParse(tokenNotifier.value) ?? 0;

    if (zeniqInput == 0 || tokenInput == 0) {
      shareOfPool.value = "0%";
      return;
    }

    final reserveADouble = reserveA.toDouble() / pow(10, zeniqDecimals);
    final reserveBDouble = reserveB.toDouble() / pow(10, tokenDecimals);

    final reserveBInZeniq = reserveBDouble * zeniqPerToken;
    final tokenInputInZeniq = tokenInput * zeniqPerToken;

    final totalPoolLiquidityInZeniq = reserveADouble + reserveBInZeniq;

    final userLiquidityInZeniq = zeniqInput + tokenInputInZeniq;

    final poolShare = (userLiquidityInZeniq / totalPoolLiquidityInZeniq) * 100;

    final cappedPoolShare = poolShare > 100 ? 100 : poolShare;

    if (cappedPoolShare.toStringAsFixed(2) == "0.00" && cappedPoolShare > 0) {
      shareOfPool.value = "<0.01%";
    } else {
      shareOfPool.value = "${cappedPoolShare.toStringAsFixed(2)}%";
    }
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
      pool.token.decimals,
      pool.token.contractAddress,
      pool.zeniqPerToken,
    );
    return null;
  }, [zeniqBalance, pool]);

  return controller.value!;
}
