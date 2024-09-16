import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/app/nomo_app.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/theme.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

final appRouter = AppRouter();
var address = "";
Amount zeniqBalance = Amount.zero;

void main() async {
  usePathUrlStrategy();

  try {
    if (WebonKitDart.isFallBackMode() && kDebugMode == false) {
      throw Exception("Not inside the NomoApp");
    }

    address = await WebonKitDart.getEvmAddress();
    zeniqBalance = await rpc.fetchTokenBalance(address, zeniqETHToken);
    print('EVM address: $address');
  } catch (e) {
    print(e);
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NomoDefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 32),
          child: Scaffold(
            backgroundColor: Colors.black87,
            body: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 96.0,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 24.0),
                    const NomoText(
                      'Not inside the NomoApp. Please use zeniqswap.com for providing liquidity in the browser.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    const NomoText(
                      'Or download the Nomo App from the App Store or Google Play Store.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 64.0),
                    PrimaryNomoButton(
                      text: "Download Nomo App",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      elevation: 10,
                      height: 64,
                      borderRadius: BorderRadius.circular(12),
                      padding: EdgeInsets.zero,
                      width: 320,
                      onPressed: () async {
                        await launchUrlString("https://nomo.app/install");
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
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
