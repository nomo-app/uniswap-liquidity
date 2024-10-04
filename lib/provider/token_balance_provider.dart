import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'token_balance_provider.g.dart';

@riverpod
class TokenBalanceNotifier extends _$TokenBalanceNotifier {
  @override
  Future<Amount> build(ERC20Entity token) async {
    return rpc.fetchTokenBalance(address, token);
  }
}
