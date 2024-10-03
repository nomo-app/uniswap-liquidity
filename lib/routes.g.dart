// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

class AppRouter extends NomoAppRouter {
  final Future<bool> Function()? shouldPop;
  final Future<bool> Function()? willPop;
  late final RouterConfig<Object> config;
  late final NomoRouterDelegate delegate;
  AppRouter({this.shouldPop, this.willPop})
      : super(
          {
            HomeScreenRoute.path: ([a]) => HomeScreenRoute(),
            DetailsScreenRoute.path: ([a]) {
              final typedArgs = a as DetailsScreenArguments?;
              return DetailsScreenRoute(
                pair: typedArgs?.pair,
              );
            },
            AddScreenRoute.path: ([a]) {
              final typedArgs = a as AddScreenArguments?;
              return AddScreenRoute(
                pair: typedArgs?.pair,
              );
            },
            AddPairRoute.path: ([a]) {
              final typedArgs = a as AddPairArguments?;
              return AddPairRoute(
                token: typedArgs?.token,
              );
            },
          },
          _routes.expanded.where((r) => r is! NestedNavigator).toList(),
          _routes.expanded.whereType<NestedNavigator>().toList(),
        ) {
    delegate = NomoRouterDelegate(appRouter: this);
    config = RouterConfig(
        routerDelegate: delegate,
        backButtonDispatcher:
            NomoBackButtonDispatcher(delegate, shouldPop, willPop),
        routeInformationParser: const NomoRouteInformationParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            uri:
                WidgetsBinding.instance.platformDispatcher.defaultRouteName.uri,
          ),
        ));
  }
}

class HomeScreenArguments {
  const HomeScreenArguments();
}

class HomeScreenRoute extends AppRoute implements HomeScreenArguments {
  HomeScreenRoute()
      : super(
          name: '/',
          page: HomeScreen(),
        );
  static String path = '/';
}

class DetailsScreenArguments {
  final Pair? pair;
  const DetailsScreenArguments({
    this.pair,
  });
}

class DetailsScreenRoute extends AppRoute implements DetailsScreenArguments {
  @override
  final Pair? pair;
  DetailsScreenRoute({
    this.pair,
  }) : super(
          name: '/details',
          page: DetailsScreen(
            pair: pair,
          ),
        );
  static String path = '/details';
}

class AddScreenArguments {
  final Pair? pair;
  const AddScreenArguments({
    this.pair,
  });
}

class AddScreenRoute extends AppRoute implements AddScreenArguments {
  @override
  final Pair? pair;
  AddScreenRoute({
    this.pair,
  }) : super(
          name: '/add',
          page: AddScreen(
            pair: pair,
          ),
        );
  static String path = '/add';
}

class AddPairArguments {
  final ERC20Entity? token;
  const AddPairArguments({
    this.token,
  });
}

class AddPairRoute extends AppRoute implements AddPairArguments {
  @override
  final ERC20Entity? token;
  AddPairRoute({
    this.token,
  }) : super(
          name: '/addPair',
          page: AddPair(
            token: token,
          ),
        );
  static String path = '/addPair';
}
