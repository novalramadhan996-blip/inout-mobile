import 'package:chat/core/resources/network/http_service.dart';
import 'package:chat/core/resources/network/rest_client.dart';
import 'package:chat/core/resources/storage/shared_preference_service.dart';
import 'package:chat/repositories/repository.dart';
import 'package:chat/repositories/repository_google_map.dart';
import 'package:chat/viewmodel/chat_view_model.dart';
import 'package:chat/viewmodel/group_list_view_model.dart';
import 'package:chat/viewmodel/map_view_model.dart';
import 'package:chat/viewmodel/user_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;
late final Alice alice;
late final GlobalKey<NavigatorState> aliceNavigatorKey;

Future<void> initilizeDi(GlobalKey<NavigatorState>? navigatorKey) async {
  aliceNavigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
  sl.registerLazySingleton<GlobalKey<NavigatorState>>(
      () => aliceNavigatorKey);
  sl.registerLazySingleton<SharedPreferenceService>(
      () => SharedPreferenceService());
  alice = Alice(
      navigatorKey: aliceNavigatorKey,
      showNotification: true,
      showInspectorOnShake: true);
  alice.setNavigatorKey(aliceNavigatorKey);
  sl.registerLazySingleton<Alice>(() => alice);
  sl.registerLazySingleton<HttpService>(() => HttpService(alice: alice));
  sl.registerSingleton<RestClient>(
    RestClient(sl<HttpService>().dio),
    instanceName: 'dio',
  );
  sl.registerLazySingleton<Repository>(
      () => Repository(restClient: sl<RestClient>(instanceName: 'dio')));
  sl.registerLazySingleton<UserListViewModel>(
      () => UserListViewModel(sl<Repository>()));
  sl.registerLazySingleton<GroupListViewModel>(
      () => GroupListViewModel(sl<Repository>()));
  sl.registerLazySingleton<ChatViewModel>(
      () => ChatViewModel(sl<Repository>()));

  sl.registerSingleton<RestClient>(
    RestClient(sl<HttpService>().dioMapGoogle),
    instanceName: 'dioMapGoogle',
  );
  sl.registerLazySingleton<RepositoryGoogleMap>(() => RepositoryGoogleMap(
      restClient: sl<RestClient>(instanceName: 'dioMapGoogle')));

  sl.registerSingleton<RestClient>(
    RestClient(sl<HttpService>().dioMock),
    instanceName: 'dioMock',
  );
  sl.registerLazySingleton<MapViewModel>(
      () => MapViewModel(sl<RepositoryGoogleMap>()));
}
