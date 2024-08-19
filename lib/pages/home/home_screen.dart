import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/loading/shimmer/shimmer.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/widgets/pool_overview.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairsProvider = ref.watch(pairNotifierProvider);

    return NomoScaffold(
      appBar: NomoAppBar(
        title: NomoText(
          "Pools",
          style: context.typography.h2,
        ),
      ),
      child: Shimmer(
        child: NomoRouteBody(
          padding: const EdgeInsets.all(16),
          backgroundColor: context.theme.colors.background1,
          child: pairsProvider.when(
            data: (pairs) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 240,
                        child: NomoText(
                          "Pair",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "TVL",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "APR",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "Volume 24h",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "Fees 24h",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "Token Price",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "Zeniq Value Locked",
                          style: context.typography.b2,
                        ),
                      ),
                      32.hSpacing,
                      SizedBox(
                        width: 100,
                        child: NomoText(
                          "Token Value Locked",
                          style: context.typography.b2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: pairs.length,
                    itemBuilder: (context, index) {
                      return PoolOverview(
                        pair: pairs[index],
                      );
                    },
                  ),
                ),
              ],
            ),
            error: (error, _) => NomoText(
              error.toString(),
              style: context.typography.h2,
              color: context.theme.colors.error,
            ),
            loading: () => Center(
              child: CircularProgressIndicator(
                color: context.theme.colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
