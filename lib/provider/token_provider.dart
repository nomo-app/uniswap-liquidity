import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/token_repository.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'token_provider.g.dart';

@riverpod
class TokenNotifier extends _$TokenNotifier {
  @override
  Future<List<ERC20Entity>> build(List<Pair> pairs) async {
    final allTokens = await TokenRepository.fetchFixedTokens();

    // Filter out pairs with oldPosition set to true
    final relevantPairs =
        pairs.where((pair) => pair.position?.oldPosition != true).toList();

    // Function to remove "ZEN20" namespace from symbol
    String cleanSymbol(String symbol) {
      symbol = symbol.trim();
      if (symbol.startsWith("ZEN20 ")) {
        symbol = symbol.substring(6).trim();
      }
      if (symbol.endsWith(" ZEN20")) {
        symbol = symbol.substring(0, symbol.length - 6).trim();
      }
      return symbol;
    }

    // Create a set of cleaned symbols from relevant pairs
    final existingTokenSymbols = {
      ...relevantPairs.map((pair) => cleanSymbol(pair.token.symbol)),
      ...relevantPairs.map((pair) => cleanSymbol(pair.tokeWZeniq.symbol)),
    }.toSet();

    // Filter out tokens that already have non-old pairs, comparing cleaned symbols
    final tokensWithNoPool = allTokens.where((token) {
      final cleanedSymbol = cleanSymbol(token.symbol);
      return !existingTokenSymbols.contains(cleanedSymbol);
    }).toList();

    return tokensWithNoPool;
  }
}
