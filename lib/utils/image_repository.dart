import 'dart:async';
import 'dart:convert';
import 'package:uniswap_liquidity/utils/http_client.dart';
import 'package:uniswap_liquidity/utils/logger.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class ImageEntity {
  final String thumb;
  final String small;
  final String large;
  final bool isPending;

  const ImageEntity({
    required this.thumb,
    required this.small,
    required this.large,
    this.isPending = false,
  });

  factory ImageEntity.fromJson(Map<String, dynamic> json) => ImageEntity(
        thumb: json['thumb'] as String,
        small: json['small'] as String,
        large: json['large'] as String,
        isPending: json['isPending'] as bool? ?? false,
      );
}

abstract class ImageRepository {
  static Future<ImageEntity> getImage(CoinEntity token) async {
    if (token is ERC20Entity &&
        token.contractAddress.toLowerCase() ==
            "0x74DC1C4ec10abE9F5C8A3EabF1A90b97cDc3Ead8".toLowerCase()) {
      token = zeniqCoin;
    }

    final endpoint =
        '$PRICE_ENDPOINT/info/image/${token is ERC20Entity ? '${token.contractAddress}/${chaindIdMap[token.chainID]}' : PriceRepository.getAssetName(token)}';
    try {
      final result = await (_getImage(endpoint).timeout(REQUEST_TIMEOUT_LIMIT));
      return result;
    } catch (e, s) {
      Logger.logError(
        e,
        hint: "Failed to fetch image from $endpoint",
        s: s,
      );
      rethrow;
    }
  }

  static Future<ImageEntity> _getImage(String endpoint) async {
    Logger.logFetch(
      "Fetch Image from $endpoint",
      "PriceService Image",
    );

    final uri = Uri.parse(endpoint);

    final response = await HTTPService.client.get(
      uri,
      headers: {"Content-Type": "application/json"},
    ).timeout(
      REQUEST_TIMEOUT_LIMIT,
      onTimeout: () => throw TimeoutException("Timeout", REQUEST_TIMEOUT_LIMIT),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "image_repository: Request returned status code ${response.statusCode}",
      );
    }
    final body = jsonDecode(response.body);

    if (body == null && body is! Json) {
      throw Exception(
        "image_repository: Request returned null: $endpoint",
      );
    }

    final image = ImageEntity.fromJson(body);

    if (image.isPending) throw Exception("Image is pending");

    return image;
  }
}
