import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
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
          style: context.typography.h1,
        ),
      ),
      child: NomoRouteBody(
        padding: const EdgeInsets.all(16),
        backgroundColor: context.theme.colors.background1,
        child: pairsProvider.when(
          data: (pairs) => ListView.builder(
            itemCount: pairs.length,
            itemBuilder: (context, index) {
              return PoolOverview(
                pair: pairs[index],
              );
            },
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
    );
  }
}
