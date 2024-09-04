import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

part 'liquidity_provider.g.dart';

@riverpod
class LiquidityNotifier extends _$LiquidityNotifier {
  @override
  LiquidityState build() {
    return LiquidityState.idel;
  }

  Future<String?> addLiquidity(Liquidity liquidity) async {
    state = LiquidityState.loading;
    final now = DateTime.now();
    final deadline = now.add(Duration(minutes: 20));
    final amountZeniqDesired = Amount.convert(
        value: double.parse(liquidity.zeniqValue),
        decimals: liquidity.pair.tokeWZeniq.decimals);
    final amountTokenDesired = Amount.convert(
        value: double.parse(liquidity.tokenValue),
        decimals: liquidity.pair.token.decimals);
    final minAmountZeniq = calculateMinAmount(amountZeniqDesired.value,
        liquidity.slippage, liquidity.pair.tokeWZeniq.decimals);
    final minAmountToken = calculateMinAmount(amountTokenDesired.value,
        liquidity.slippage, liquidity.pair.token.decimals);
    final tokenContract = liquidity.pair.token.contractAddress;
    final tokenERC20 = ERC20Contract(
      contractAddress: tokenContract,
      rpc: rpc,
    );
    final allowance = await _checkAllowance(tokenContract, tokenERC20);

    if (allowance < amountTokenDesired.value) {
      await _approveToken(tokenContract, tokenERC20, amountTokenDesired.value);
    }

    final rawTX = await _getLiquidtyTx(
      amountETHDesired: amountZeniqDesired.value,
      amountETHMin: minAmountZeniq,
      amountTokenDesired: amountTokenDesired.value,
      amountTokenMin: minAmountToken,
      deadline: BigInt.from(deadline.millisecondsSinceEpoch ~/ 1000),
      token: tokenContract,
    );

    if (rawTX == null) {
      state = LiquidityState.error;
      return null;
    }
    final txHash = await _sendTransaction(rawTX);

    if (txHash == null) {
      state = LiquidityState.error;
      return null;
    }

    state = LiquidityState.idel;

    return txHash;
  }

  Future<String?> _sendTransaction(RawEVMTransaction rawTx) async {
    try {
      final signedTx =
          await WebonKitDart.signTransaction(rawTx.serializedTransactionHex);
      final txHash = await rpc.sendRawTransaction(signedTx);
      return txHash;
    } catch (e) {
      state = LiquidityState.error;
      print('Error sending transaction: $e');
    }
    return null;
  }

  Future<void> _approveToken(
      String contracAddress, ERC20Contract contract, BigInt amount) async {
    try {
      final rawTx = await contract.approveTx(
        sender: address,
        spender: zeniqSwapRouter.contractAddress,
        value: amount,
      );
      final signedTx =
          await WebonKitDart.signTransaction(rawTx.serializedTransactionHex);
      await rpc.sendRawTransaction(signedTx);
    } catch (e) {
      state = LiquidityState.error;
      print('Error approving token value: $e');
    }
  }

  Future<BigInt> _checkAllowance(
      String contracAddress, ERC20Contract contract) async {
    BigInt allowance = BigInt.zero;
    try {
      allowance = await contract.allowance(
        owner: address,
        spender: zeniqSwapRouter.contractAddress,
      );
      return allowance;
    } catch (e) {
      state = LiquidityState.error;
      print('Error fetching allowance: $e');
    }
    return allowance;
  }

  Future<RawEVMTransaction?> _getLiquidtyTx({
    required BigInt deadline,
    required BigInt amountTokenDesired,
    required BigInt amountETHDesired,
    required BigInt amountTokenMin,
    required BigInt amountETHMin,
    required String token,
  }) async {
    try {
      final rawTx = await zeniqSwapRouter.addLiquidityETHTx(
        token: token,
        amountTokenDesired: amountTokenDesired,
        amountETHMin: amountETHMin,
        amountTokenMin: amountTokenMin,
        to: address,
        deadline: deadline,
        sender: address,
        amountETHDesired: amountETHDesired,
      );
      return rawTx;
    } catch (e) {
      state = LiquidityState.error;
      print('Error fetching raw tx: $e');
    }

    return null;
  }
}

enum LiquidityState { loading, idel, error }

BigInt calculateMinAmount(BigInt amount, String slippage, int tokenDecimals) {
  // Convert slippage to a decimal (e.g., "0.5" becomes 0.005)
  final slippageDecimal = double.parse(slippage) / 100;

  // Calculate the scaling factor based on token decimals
  final scalingFactor = BigInt.from(10).pow(tokenDecimals);

  // Calculate the slippage amount
  final slippageAmount = (amount *
          BigInt.from((slippageDecimal * scalingFactor.toDouble()).round())) ~/
      scalingFactor;

  // Calculate the minimum amount
  final minAmount = amount - slippageAmount;

  return minAmount;
}

class Liquidity {
  final Pair pair;
  final String slippage;
  final String zeniqValue;
  final String tokenValue;

  Liquidity(
      {required this.pair,
      required this.slippage,
      required this.zeniqValue,
      required this.tokenValue});
}
