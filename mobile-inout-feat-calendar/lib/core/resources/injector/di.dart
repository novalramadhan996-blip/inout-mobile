import 'package:chat/core/resources/storage/shared_preference_service.dart';
import 'package:chat/core/route_change_notifier.dart';
import 'package:chat/viewmodel/chat_view_model.dart';
import 'package:chat/viewmodel/group_list_view_model.dart';
import 'package:chat/viewmodel/user_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/local/camera_service.dart';
import 'package:mobile_in_out/core/resources/local/face_detector_service.dart';
import 'package:mobile_in_out/core/resources/local/ml_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/network/http_service.dart';
import 'package:mobile_in_out/core/resources/network/rest_client.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/localizations/locale_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider_old.dart';
import 'package:mobile_in_out/feature/board/provider/board_provider.dart';
import 'package:mobile_in_out/feature/change_password/provider/change_password_provider.dart';
import 'package:mobile_in_out/feature/forgot_password/provider/reset_password_provider.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/home_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/organization_provider.dart';
import 'package:mobile_in_out/feature/maps/provider/map_provider.dart';
import 'package:mobile_in_out/feature/profile/providers/profile_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:mobile_in_out/feature/todo/provider/todo_provider.dart';
import 'package:chat/core/resources/network/http_service.dart' as HttpServ;
import 'package:chat/core/resources/network/rest_client.dart' as RestCl;
import 'package:chat/repositories/repository.dart' as Repo;

final sl = GetIt.instance;

Future<void> initilizeDi() async {
  sl.registerLazySingleton<GlobalKey<NavigatorState>>(
    () => GlobalKey<NavigatorState>(),
  );
  sl.registerLazySingleton<SharedPreferenceService>(
    () => SharedPreferenceService(),
  );
  sl.registerLazySingleton<Alice>(
    () => Alice(
      showNotification: true,
      showInspectorOnShake: true,
      navigatorKey: sl<GlobalKey<NavigatorState>>(),
    ),
  );
  sl.registerLazySingleton<ShardPrefService>(() => ShardPrefService());
  sl.registerLazySingleton<LocaleProvider>(
    () => LocaleProvider(sl<ShardPrefService>()),
  );

  sl.registerLazySingleton<HttpService>(() => HttpService(alice: sl<Alice>()));
  sl.registerLazySingleton<RestClient>(
    () => RestClient(sl<HttpService>().dio),
    instanceName: 'dio',
  );
  sl.registerLazySingleton<Repository>(
    () => Repository(restClient: sl<RestClient>(instanceName: 'dio')),
  );

  // Face Services
  sl.registerLazySingleton<CameraService>(() => CameraService());
  sl.registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
  sl.registerLazySingleton<MLService>(() => MLService());

  // Providers
  sl.registerLazySingleton<ProfileProvider>(
    () => ProfileProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<InOutProvider>(
    () => InOutProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<AuthProvider>(() => AuthProvider(sl<Repository>()));
  sl.registerLazySingleton<RegisterProvider>(
    () => RegisterProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<RegisterProviderOld>(
    () => RegisterProviderOld(sl<Repository>()),
  );

  sl.registerLazySingleton<HomeProvider>(() => HomeProvider(sl<Repository>()));
  sl.registerLazySingleton<MapProvider>(() => MapProvider());
  sl.registerLazySingleton<LocationProvider>(
    () => LocationProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<HistoryProvider>(
    () => HistoryProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<ResetPasswordProvider>(
    () => ResetPasswordProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<ChangePasswordProvider>(
    () => ChangePasswordProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<TodoProvider>(() => TodoProvider(sl<Repository>()));
  sl.registerLazySingleton<BoardProvider>(
    () => BoardProvider(sl<Repository>()),
  );
  sl.registerLazySingleton<TaskProvider>(() => TaskProvider(sl<Repository>()));
  sl.registerLazySingleton<OrganizationProvider>(
    () => OrganizationProvider(sl<Repository>()),
  );

  sl.registerLazySingleton<HttpServ.HttpService>(
    () => HttpServ.HttpService(alice: sl<Alice>()),
  );
  sl.registerSingleton<RestCl.RestClient>(
    RestCl.RestClient(sl<HttpServ.HttpService>().dio),
    instanceName: 'dio',
  );
  sl.registerLazySingleton<Repo.Repository>(
    () =>
        Repo.Repository(restClient: sl<RestCl.RestClient>(instanceName: 'dio')),
  );
  sl.registerLazySingleton<UserListViewModel>(
    () => UserListViewModel(sl<Repo.Repository>()),
  );
  sl.registerLazySingleton<GroupListViewModel>(
    () => GroupListViewModel(sl<Repo.Repository>()),
  );
  sl.registerLazySingleton<ChatViewModel>(
    () => ChatViewModel(sl<Repo.Repository>()),
  );
  sl.registerLazySingleton<RouteChangeNotifier>(() => RouteChangeNotifier());
}
