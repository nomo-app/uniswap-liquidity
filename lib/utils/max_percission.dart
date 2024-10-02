import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';

String formatValueWithCurrency(Currency currency, double value) {
  return "${currency == Currency.usd ? '${currency.symbol} ' : ''}"
      "${value.formatDouble(2)}"
      "${currency == Currency.eur ? ' ${currency.symbol}' : ''}";
}

extension FormatExtension on double {
  String formatTokenBalance({int maxDecimals = 5, int minDecimals = 2}) {
    if (this == 0) return '0';

    final absValue = abs();

    // For very large numbers (100000 and above)
    if (absValue >= 100000) {
      return round().toString();
    }

    // For numbers between 1 and 99999.99
    if (absValue >= 1) {
      return toStringAsFixed(2);
    }

    // For small numbers (less than 1)
    final String formattedString = toStringAsFixed(maxDecimals);
    final parts = formattedString.split('.');

    if (parts.length == 1) return parts[0]; // No decimal part

    String integerPart = parts[0];
    String fractionalPart = parts[1];

    // Trim trailing zeros, but keep at least minDecimals
    while (
        fractionalPart.length > minDecimals && fractionalPart.endsWith('0')) {
      fractionalPart = fractionalPart.substring(0, fractionalPart.length - 1);
    }

    // If the number is very small, show significant digits
    if (absValue < 0.00001) {
      final scientificNotation = toStringAsExponential(maxDecimals - 1);
      final scientificParts = scientificNotation.split('e');
      final coefficient = double.parse(scientificParts[0]);
      final exponent = int.parse(scientificParts[1]);

      String significantDigits =
          coefficient.abs().toStringAsFixed(maxDecimals - 1);
      while (significantDigits.endsWith('0')) {
        significantDigits =
            significantDigits.substring(0, significantDigits.length - 1);
      }
      if (significantDigits.endsWith('.')) {
        significantDigits =
            significantDigits.substring(0, significantDigits.length - 1);
      }

      return '${this < 0 ? '-' : ''}0.${'0' * (-exponent - 1)}$significantDigits';
    }

    return '$integerPart${fractionalPart.isNotEmpty ? '.$fractionalPart' : ''}';
  }

  (String, Color) formatPriceImpact() {
    return switch (this) {
      < 0.01 => ('<0.01', Colors.greenAccent),
      < 1 => ('${toMaxPrecision(2)}', Colors.greenAccent),
      < 5 => ('${toMaxPrecision(2)}', Colors.deepOrangeAccent),
      _ => ('${toMaxPrecision(2)}', Colors.redAccent),
    };
  }

  String formatDouble(int maxPrecision) {
    if (this == 0) {
      return '0';
    }

    if (this < 0.01) {
      return '<0.01';
    } else {
      return toStringAsFixed(maxPrecision);
    }
  }

  String toMaxPrecisionWithoutScientificNotation(int maxPrecision) {
    final double value = this;
    final exact = value.toExactString();
    final zeroCount = _countZeroDigits(exact);
    final nonZeroCount = value >= 1 ? (log(value) / log(10)).ceil() : 1;
    final maxLen = maxPrecision + zeroCount + nonZeroCount;
    if (maxLen < exact.length) {
      return exact.substring(0, maxLen);
    } else {
      return exact;
    }
  }

  double toMaxPrecision(int maxPrecision) {
    return double.parse(toMaxPrecisionWithoutScientificNotation(maxPrecision));
  }

  int _countZeroDigits(String str) {
    int zeroCount = 0;

    if (str.replaceAll("-", "").indexOf('.') > 1) {
      str = str.substring(str.indexOf('.') + 1, str.length);
    }

    for (int i = 0; i < str.length; i++) {
      if (str[i] != "0" && str[i] != "-" && str[i] != "." && str[i] != ",") {
        break;
      }
      zeroCount++;
    }
    return zeroCount;
  }

  String toExactString() {
    // https://stackoverflow.com/questions/62989638/convert-long-double-to-string-without-scientific-notation-dart
    double value = this;
    var sign = "";
    if (value < 0) {
      value = -value;
      sign = "-";
    }
    var string = value.toString();
    var e = string.lastIndexOf('e');
    if (e < 0) return "$sign$string";
    var hasComma = string.indexOf('.') == 1;
    var offset = int.parse(
      string.substring(e + (string.startsWith('-', e + 1) ? 1 : 2)),
    );
    var digits = string.substring(0, 1);

    if (hasComma) {
      digits += string.substring(2, e);
    }

    if (offset < 0) {
      return "${sign}0.${"0" * ~offset}$digits";
    }
    if (offset > 0) {
      if (offset >= digits.length) {
        return sign + digits.padRight(offset + 1, "0");
      }
      return "$sign${digits.substring(0, offset + 1)}"
          ".${digits.substring(offset + 1)}";
    }
    return digits;
  }
}

BigInt? parseFromString(String value, int decimals) {
  final split = value.replaceAll(',', '.').split('.');

  if (split.length > 2) {
    return null;
  }

  final right = split.length == 2
      ? split[1].padRight(decimals, '0')
      : ''.padRight(decimals, '0');
  final left = split[0];

  return BigInt.tryParse('$left$right');
}
