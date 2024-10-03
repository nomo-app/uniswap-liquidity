import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/liquidity_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

class AddPoolFormController {
  final ValueNotifier<String> zeniqNotifier;
  final ValueNotifier<String> tokenNotifier;
  final ValueNotifier<String?> zeniqErrorNotifier;
  final ValueNotifier<String?> tokenErrorNotifier;
  final ValueNotifier<bool> canAddLiquidity;
  final ValueNotifier<ApprovalState> tokenApprovalState;
  final ValueNotifier<ApprovalState> wzeniqApprovalState;
  final int zeniqDecimals;
  final int tokenDecimals;
  final double zeniqBalance;
  final double tokenBalance;
  final String tokenContractAddress;
  final String wzeniqContractAddress;

  AddPoolFormController(
    this.zeniqBalance,
    this.tokenBalance,
    this.zeniqDecimals,
    this.tokenDecimals,
    this.tokenContractAddress,
    this.wzeniqContractAddress,
  )   : zeniqNotifier = ValueNotifier(""),
        tokenNotifier = ValueNotifier(""),
        canAddLiquidity = ValueNotifier(false),
        tokenApprovalState = ValueNotifier(ApprovalState.idel),
        wzeniqApprovalState = ValueNotifier(ApprovalState.idel),
        zeniqErrorNotifier = ValueNotifier(null),
        tokenErrorNotifier = ValueNotifier(null) {
    zeniqNotifier.addListener(_validateInputs);
    tokenNotifier.addListener(_validateInputs);
  }

  void _validateInputs() async {
    bool isValid = true;
    ApprovalState tokenApproval = ApprovalState.idel;
    ApprovalState wzeniqApproval = ApprovalState.idel;

    if (zeniqNotifier.value.isEmpty || tokenNotifier.value.isEmpty) {
      isValid = false;
    }

    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? 0;
    final tokenInput = double.tryParse(tokenNotifier.value) ?? 0;

    if (zeniqInput > zeniqBalance) {
      zeniqErrorNotifier.value = "Insufficient ZENIQ balance";
      isValid = false;
    } else {
      zeniqErrorNotifier.value = null;
    }

    if (tokenInput > tokenBalance) {
      tokenErrorNotifier.value = "Insufficient token balance";
      isValid = false;
    } else {
      tokenErrorNotifier.value = null;
    }

    if (isValid) {
      final tokenAllowance = await checkAllowance(tokenContractAddress);
      final wzeniqAllowance = await checkAllowance(wzeniqContractAddress);

      Amount tokenAmount =
          Amount.convert(value: tokenInput, decimals: tokenDecimals);
      Amount zeniqAmount =
          Amount.convert(value: zeniqInput, decimals: zeniqDecimals);

      if (tokenAllowance < tokenAmount.value) {
        tokenApproval = ApprovalState.needsApproval;
        isValid = false;
      }

      if (wzeniqAllowance < zeniqAmount.value) {
        wzeniqApproval = ApprovalState.needsApproval;
        isValid = false;
      }
    }

    tokenApprovalState.value = tokenApproval;
    wzeniqApprovalState.value = wzeniqApproval;
    canAddLiquidity.value = isValid;
  }

  Future<BigInt> checkAllowance(String contractAddress) async {
    BigInt allowance = BigInt.zero;
    ERC20Contract contract = ERC20Contract(
      contractAddress: contractAddress,
      rpc: rpc,
    );
    try {
      allowance = await contract.allowance(
        owner: address,
        spender: zeniqV2SwapRouter.contractAddress,
      );
      print("Allowance for $contractAddress: $allowance");
      return allowance;
    } catch (e) {
      print('Error fetching allowance for $contractAddress: $e');
    }
    return allowance;
  }

  Future<void> approveToken(String contractAddress, BigInt amount) async {
    final isWZENIQ = contractAddress == wzeniqContractAddress;
    final approvalState = isWZENIQ ? wzeniqApprovalState : tokenApprovalState;

    approvalState.value = ApprovalState.loading;
    ERC20Contract contract = ERC20Contract(
      contractAddress: contractAddress,
      rpc: rpc,
    );

    try {
      final rawTx = await contract.approveTx(
        sender: address,
        spender: zeniqSwapRouter.contractAddress,
        value: amount,
      ) as RawEVMTransactionType0;
      print("Raw approve TX for ${isWZENIQ ? 'WZENIQ' : 'token'}: $rawTx");
      final signedTx = await WebonKitDart.signTransaction(
          rawTx.serializedUnsigned(rpc.type.chainId).toHex);
      final txHash = await rpc.sendRawTransaction(signedTx);

      final approved = await rpc.waitForTxConfirmation(txHash);

      if (approved) {
        approvalState.value = ApprovalState.approved;
        _validateInputs(); // Re-validate to check if we can now add liquidity
      } else {
        throw Exception("Approval failed");
      }

      print("messagehex of approve ${isWZENIQ ? 'WZENIQ' : 'token'}: $txHash");
    } catch (e) {
      approvalState.value = ApprovalState.error;
      print('Error approving ${isWZENIQ ? 'WZENIQ' : 'token'} value: $e');
    }
  }
}

AddPoolFormController useAddPairFormHook(double zeniqBalance, Pair pool) {
  final controller = useState<AddPoolFormController?>(null);

  useEffect(() {
    controller.value = AddPoolFormController(
      zeniqBalance,
      pool.balanceToken?.displayDouble ?? 0,
      pool.tokeWZeniq.decimals,
      pool.token.decimals,
      pool.token.contractAddress,
      pool.tokeWZeniq.contractAddress,
    );
    return null;
  }, [zeniqBalance, pool]);

  return controller.value!;
}
