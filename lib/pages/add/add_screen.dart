import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/selected_pool_provider.dart';
import 'package:uniswap_liquidity/widgets/add/add_liquidity_box.dart';

class AddScreen extends ConsumerWidget {
  final Pair? pair;

  const AddScreen({this.pair, super.key})
      : assert(pair != null, 'pair must not be null');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPool = ref.watch(selectedPoolProvider(pair!));
    return NomoScaffold(
      appBar: NomoAppBar(
        leading: BackButton(
          color: context.theme.colors.foreground1,
        ),
        title: NomoText(
          "Add Liquidity",
          style: context.typography.h1,
        ),
      ),
      child: NomoRouteBody(
        child: selectedPool.when(
          data: (pair) => Padding(
            padding: const EdgeInsets.only(top: 64, left: 12, right: 12),
            child: AddLiquidityBox(selectedPool: pair),
          ),
          error: (error, stackTrace) => NomoText(error.toString()),
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
