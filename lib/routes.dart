import 'package:flutter/widgets.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:route_gen/anotations.dart';
import 'package:uniswap_liquidity/pages/add/add_pair.dart';
import 'package:uniswap_liquidity/pages/add/add_screen.dart';
import 'package:uniswap_liquidity/pages/details/details_screen.dart';
import 'package:uniswap_liquidity/pages/home/home_screen.dart';
import 'package:uniswap_liquidity/provider/model/pair.dart';
import 'package:walletkit_dart/walletkit_dart.dart';

part "routes.g.dart";

@AppRoutes()
const _routes = [
  MenuPageRouteInfo(
    path: '/',
    page: HomeScreen,
    title: 'Home',
  ),
  MenuPageRouteInfo(
    page: DetailsScreen,
    path: '/details',
    title: 'Details',
  ),
  MenuPageRouteInfo(
    path: "/add",
    page: AddScreen,
    title: "Add",
  ),
  MenuPageRouteInfo(
    path: "/addPair",
    page: AddPair,
    title: "AddPair",
  ),
];
