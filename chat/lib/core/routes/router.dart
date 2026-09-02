part of 'router_import.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoadingRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: ChatDetailRoute.page),
      ];
}

class RouterObserver extends AutoRouterObserver {
  final Map<Route, List<RouteAware>> _listeners = {};

  void subscribe(RouteAware routeAware, Route route) {
    if (_listeners[route] == null) {
      _listeners[route] = [];
    }
    if (!_listeners[route]!.contains(routeAware)) {
      _listeners[route]!.add(routeAware);
    }
  }

  void unsubscribe(RouteAware routeAware) {
    for (final entry in _listeners.entries) {
      entry.value.remove(routeAware);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    log(
      '🚀/ Push Route: ${route.data?.path}',
      time: DateTime.now(),
      name: "Route",
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    log(
      '🔫/ Pop Route: ${route.data?.path}',
      time: DateTime.now(),
      name: "Route",
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    log(
      '❌/ Remove Route: ${route.data?.path}',
      time: DateTime.now(),
      name: "Route",
    );
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    log(
      '🔁/ Replace Route: ${newRoute?.settings.name}',
      time: DateTime.now(),
      name: "Route",
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    log(
      '🙌/ User Gesture: ${route.data?.path}',
      time: DateTime.now(),
      name: "Route",
    );
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    log('🛑/ User Gesture Stopped', time: DateTime.now(), name: "Route");
    super.didStopUserGesture();
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    log('👀/ Route Visited: ${route.name}', name: "Route");
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    log('/ Route Re-visited: ${route.name}', name: "Route");
  }
}
