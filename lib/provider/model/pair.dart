import 'package:flutter/foundation.dart';
import 'package:uniswap_liquidity/provider/model/position.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

@immutable
class UniswapV2PairOrZeniqSwapPair {
  final dynamic _contract;

  const UniswapV2PairOrZeniqSwapPair.uniswap(UniswapV2Pair contract)
      : _contract = contract;
  const UniswapV2PairOrZeniqSwapPair.zeniqSwap(ZeniqswapV2Pair contract)
      : _contract = contract;

  bool get isUniswap => _contract is UniswapV2Pair;
  bool get isZeniqswap => _contract is ZeniqswapV2Pair;

  UniswapV2Pair get asUniswap => _contract as UniswapV2Pair;
  ZeniqswapV2Pair get asZeniqSwap => _contract as ZeniqswapV2Pair;

  get contractAddress => when(
        uniswap: (contract) => contract.contractAddress,
        zeniqSwap: (contract) => contract.contractAddress,
      );

  T when<T>({
    required T Function(UniswapV2Pair) uniswap,
    required T Function(ZeniqswapV2Pair) zeniqSwap,
  }) {
    if (_contract is UniswapV2Pair) {
      return uniswap(_contract);
    } else {
      return zeniqSwap(_contract as ZeniqswapV2Pair);
    }
  }
}

class Pair extends PairInformation {
  ERC20Entity tokeWZeniq;
  ERC20Entity token;
  final UniswapV2PairOrZeniqSwapPair contract;
  (BigInt, BigInt) reserves;
  Position? position;
  final bool isUpdating;

  Pair({
    required this.tokeWZeniq,
    required super.volume24h,
    required super.fees24h,
    required super.apr,
    required this.token,
    required this.contract,
    required this.reserves,
    required super.tvl,
    required super.zeniqFiatValue,
    required super.tokenFiatValue,
    required super.tokenPrice,
    required super.zeniqPrice,
    required super.balanceToken,
    required super.fiatBlanceToken,
    required super.fiatZeniqBalance,
    required super.zeniqBalance,
    required super.tokenPerZeniq,
    required super.zeniqPerToken,
    this.isUpdating = false,
    required this.position,
    required super.zeniqValue,
    required super.tokenValue,
  });

  copyWith({
    ERC20Entity? tokeWZeniq,
    ERC20Entity? token,
    UniswapV2PairOrZeniqSwapPair? contract,
    (BigInt, BigInt)? reserves,
    double? tvl,
    double? volume24h,
    double? fees24h,
    double? apr,
    double? zeniqFiatValue,
    double? tokenFiatValue,
    double? tokenPrice,
    double? zeniqPrice,
    Amount? balanceToken,
    double? fiatBlanceToken,
    double? fiatZeniqBalance,
    Amount? zeniqBalance,
    bool? isUpdating,
    double? tokenPerZeniq,
    double? zeniqPerToken,
    Position? position,
    Amount? zeniqValue,
    Amount? tokenValue,
  }) {
    return Pair(
      tokeWZeniq: tokeWZeniq ?? this.tokeWZeniq,
      token: token ?? this.token,
      contract: contract ?? this.contract,
      reserves: reserves ?? this.reserves,
      tvl: tvl ?? this.tvl,
      volume24h: volume24h ?? this.volume24h,
      fees24h: fees24h ?? this.fees24h,
      apr: apr ?? this.apr,
      zeniqFiatValue: zeniqFiatValue ?? this.zeniqFiatValue,
      tokenFiatValue: tokenFiatValue ?? this.tokenFiatValue,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      isUpdating: isUpdating ?? this.isUpdating,
      zeniqPrice: zeniqPrice ?? this.zeniqPrice,
      balanceToken: balanceToken ?? this.balanceToken,
      fiatBlanceToken: fiatBlanceToken ?? this.fiatBlanceToken,
      fiatZeniqBalance: fiatZeniqBalance ?? this.fiatZeniqBalance,
      zeniqBalance: zeniqBalance ?? this.zeniqBalance,
      tokenPerZeniq: tokenPerZeniq ?? this.tokenPerZeniq,
      zeniqPerToken: zeniqPerToken ?? this.zeniqPerToken,
      position: position ?? this.position,
      zeniqValue: zeniqValue ?? this.zeniqValue,
      tokenValue: tokenValue ?? this.tokenValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pair &&
        other.contract == contract &&
        other.tokenPerZeniq == tokenPerZeniq &&
        other.zeniqPerToken == zeniqPerToken &&
        other.tokeWZeniq == tokeWZeniq &&
        other.token == token &&
        other.reserves == reserves &&
        other.position == position &&
        other.isUpdating == isUpdating;
  }

  @override
  String toString() {
    return "Pair ${tokeWZeniq.symbol}/${token.symbol}";
  }

  @override
  int get hashCode {
    return tokeWZeniq.hashCode ^
        token.hashCode ^
        contract.hashCode ^
        reserves.hashCode ^
        tvl.hashCode ^
        volume24h.hashCode ^
        fees24h.hashCode ^
        apr.hashCode ^
        zeniqFiatValue.hashCode ^
        tokenFiatValue.hashCode ^
        tokenPrice.hashCode ^
        zeniqPrice.hashCode ^
        balanceToken.hashCode ^
        fiatBlanceToken.hashCode ^
        fiatZeniqBalance.hashCode ^
        tokenPerZeniq.hashCode ^
        zeniqPerToken.hashCode ^
        position.hashCode;
  }
}

abstract class PairInformation {
  final double tvl;
  final double? volume24h;
  final double? fees24h;
  final double? apr;
  final double zeniqPrice;
  final double tokenPrice;
  final double tokenFiatValue;
  final double zeniqFiatValue;
  final Amount? balanceToken;
  final double? fiatBlanceToken;
  final double? fiatZeniqBalance;
  final Amount zeniqBalance;
  final double tokenPerZeniq;
  final double zeniqPerToken;
  final Amount zeniqValue;
  final Amount tokenValue;

  PairInformation({
    required this.tvl,
    required this.volume24h,
    required this.fees24h,
    required this.apr,
    required this.zeniqFiatValue,
    required this.tokenFiatValue,
    required this.tokenPrice,
    required this.zeniqPrice,
    required this.balanceToken,
    required this.fiatBlanceToken,
    required this.fiatZeniqBalance,
    required this.zeniqBalance,
    required this.tokenPerZeniq,
    required this.zeniqPerToken,
    required this.zeniqValue,
    required this.tokenValue,
  });
}
