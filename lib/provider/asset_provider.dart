import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uniswap_liquidity/main.dart';
import 'package:uniswap_liquidity/utils/image_repository.dart';
import 'package:uniswap_liquidity/utils/logger.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part 'asset_provider.g.dart';

const _fetchInterval = Duration(minutes: 1);

class AssetNotifier {
  final String address;
  final List<TokenEntity> tokens;
  final EvmRpcInterface rpc = EvmRpcInterface(
    type: ZeniqSmartNetwork,
    clients: [
      EvmRpcClient(zeniqSmartRPCEndpoint),
    ],
  );

  final ValueNotifier<Currency> currencyNotifier = ValueNotifier(Currency.usd);

  Currency get currency => currencyNotifier.value;

  final Map<TokenEntity, ValueNotifier<AsyncValue<ImageEntity>>> _images = {};

  void addPreviewToken(TokenEntity token) {
    _images[token] = ValueNotifier(AsyncValue.loading());
    fetchImageForToken(token);
  }

  void addToken(TokenEntity token) {
    tokens.add(token);

    fetchImageForToken(token);
  }

  AssetNotifier(this.address, this.tokens) {
    for (final token in tokens) {
      _images[token] = ValueNotifier(AsyncValue.loading());
    }

    fetchAllImages();

    Timer.periodic(_fetchInterval, (_) {
      fetchAllImages();
    });
  }

  Future<void> fetchAllImages() async =>
      await Future.wait(tokens.map(fetchImageForToken));

  Future<void> fetchImageForToken(TokenEntity token) async {
    if (!_images.containsKey(token)) {
      _images[token] = ValueNotifier(AsyncValue.loading());
    }
    final currentImage = _images[token]!.value;

    if (currentImage.hasValue) return;

    if (token.symbol == "WZENIQ") {
      final image = ImageEntity(
        thumb: "assets/images/zeniq.png",
        small: "assets/images/zeniq.png",
        large: "assets/images/zeniq.png",
      );
      _images[token]!.value = AsyncValue.data(image);
      return;
    }

    try {
      final image = await ImageRepository.getImage(token);
      _images[token]!.value = AsyncValue.data(image);
    } catch (e, s) {
      Logger.logError(
        e,
        hint: "Failed to fetch image for ${token.symbol}",
        s: s,
      );
      final image = ImageEntity(
        thumb: "assets/images/blank-token.png",
        small: "assets/images/blank-token.png",
        large: "assets/images/blank-token.png",
      );
      _images[token]!.value = AsyncValue.data(image);
    }
  }

  Future<double> fetchSingelPrice(
      EthBasedTokenEntity token, bool isZeniq) async {
    final result = await PriceRepository.fetchSingle(token, currency, isZeniq);
    return result;
  }

  ValueNotifier<AsyncValue<ImageEntity>>? imageNotifierForToken(
          TokenEntity token) =>
      _images[token];
}

@Riverpod(keepAlive: true)
AssetNotifier assetNotifier(AssetNotifierRef ref) {
  return AssetNotifier(address, []);
}
