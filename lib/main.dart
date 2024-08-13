import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/app/nomo_app.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/theme.dart';

final appRouter = AppRouter();

void main() {
  usePathUrlStrategy();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NomoNavigator(
      delegate: appRouter.delegate,
      child: NomoApp(
        themeDelegate: AppThemeDelegate(),
        routerConfig: appRouter.config,
        color: const Color(0xFF1A1A1A),
        supportedLocales: const [Locale('en', 'US')],
      ),
    );
  }
}
