import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/dropdownmenu/drop_down_item.dart';
import 'package:nomo_ui_kit/components/dropdownmenu/dropdownmenu.dart';
import 'package:nomo_ui_kit/components/input/textInput/nomo_input.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';
import 'package:uniswap_liquidity/provider/show_all_pools_provider.dart';
import 'package:uniswap_liquidity/utils/price_repository.dart';
import 'package:uniswap_liquidity/widgets/animated_expandable.dart';
import 'package:uniswap_liquidity/widgets/pool_overview.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAllPools = ref.watch(showAllPoolsProvider);
    final pairsProvider = ref.watch(pairNotifierProvider);
    final showLowTVLPools = useState(false);
    final searchNotifier = useState('');
    final searchTerm = useState('');
    final assetNotifier = ref.watch(assetNotifierProvider);
    final currentCurrency = assetNotifier.currency;

    useEffect(() {
      void listener() {
        searchTerm.value = searchNotifier.value.toLowerCase();
      }

      searchNotifier.addListener(listener);
      return () => searchNotifier.removeListener(listener);
    }, [searchNotifier]);

    return NomoScaffold(
      appBar: NomoAppBar(
        title: NomoText(
          "Liquidity",
          style: context.typography.h1,
        ),
      ),
      child: NomoRouteBody(
        padding: const EdgeInsets.all(16),
        backgroundColor: context.theme.colors.background1,
        child: pairsProvider.when(
          data: (pairs) {
            final filteredPairs = pairs
                .where((pair) =>
                    pair.token.symbol.toLowerCase().contains(searchTerm.value))
                .toList();

            final positionPairs = filteredPairs
                .where((element) => element.position != null)
                .toList();
            positionPairs.sort((a, b) =>
                b.position!.valueLocked.compareTo(a.position!.valueLocked));
            filteredPairs.sort((a, b) => b.tvl.compareTo(a.tvl));

            final highTVLPairs =
                filteredPairs.where((p) => p.tvl >= 100).toList();
            final lowTVLPairs =
                filteredPairs.where((p) => p.tvl < 100).toList();

            return Column(
              children: [
                Row(
                  children: [
                    PrimaryNomoButton(
                      borderRadius: BorderRadius.circular(8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: showAllPools
                          ? context.theme.colors.background2
                          : context.theme.colors.primary,
                      onPressed: () {
                        if (showAllPools) {
                          ref.read(showAllPoolsProvider.notifier).toggle();
                        }

                        showLowTVLPools.value = false;
                      },
                      text: "My Pools",
                      textStyle: context.typography.b1,
                    ),
                    16.hSpacing,
                    PrimaryNomoButton(
                      borderRadius: BorderRadius.circular(8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: showAllPools
                          ? context.theme.colors.primary
                          : context.theme.colors.background2,
                      onPressed: () {
                        if (!showAllPools) {
                          ref.read(showAllPoolsProvider.notifier).toggle();
                        }
                      },
                      text: "All Pools",
                      textStyle: context.typography.b1,
                    ),
                    Spacer(),
                    NomoDropDownMenu(
                      width: 124,
                      borderRadius: BorderRadius.circular(8),
                      dropdownColor: context.theme.colors.background2,
                      backgroundColor: context.theme.colors.background2,
                      iconColor: context.theme.colors.primary,
                      itemPadding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      initialValue: currentCurrency,
                      onChanged: (value) {
                        final newCurrency = currentCurrency == Currency.usd
                            ? Currency.eur
                            : Currency.usd;
                        assetNotifier.currencyNotifier.value = newCurrency;
                        ref.read(pairNotifierProvider.notifier).softUpdate();
                      },
                      itemHeight: 28,
                      items: [
                        NomoDropdownItemWidget(
                          value: Currency.eur,
                          widget: NomoText(
                            "${Currency.eur.displayName} ${Currency.eur.symbol}",
                            style: context.typography.b1,
                          ),
                        ),
                        NomoDropdownItemWidget(
                          value: Currency.usd,
                          widget: NomoText(
                            "${Currency.usd.displayName} ${Currency.usd.symbol}",
                            style: context.typography.b1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                16.vSpacing,
                NomoInput(
                  // controller: searchController,
                  valueNotifier: searchNotifier,
                  placeHolder: "Search pools...",
                  placeHolderStyle: context.typography.b1,
                  borderRadius: BorderRadius.circular(8),
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.search,
                      color: context.theme.colors.foreground1,
                    ),
                  ),
                  style: context.typography.b1,
                ),
                16.vSpacing,
                if (filteredPairs.isEmpty) ...[
                  NomoText(
                    "No pools found",
                    style: context.typography.b2,
                  ),
                ] else if (positionPairs.isEmpty && !showAllPools) ...[
                  NomoText(
                    "No positions found",
                    style: context.typography.b2,
                  ),
                  12.vSpacing,
                  NomoText(
                    "Add liquidity to a pool to see your positions",
                    style: context.typography.b2,
                  ),
                ] else ...[
                  Expanded(
                    child: ListView(
                      children: [
                        ...showAllPools
                            ? highTVLPairs.map((pair) => PoolOverview(
                                  pair: pair,
                                ))
                            : positionPairs.map((pair) => PoolOverview(
                                  pair: pair,
                                )),
                        if (showAllPools && lowTVLPairs.isNotEmpty)
                          AnimatedExpandableRow(
                            isExpanded: showLowTVLPools.value,
                            lowTVLPoolsCount: lowTVLPairs.length,
                            onTap: () {
                              showLowTVLPools.value = !showLowTVLPools.value;
                            },
                          ),
                        if (showAllPools && showLowTVLPools.value)
                          ...lowTVLPairs.map((pair) => PoolOverview(
                                pair: pair,
                              )),
                      ],
                    ),
                  ),
                ],
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
