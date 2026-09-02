import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service_provider.dart';
import 'package:mobile_in_out/feature/home/data/datasource/home_remote_datasource.dart';
import 'package:mobile_in_out/feature/home/data/repositories/home_repository.dart';
import 'package:mobile_in_out/feature/home/domain/repositories/home_repository.dart';
import 'package:riverpod/riverpod.dart';

final homeDatasourceProvider = Provider.family<HomeDatasource, NetworkService>(
  (_, networkService) => HomeRemoteDatasource(networkService),
);

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final datasource = ref.watch(homeDatasourceProvider(networkService));
  final repository = HomeRepositoryImpl(datasource);

  return repository;
});
