import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/router/nomo_navigator.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';

class RemoveScreen extends ConsumerWidget {
  final Pair? pair;
  const RemoveScreen({this.pair, super.key})
      : assert(pair != null, 'pair must not be null');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pair == null) {
      NomoNavigator.of(context).pop();
      return SizedBox.shrink();
    }

    return NomoScaffold(
      appBar: NomoAppBar(
        leading: BackButton(
          color: context.theme.colors.foreground1,
        ),
        title: NomoText(
          "Remove Old Liquidity",
          style: context.typography.h1,
        ),
      ),
      child: NomoRouteBody(
        maxContentWidth: 600,
      ),
    );
  }
}
