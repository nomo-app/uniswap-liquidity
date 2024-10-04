import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/token_repository.dart';
import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

part 'token_provider.g.dart';

@riverpod
class TokenNotifier extends _$TokenNotifier {
  @override
  Future<List<ERC20Entity>> build(List<Pair> pairs) async {
    final List<ERC20Entity> listAssets = [];

    try {
      listAssets.addAll(
        await WebonKitDart.getAllAssets().then(
          (assets) => assets
              .where((asset) {
                return asset.chainId == ZeniqSmartNetwork.chainId;
              })
              .map((asset) {
                if (asset.contractAddress != null) {
                  return ERC20Entity(
                    name: asset.name,
                    symbol: asset.symbol,
                    decimals: asset.decimals,
                    contractAddress: asset.contractAddress!,
                    chainID: asset.chainId!,
                  );
                }

                return null;
              })
              .whereType<ERC20Entity>()
              .toList(),
        ),
      );
    } catch (e) {
      listAssets.addAll(await TokenRepository.fetchFixedTokens());
    }

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
    final tokensWithNoPool = listAssets.where((token) {
      final cleanedSymbol = cleanSymbol(token.symbol);
      return !existingTokenSymbols.contains(cleanedSymbol);
    }).toList();

    return tokensWithNoPool;
  }
}
