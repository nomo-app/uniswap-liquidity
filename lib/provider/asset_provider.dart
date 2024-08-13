import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  final Map<TokenEntity, ValueNotifier<AsyncValue<Amount>>> _balances = {};
  final Map<TokenEntity, ValueNotifier<AsyncValue<PriceState>>> _prices = {};
  final Map<TokenEntity, ValueNotifier<AsyncValue<ImageEntity>>> _images = {};

  void addPreviewToken(TokenEntity token) {
    _balances[token] = ValueNotifier(AsyncValue.loading());
    _prices[token] = ValueNotifier(AsyncValue.loading());
    _images[token] = ValueNotifier(AsyncValue.loading());

    fetchBalanceForToken(token);
    fetchImageForToken(token);
  }

  void addToken(TokenEntity token) {
    tokens.add(token);

    fetchBalanceForToken(token);
    fetchImageForToken(token);
    fetchPriceForToken(token);
  }

  AssetNotifier(this.address, this.tokens) {
    for (final token in tokens) {
      _balances[token] = ValueNotifier(AsyncValue.loading());
      _prices[token] = ValueNotifier(AsyncValue.loading());
      _images[token] = ValueNotifier(AsyncValue.loading());
    }

    currencyNotifier.addListener(() {
      fetchAllPrices();
    });

    fetchAllBalances();
    fetchAllPrices();
    fetchAllImages();

    Timer.periodic(_fetchInterval, (_) {
      fetchAllBalances();
      fetchAllPrices();
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

  Future<void> fetchAllBalances() async =>
      await Future.wait(tokens.map(fetchBalanceForToken));

  Future<void> fetchBalanceForToken(TokenEntity token) async {
    try {
      final balance = await (token.isERC20
          ? rpc.fetchTokenBalance(address, token.asEthBased!)
          : rpc.fetchBalance(address: address));

      _balances[token]!.value = AsyncValue.data(balance);
    } catch (e, s) {
      _balances[token]!.value = AsyncValue.error(e, s);
    }
  }

  Future<void> fetchAllPrices() async {
    final results =
        await PriceRepository.fetchAll(currency: currency, tokens: tokens);

    for (final token in tokens) {
      var priceEntity = results.firstWhereOrNull((pe) => pe.matchToken(token));

      if (priceEntity == null || priceEntity.isPending) {
        _prices[token]!.value =
            AsyncValue.error("Price not available", StackTrace.current);
        continue;
      }

      _prices[token]!.value = AsyncValue.data(
        PriceState(currency: currency, price: priceEntity.price),
      );
    }
  }

  Future<void> fetchPriceForToken(TokenEntity token) async {
    try {
      final result = await PriceRepository.fetchSingle(token, currency);
      _prices[token]!.value = AsyncValue.data(
        PriceState(currency: currency, price: result),
      );
    } catch (e, s) {
      _prices[token]!.value = AsyncValue.error(e, s);
    }
  }

  ValueNotifier<AsyncValue<Amount>> notifierForToken(TokenEntity token) =>
      _balances[token]!;

  ValueNotifier<AsyncValue<PriceState>> priceNotifierForToken(
          TokenEntity token) =>
      _prices[token]!;

  ValueNotifier<AsyncValue<ImageEntity>>? imageNotifierForToken(
          TokenEntity token) =>
      _images[token];
}

@Riverpod(keepAlive: true)
AssetNotifier assetNotifier(AssetNotifierRef ref) {
  return AssetNotifier('0xA7Fa4bB0bba164F999E8C7B83C9da96A3bE44616', []);
}
