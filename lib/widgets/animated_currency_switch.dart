import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';

class AnimatedCurrencySwitch extends ConsumerWidget {
  const AnimatedCurrencySwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetNotifier = ref.watch(assetNotifierProvider);
    final currentCurrency = assetNotifier.currency;

    return GestureDetector(
      onTap: () {
        final newCurrency =
            currentCurrency == Currency.usd ? Currency.eur : Currency.usd;
        assetNotifier.currencyNotifier.value = newCurrency;
        ref.invalidate(pairNotifierProvider);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.theme.colors.background2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.theme.colors.primary, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CurrencySymbol(
              symbol: '\$',
              isActive: currentCurrency == Currency.usd,
            ),
            SizedBox(width: 8),
            _AnimatedSwitch(isRight: currentCurrency == Currency.eur),
            SizedBox(width: 8),
            _CurrencySymbol(
              symbol: '€',
              isActive: currentCurrency == Currency.eur,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySymbol extends StatelessWidget {
  final String symbol;
  final bool isActive;

  const _CurrencySymbol({
    required this.symbol,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isActive
            ? context.theme.colors.primary
            : context.theme.colors.onDisabled,
      ),
      child: Text(symbol),
    );
  }
}

class _AnimatedSwitch extends StatelessWidget {
  final bool isRight;

  const _AnimatedSwitch({required this.isRight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
        color: context.theme.colors.background1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: context.theme.colors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
