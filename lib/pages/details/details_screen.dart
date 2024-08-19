import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';

class DetailsScreen extends HookConsumerWidget {
  const DetailsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NomoScaffold(
      appBar: NomoAppBar(
        leading: BackButton(
          color: context.theme.colors.foreground1,
        ),
        title: NomoText("Details"),
      ),
      child: NomoRouteBody(
        child: Container(
          child: Text("Details Screen"),
        ),
      ),
    );
  }
}
