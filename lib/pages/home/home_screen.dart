import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/router/nomo_navigator.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/widgets/add/select_dialog.dart';
import 'package:uniswap_liquidity/widgets/pool_overview.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairsProvider = ref.watch(pairNotifierProvider);

    return NomoScaffold(
      appBar: NomoAppBar(
        title: NomoText(
          "Positions",
          style: context.typography.h1,
        ),
        trailling: PrimaryNomoButton(
          borderRadius: BorderRadius.circular(8),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          onPressed: () async {
            final pair = await showDialog(
              context: context,
              builder: (context) => SelectDialog(),
            );
            if (pair == null) return;
            // ignore: use_build_context_synchronously
            NomoNavigator.of(context).push(AddScreenRoute(pair: pair));
          },
          text: "Add Liquidity",
          textStyle: context.typography.b1,
        ),
      ),
      child: NomoRouteBody(
        padding: const EdgeInsets.all(16),
        backgroundColor: context.theme.colors.background1,
        child: pairsProvider.when(
          data: (pairs) {
            final positionPairs =
                pairs.where((element) => element.position != null).toList();

            if (positionPairs.isEmpty) {
              return Column(
                children: [
                  NomoText(
                    "No positions found",
                    style: context.typography.b2,
                  ),
                  12.vSpacing,
                  NomoText(
                    "Add liquidity to a pool to see your positions",
                    style: context.typography.b2,
                  ),
                  PrimaryNomoButton(
                    padding: EdgeInsets.all(
                      8,
                    ),
                    onPressed: () {
                      // Navigator.of(context).pushNamed("/add");
                    },
                    text: "Add Liquidity",
                    textStyle: context.typography.b2,
                  )
                ],
              );
            }
            return ListView.builder(
              itemCount: positionPairs.length,
              itemBuilder: (context, index) {
                final pair = positionPairs[index];
                return PoolOverview(pair: pair);
              },
            );
          },
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
