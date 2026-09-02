import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service_provider.dart';
import 'package:mobile_in_out/feature/home_v2/data/datasource/home_v2_local_datasource.dart';
import 'package:mobile_in_out/feature/home_v2/data/datasource/home_v2_remote_datasource.dart';
import 'package:mobile_in_out/feature/home_v2/data/repositories/home_v2_repository.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final homeV2DatasourceProvider =
    Provider.family<HomeV2Datasource, NetworkService>(
      (_, networkService) => HomeV2RemoteDatasource(networkService),
    );

final homeV2LocalDatasourceProvider = Provider<HomeV2LocalData>((ref) {
  return HomeV2LocalDatasource();
});

final homeV2RepositoryProvider = Provider<HomeV2Repository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final remote = ref.watch(homeV2DatasourceProvider(networkService));
  final localData = ref.watch(homeV2LocalDatasourceProvider);

  return HomeV2RepositoryImpl(
    homeV2Datasource: remote,
    homeV2LocalData: localData,
  );
});
