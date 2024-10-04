import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/token_balance_provider.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class TokenItem extends HookConsumerWidget {
  final ERC20Entity token;
  const TokenItem({required this.token, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(assetNotifierProvider).addToken(token);

    final tokenAsyncImage =
        ref.watch(assetNotifierProvider).imageNotifierForToken(token)!;

    final tokenBalance = ref.watch(tokenBalanceNotifierProvider(token));

    return ListenableBuilder(
      listenable: Listenable.merge([tokenAsyncImage]),
      builder: (context, child) {
        final tokenImage = tokenAsyncImage.value;

        return tokenBalance.when(
          data: (data) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                tokenImage.when(
                  data: (data) => ClipOval(
                    child: Image.network(
                      data.small,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    error.toString(),
                  ),
                  loading: () => CircularProgressIndicator(
                    color: context.theme.colors.primary,
                  ),
                ),
                16.hSpacing,
                NomoText(
                  token.symbol,
                  style: context.typography.b1,
                ),
                Spacer(),
                NomoText(
                  maxLines: 2,
                  fit: true,
                  data.displayDouble.formatTokenBalance(),
                  style: context.typography.b1,
                )
              ],
            ),
          ),
          error: (error, stackTrace) => NomoText(
            error.toString(),
            style: context.typography.b1,
          ),
          loading: () => SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: context.theme.colors.primary,
            ),
          ),
        );
      },
    );
  }
}
