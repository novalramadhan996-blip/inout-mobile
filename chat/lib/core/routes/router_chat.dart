import 'package:auto_route/auto_route.dart';

import 'package:chat/core/routes/router_import.gr.dart';

@AutoRouterConfig()
class ChatRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes =>
      [AutoRoute(page: ChatRoute.page), AutoRoute(page: ChatDetailRoute.page)];
}
