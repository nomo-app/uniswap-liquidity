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
  String toString() {
    return 'Position(share: ${share} liquidity: ${liquidity.displayDouble}, zeniqValue: $zeniqValue, tokenValue: $tokenValue)';
  }
}
