import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/utils/token_repository.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'token_provider.g.dart';

@riverpod
class TokenNotifier extends _$TokenNotifier {
  @override
  Future<List<ERC20Entity>> build() async {
    final allToken = await TokenRepository.fetchFixedTokens();

    return TokenRepository.fetchTokensWhereNoLiquidty(
        allTokens: allToken, minZeniqInPool: 1000);
  }
}
