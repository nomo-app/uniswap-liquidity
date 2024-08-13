import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/app/nomo_app.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/theme.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

final appRouter = AppRouter();

void main() async {
  usePathUrlStrategy();
  final String address;

  try {
    if (WebonKitDart.isFallBackMode()) {
      print('Fallback mode is active');
    }

    address = await WebonKitDart.getEvmAddress();
    print('EVM address: $address');
  } catch (e) {
    print(e);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
