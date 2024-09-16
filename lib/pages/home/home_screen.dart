import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
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
    final showAllPools = useState(false);

    return NomoScaffold(
      appBar: NomoAppBar(
        title: NomoText(
          "Positions",
          style: context.typography.h1,
        ),
        // trailling: PrimaryNomoButton(
        //   borderRadius: BorderRadius.circular(8),
        //   padding: EdgeInsets.symmetric(
        //     horizontal: 16,
        //     vertical: 8,
        //   ),
        //   onPressed: () async {
        //     final pair = await showDialog(
        //       context: context,
        //       builder: (context) => SuccessDialog(
        //           messageHex: "0x04358de9c80fa9e3e0185e25a513c08f97610720"),
        //     );
        //     if (pair == null) return;
        //     // ignore: use_build_context_synchronously
        //     // NomoNavigator.of(context).push(AddScreenRoute(pair: pair));
        //   },
        //   text: "Add Liquidity",
        //   textStyle: context.typography.b1,
        // ),
      ),
      child: NomoRouteBody(
        padding: const EdgeInsets.all(16),
        backgroundColor: context.theme.colors.background1,
        child: pairsProvider.when(
          data: (pairs) {
            final positionPairs =
                pairs.where((element) => element.position != null).toList();
            final allPools =
                pairs.where((element) => element.position == null).toList();

            if (positionPairs.isEmpty) {
              showAllPools.value = true;
            }

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
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    PrimaryNomoButton(
                      borderRadius: BorderRadius.circular(8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: showAllPools.value
                          ? context.theme.colors.background2
                          : context.theme.colors.primary,
                      onPressed: () {
                        showAllPools.value = false;
                      },
                      text: "My Pools",
                      textStyle: context.typography.b1,
                    ),
                    16.hSpacing,
                    PrimaryNomoButton(
                      borderRadius: BorderRadius.circular(8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: showAllPools.value
                          ? context.theme.colors.primary
                          : context.theme.colors.background2,
                      onPressed: () {
                        showAllPools.value = true;
                      },
                      text: "All Pools",
                      textStyle: context.typography.b1,
                    ),
                  ],
                ),
                16.vSpacing,
                Expanded(
                  child: ListView.builder(
                    itemCount: showAllPools.value
                        ? allPools.length
                        : positionPairs.length,
                    itemBuilder: (context, index) {
                      final pair = showAllPools.value
                          ? allPools[index]
                          : positionPairs[index];
                      return PoolOverview(pair: pair);
                    },
                  ),
                ),
              ],
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
