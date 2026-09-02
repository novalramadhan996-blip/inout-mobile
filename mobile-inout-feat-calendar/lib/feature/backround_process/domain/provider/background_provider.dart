import 'package:get_it/get_it.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/feature/backround_process/data/datasource/background_remote_datasource.dart';
import 'package:mobile_in_out/feature/backround_process/data/repositories/background_repository.dart';
import 'package:mobile_in_out/feature/backround_process/domain/repositories/background_repository.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service_provider.dart';
import 'package:riverpod/riverpod.dart';

final prefServiceProvider = Provider<ShardPrefService>((ref) {
  return sl<ShardPrefService>();
});

final backgroundDatasourceProvider =
    Provider.family<BackgroundDatasource, NetworkService>(
      (_, networkService) => BackgroundRemoteDatasource(networkService),
    );

final backgroundRepositoryProvider = Provider<BackgroundRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final datasource = ref.watch(backgroundDatasourceProvider(networkService));
  final prefService = ref.watch(prefServiceProvider);
  final repository = BackgroundRepositoryImpl(datasource, prefService);

  return repository;
});
