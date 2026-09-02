part of 'router_import.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),

    // Auth
    AutoRoute(page: SignInRoute.page),
    AutoRoute(page: SignUpRouteNew.page),
    AutoRoute(page: SignUpRouteOri.page),
    AutoRoute(page: OtpRoute.page),
    AutoRoute(page: RegisterFaceRoute.page),

    // Profile
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: FaceregistrationRoute.page),
    AutoRoute(page: FaceregistrationRegisterRoute.page),
    AutoRoute(page: ProfileUser.page),

    // Chat
    AutoRoute(page: ChatRoomRoute.page),

    // Checkin And Chenckout
    AutoRoute(page: CheckInRoute.page),
    AutoRoute(page: CheckInSubmitRoute.page),
    AutoRoute(page: CheckOutSubmitRoute.page),

    // Maps
    AutoRoute(page: MapRoute.page),

    // History
    AutoRoute(page: HistoryRoute.page),
    AutoRoute(page: DetailHistory.page),
    AutoRoute(page: GroupListRoute.page),

    // Change Password
    AutoRoute(page: ChangePasswordRoute.page),

    // Home
    AutoRoute(
      path: '/main-page',
      page: MainRoute.page,
      children: [
        // AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'home_page_v2', page: HomeRouteV2.page),
        AutoRoute(path: 'calendar', page: CalendarRoute.page),
        AutoRoute(path: 'chat', page: ChatRoute.page),
        // AutoRoute(path: 'ChatScreenRoute', page: autoroute.ChatRoute.page), // disable page chat because not already to test
        AutoRoute(path: 'todo', page: TodoRoute.page),
      ],
    ),

    //Home Reservation
    AutoRoute(page: HomeReservationRoute.page),
    AutoRoute(page: ReservationListRoute.page),
    AutoRoute(page: GuestListRoute.page),

    // Forgot Password
    AutoRoute(page: ForgotPasswordUsername.page),
    AutoRoute(page: ForgotPasswordPass.page),

    // Todo Pages
    AutoRoute(page: BoardRoute.page),
    AutoRoute(page: TaskRoute.page),

    // Setting Pages
    AutoRoute(page: SettingRoute.page),
    AutoRoute(page: ReminderAbsensiRoute.page),
    AutoRoute(page: DeviceInfoRoute.page),

    // Report Activity Pages
    AutoRoute(page: ReportActivityRoute.page),
    AutoRoute(page: ListReportActivityRoute.page),

    // Checkin
    AutoRoute(page: AbsenceRoute.page),

    // chat
    AutoRoute(page: autoroute.ChatDetailRoute.page),

    // calendar
    AutoRoute(page: CreateEventRoute.page),
    AutoRoute(page: DetailEventRoute.page),
    AutoRoute(page: CheckinMeetingRoute.page),
    AutoRoute(page: QrCodeMeetingRoute.page),
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
    LogHelper.logDebug(
      '🚀/ Push Route: ${route.data?.path}'
      'time: ${DateTime.now()}'
      'name: Route',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    LogHelper.logDebug(
      '🔫/ Pop Route: ${route.data?.path}'
      'time: ${DateTime.now()}'
      'name: Route',
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    LogHelper.logDebug(
      '❌/ Remove Route: ${route.data?.path}'
      'time: ${DateTime.now()}'
      'name: Route',
    );
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    LogHelper.logDebug(
      '🔁/ Replace Route: ${newRoute?.settings.name}'
      'time: ${DateTime.now()}'
      'name: Route',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    LogHelper.logDebug(
      '🙌/ User Gesture: ${route.data?.path}'
      'time: ${DateTime.now()}'
      'name: Route',
    );
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    LogHelper.logDebug(
      '🛑/ User Gesture Stopped'
      'time: ${DateTime.now()}'
      'name: Route',
    );
    super.didStopUserGesture();
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    LogHelper.logDebug('👀/ Route Visited: ${route.name} name: Route');
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    LogHelper.logDebug('/ Route Re-visited: ${route.name} name: Route');
  }
}
