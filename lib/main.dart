import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_ui_kit/app/nomo_app.dart';
import 'package:nomo_ui_kit/components/buttons/primary/nomo_primary_button.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/routes.dart';
import 'package:uniswap_liquidity/theme.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletkit_dart/walletkit_dart.dart';
import 'package:webon_kit_dart/webon_kit_dart.dart';

final appRouter = AppRouter();
var address = "";
Amount zeniqBalance = Amount.zero;
const deeplink = 'https://nomo.app/webon/liquidity.zeniqswap.com';

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
    final textStyle = GoogleFonts.roboto(
      color: Colors.white,
      fontSize: 16,
    );
    print(e);
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NomoDefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 32),
          child: Builder(builder: (context) {
            return Scaffold(
              backgroundColor: Colors.black,
              extendBodyBehindAppBar: true,
              body: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 32,
                        ),
                        child: NomoCard(
                          backgroundColor: Color(0xff1e2428).withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Zeniq Pools',
                                style: GoogleFonts.dancingScript(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      Center(
                        child: NomoCard(
                          backgroundColor: Color(0xff1e2428).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 48),
                          child: SizedBox(
                            width: 380,
                            child: Column(
                              children: [
                                Text(
                                  "Coming Soon",
                                  style: GoogleFonts.roboto().copyWith(
                                    fontSize: 36,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 32.0),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(16),
                                  width: 200,
                                  height: 200,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await launchUrlString(
                                        'https://nomo.app/webon/liquidity.zeniqswap.com',
                                      );
                                    },
                                    child: BarcodeWidget(
                                      data: deeplink,
                                      color: Colors.black,
                                      barcode: Barcode.fromType(
                                        BarcodeType.QrCode,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32.0),
                                Text(
                                  'Not inside the NomoApp. Please use zeniqswap.com for providing liquidity in the browser.',
                                  textAlign: TextAlign.center,
                                  style: textStyle,
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'Or download the Nomo App from the App Store or Google Play Store.',
                                  textAlign: TextAlign.center,
                                  style: textStyle,
                                ),
                                const SizedBox(height: 32.0),
                                PrimaryNomoButton(
                                  text: "Download Nomo App",
                                  textStyle: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                  elevation: 0,
                                  height: 64,
                                  backgroundColor: primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                  padding: EdgeInsets.zero,
                                  width: 320,
                                  onPressed: () async {
                                    await launchUrlString(deeplink);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            );
          }),
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
