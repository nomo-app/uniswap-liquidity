import 'package:walletkit_dart/walletkit_dart.dart';

class Position {
  final Amount liquidity;
  // final Pair pair;
  final Amount totalSupply;
  final Amount zeniqValue;
  final Amount tokenValue;
  final Amount share;
  final Amount reserveAmountZeniq;
  final Amount reserveAmountToken;
  final double valueLocked;

  Position({
    // required this.pair,
    required this.liquidity,
    required this.zeniqValue,
    required this.tokenValue,
    required this.totalSupply,
    required this.share,
    required this.reserveAmountZeniq,
    required this.reserveAmountToken,
    required this.valueLocked,
  });

  @override
  String toString() {
    return 'Position(share: ${share} liquidity: ${liquidity.displayDouble}, zeniqValue: $zeniqValue, tokenValue: $tokenValue)';
  }
}
