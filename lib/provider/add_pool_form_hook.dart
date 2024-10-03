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
  final Pair pool;
  final ValueNotifier<ApprovalState> tokenApprovalState;
  final ValueNotifier<ApprovalState> zeniqApprovalState;
  final int zeniqDecimals;
  final int tokenDecimals;
  final double zeniqBalance;
  final double tokenBalance;
  final String tokenContractAddress;
  final String wzeniqContractAddress;
  final ValueNotifier<Pair> informationPair;
  final ValueNotifier<bool> showButtons;

  AddPoolFormController(
    this.pool,
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
        zeniqApprovalState = ValueNotifier(ApprovalState.idel),
        informationPair = ValueNotifier(pool),
        zeniqErrorNotifier = ValueNotifier(null),
        showButtons = ValueNotifier(true),
        tokenErrorNotifier = ValueNotifier(null) {
    zeniqNotifier.addListener(_validateInputs);
    tokenNotifier.addListener(_validateInputs);
  }

  void _getValidationPair(double zeniqInput, double tokenInput) {
    double tokensPerZeniq;
    double zeniqPerToken;

    if (zeniqInput == 0 || tokenInput == 0) {
      tokensPerZeniq = 0;
      zeniqPerToken = 0;
    } else {
      tokensPerZeniq = tokenInput / zeniqInput;
      zeniqPerToken = zeniqInput / tokenInput;
    }

    print("Before update: ${informationPair.value.tokenPerZeniq}");
    informationPair.value = informationPair.value.copyWith(
      tokenPerZeniq: tokensPerZeniq,
      zeniqPerToken: zeniqPerToken,
    );

    print("After update: ${informationPair.value.tokenPerZeniq}");
  }

  void _validateInputs() async {
    bool isValid = true;
    final zeniqInput = double.tryParse(zeniqNotifier.value) ?? 0;
    final tokenInput = double.tryParse(tokenNotifier.value) ?? 0;
    _getValidationPair(zeniqInput, tokenInput);
    if (zeniqInput > zeniqBalance) {
      zeniqErrorNotifier.value = "Insufficient balance";
      isValid = false;
    } else if (zeniqInput < 5000 && zeniqInput != 0) {
      zeniqErrorNotifier.value = "Minimum amount is 5000 ZENIQ";
      isValid = false;
    } else {
      zeniqErrorNotifier.value = null;
    }

    if (tokenInput > tokenBalance) {
      tokenErrorNotifier.value = "Insufficient balance";
      isValid = false;
    } else {
      tokenErrorNotifier.value = null;
    }

    if (tokenInput == 0 || zeniqInput == 0) {
      isValid = false;
      showButtons.value = false;
      canAddLiquidity.value = false;
    } else {
      showButtons.value = true;
    }

    if (isValid) {
      final allowanceToken = await checkAllowance(tokenContractAddress);
      final allowanceWzeniq = await checkAllowance(wzeniqContractAddress);

      Amount tokenAmount = Amount.convert(
        value: tokenInput,
        decimals: tokenDecimals,
      );
      Amount zeniqAmount = Amount.convert(
        value: zeniqInput,
        decimals: zeniqDecimals,
      );

      if (allowanceToken < tokenAmount.value) {
        tokenApprovalState.value = ApprovalState.needsApproval;
        isValid = false;
      } else {
        tokenApprovalState.value = ApprovalState.approved;
      }
      if (allowanceWzeniq < zeniqAmount.value) {
        zeniqApprovalState.value = ApprovalState.needsApproval;
        isValid = false;
      } else {
        zeniqApprovalState.value = ApprovalState.approved;
      }

      canAddLiquidity.value = isValid;
    }
  }

  Future<void> approveToken(ERC20Entity token, BigInt amount) async {
    final isZeniq = token.symbol == "ZENIQ";

    if (isZeniq) {
      zeniqApprovalState.value = ApprovalState.loading;
    } else {
      tokenApprovalState.value = ApprovalState.loading;
    }

    ERC20Contract contract = ERC20Contract(
      contractAddress: token.contractAddress,
      rpc: rpc,
    );
    try {
      final rawTx = await contract.approveTx(
        sender: address,
        spender: zeniqV2SwapRouter.contractAddress,
        value: amount,
      ) as RawEVMTransactionType0;
      print("Raw approve TX: ${rawTx}");
      final signedTx = await WebonKitDart.signTransaction(
          rawTx.serializedUnsigned(rpc.type.chainId).toHex);
      final txHash = await rpc.sendRawTransaction(signedTx);

      final approved = await rpc.waitForTxConfirmation(txHash);

      if (approved) {
        if (isZeniq) {
          zeniqApprovalState.value = ApprovalState.approved;
        } else {
          tokenApprovalState.value = ApprovalState.approved;
        }
        canAddLiquidity.value = true;
      } else {
        throw Exception("Approval failed");
      }

      print("messagehex of approve token: ${txHash}");
    } catch (e) {
      if (isZeniq) {
        zeniqApprovalState.value = ApprovalState.error;
      } else {
        tokenApprovalState.value = ApprovalState.error;
      }
      print('Error approving token value: $e');
    }
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
}

AddPoolFormController useAddPairFormHook(
  double zeniqBalance,
  Pair pool,
) {
  final controller = useState<AddPoolFormController?>(null);

  useEffect(() {
    controller.value = AddPoolFormController(
      pool,
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
