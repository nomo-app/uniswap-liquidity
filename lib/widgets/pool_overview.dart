import 'package:flutter/material.dart';
import 'package:nomo_ui_kit/components/card/nomo_card.dart';
import 'package:nomo_ui_kit/utils/layout_extensions.dart';
import 'package:uniswap_liquidity/provider/pair_provider.dart';

class PoolOverview extends StatelessWidget {
  final Pair pair;
  const PoolOverview({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    return NomoCard(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                color: Colors.red,
              ),
              Container(
                height: 100,
                width: 100,
                color: Colors.blue,
              ),
            ],
          ),
          12.vSpacing,
        ],
      ),
    );
  }
}
