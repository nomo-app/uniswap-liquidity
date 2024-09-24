import 'package:uniswap_liquidity/provider/model/position.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class Pair extends PairInformation {
  EthBasedTokenEntity tokeWZeniq;
  EthBasedTokenEntity token;
  UniswapV2Pair contract;
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
    required super.zeniqValue,
    required super.tokenValue,
    required super.tokenPrice,
    required super.zeniqPrice,
    required super.balanceToken,
    required super.fiatBlanceToken,
    required super.fiatZeniqBalance,
    required super.tokenPerZeniq,
    required super.zeniqPerToken,
    this.isUpdating = false,
    required this.position,
  });

  copyWith({
    EthBasedTokenEntity? tokeWZeniq,
    EthBasedTokenEntity? token,
    UniswapV2Pair? contract,
    (BigInt, BigInt)? reserves,
    double? tvl,
    double? volume24h,
    double? fees24h,
    double? apr,
    double? zeniqValue,
    double? tokenValue,
    double? tokenPrice,
    double? zeniqPrice,
    Amount? balanceToken,
    double? fiatBlanceToken,
    double? fiatZeniqBalance,
    bool? isUpdating,
    double? tokenPerZeniq,
    double? zeniqPerToken,
    Position? position,
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
      zeniqValue: zeniqValue ?? this.zeniqValue,
      tokenValue: tokenValue ?? this.tokenValue,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      isUpdating: isUpdating ?? this.isUpdating,
      zeniqPrice: zeniqPrice ?? this.zeniqPrice,
      balanceToken: balanceToken ?? this.balanceToken,
      fiatBlanceToken: fiatBlanceToken ?? this.fiatBlanceToken,
      fiatZeniqBalance: fiatZeniqBalance ?? this.fiatZeniqBalance,
      tokenPerZeniq: tokenPerZeniq ?? this.tokenPerZeniq,
      zeniqPerToken: zeniqPerToken ?? this.zeniqPerToken,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) {
    return contract.contractAddress == (other as Pair).contract.contractAddress;
  }

  @override
  String toString() {
    return "Pair ${tokeWZeniq.symbol}/${token.symbol} contract ${contract.contractAddress}";
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
        zeniqValue.hashCode ^
        tokenValue.hashCode ^
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
  final double tokenValue;
  final double zeniqValue;
  final Amount? balanceToken;
  final double? fiatBlanceToken;
  final double? fiatZeniqBalance;
  final double tokenPerZeniq;
  final double zeniqPerToken;

  PairInformation({
    required this.tvl,
    required this.volume24h,
    required this.fees24h,
    required this.apr,
    required this.zeniqValue,
    required this.tokenValue,
    required this.tokenPrice,
    required this.zeniqPrice,
    required this.balanceToken,
    required this.fiatBlanceToken,
    required this.fiatZeniqBalance,
    required this.tokenPerZeniq,
    required this.zeniqPerToken,
  });
}
