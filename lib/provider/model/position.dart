import 'package:walletkit_dart/walletkit_dart.dart';

class Position {
  final Amount liquidity;
  final Amount totalSupply;
  final Amount zeniqValue;
  final Amount tokenValue;
  final Amount share;
  final Amount reserveAmountZeniq;
  final Amount reserveAmountToken;
  final double valueLocked;
  final double zeniqFiatValue;
  final double tokenFiatValue;
  final bool oldPosition;

  Position({
    required this.liquidity,
    required this.zeniqValue,
    required this.tokenValue,
    required this.totalSupply,
    required this.share,
    required this.oldPosition,
    required this.reserveAmountZeniq,
    required this.reserveAmountToken,
    required this.valueLocked,
    required this.zeniqFiatValue,
    required this.tokenFiatValue,
  });
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position &&
        other.liquidity == liquidity &&
        other.totalSupply == totalSupply &&
        other.zeniqValue == zeniqValue &&
        other.tokenValue == tokenValue &&
        other.share == share &&
        other.reserveAmountZeniq == reserveAmountZeniq &&
        other.reserveAmountToken == reserveAmountToken &&
        other.valueLocked == valueLocked &&
        other.zeniqFiatValue == zeniqFiatValue &&
        other.tokenFiatValue == tokenFiatValue &&
        other.oldPosition == oldPosition;
  }

  @override
  int get hashCode => Object.hash(
        liquidity,
        totalSupply,
        zeniqValue,
        tokenValue,
        share,
        reserveAmountZeniq,
        reserveAmountToken,
        valueLocked,
        zeniqFiatValue,
        tokenFiatValue,
        oldPosition,
      );

  @override
  String toString() {
    return 'Position(share: ${share} liquidity: ${liquidity.displayDouble}, zeniqValue: $zeniqValue, tokenValue: $tokenValue isOld: $oldPosition)';
  }
}
