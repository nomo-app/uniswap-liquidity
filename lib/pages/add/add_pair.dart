import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_router/router/nomo_navigator.dart';
import 'package:nomo_ui_kit/components/app/app_bar/nomo_app_bar.dart';
import 'package:nomo_ui_kit/components/app/routebody/nomo_route_body.dart';
import 'package:nomo_ui_kit/components/app/scaffold/nomo_scaffold.dart';
import 'package:nomo_ui_kit/components/text/nomo_text.dart';
import 'package:nomo_ui_kit/theme/nomo_theme.dart';
import 'package:uniswap_liquidity/provider/asset_provider.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:uniswap_liquidity/provider/token_balance_provider.dart';
import 'package:uniswap_liquidity/utils/rpc.dart';
import 'package:uniswap_liquidity/widgets/add/add_pair_box.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

class AddPair extends ConsumerWidget {
  final ERC20Entity? token;

  const AddPair({this.token, super.key}) : assert(token != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceToken = ref.watch(tokenBalanceNotifierProvider(token!));

    if (token == null) {
      NomoNavigator.of(context).pop();
      return SizedBox.shrink();
    }

    ref.read(assetNotifierProvider).addToken(zeniqWrapperToken);

    return NomoScaffold(
      appBar: NomoAppBar(
        leading: BackButton(
          color: context.theme.colors.foreground1,
        ),
        title: NomoText(
          "Add Pair",
          style: context.typography.h1,
        ),
      ),
      child: NomoRouteBody(
        maxContentWidth: 600,
        child: balanceToken.when(
          data: (data) {
            final Pair createPair = Pair(
              tokeWZeniq: zeniqWrapperToken,
              volume24h: null,
              fees24h: null,
              apr: null,
              token: token!,
              contract: UniswapV2Pair(contractAddress: "asdasd", rpc: rpc),
              reserves: (BigInt.zero, BigInt.zero),
              tvl: 0,
              zeniqFiatValue: 0,
              tokenFiatValue: 0,
              tokenPrice: 0,
              zeniqPrice: 0,
              balanceToken: data,
              fiatBlanceToken: null,
              fiatZeniqBalance: null,
              tokenPerZeniq: 0,
              zeniqPerToken: 0,
              position: null,
              zeniqValue: Amount.zero,
              tokenValue: Amount.zero,
            );

            return Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: SingleChildScrollView(
                child: AddPairBox(selectedPool: createPair),
              ),
            );
          },
          error: (error, stackTrace) => NomoText(error.toString()),
          loading: () => CircularProgressIndicator(),
        ),
        // child: AddLiquidityBox(
        //   selectedPool: createPair,
        //   showPositionBox: false,
        // ),
      ),
    );
  }
}
