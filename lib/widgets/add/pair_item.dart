import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/utils/max_percission.dart';

class PairItem extends ConsumerWidget {
  final Pair pair;
  const PairItem({required this.pair, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zeniqAsyncImage = ref
        .watch(assetNotifierProvider)
        .imageNotifierForToken(pair.tokeWZeniq)!;
    final tokenAsyncImage =
        ref.watch(assetNotifierProvider).imageNotifierForToken(pair.token)!;

    return ListenableBuilder(
      listenable: Listenable.merge([zeniqAsyncImage, tokenAsyncImage]),
      builder: (context, child) {
        final zeniqImage = zeniqAsyncImage.value;
        final tokenImage = tokenAsyncImage.value;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 62,
                height: 35,
                child: Stack(
                  children: [
                    zeniqImage.when(
                      data: (data) => Positioned(
                        left: 0,
                        child: ClipOval(
                          child: Image.network(
                            data.small,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => Text(
                        error.toString(),
                      ),
                      loading: () => CircularProgressIndicator(
                        color: context.theme.colors.primary,
                      ),
                    ),
                    tokenImage.when(
                      data: (data) => Positioned(
                        left: 30,
                        child: ClipOval(
                          child: Image.network(
                            data.small,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => Text(
                        error.toString(),
                      ),
                      loading: () => CircularProgressIndicator(
                        color: context.theme.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              16.hSpacing,
              NomoText(
                "${pair.tokeWZeniq.symbol}/${pair.token.symbol}",
                style: context.typography.b1,
              ),
              Spacer(),
              NomoText(
                maxLines: 2,
                fit: true,
                pair.balanceToken!.displayDouble
                    .toMaxPrecisionWithoutScientificNotation(5),
                style: context.typography.b2,
              )
            ],
          ),
        );
      },
    );
  }
}
