import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service_provider.dart';
import 'package:mobile_in_out/feature/absence/data/datasource/absence_local_datasource.dart';
import 'package:mobile_in_out/feature/absence/data/datasource/absence_remote_datasource.dart';
import 'package:mobile_in_out/feature/absence/data/repositories/absence_repository.dart';
import 'package:mobile_in_out/feature/absence/domain/repositories/absence_repository.dart';
import 'package:riverpod/riverpod.dart';

final absenceDatasourceProvider =
    Provider.family<AbsenceDatasource, NetworkService>(
      (_, networkService) => AbsenceRemoteDatasource(networkService),
    );

final absenceLocalDatasourceProvider = Provider<AbsenceLocalData>((ref) {
  return AbsenceLocalDatasource();
});

final absenceRepositoryProvider = Provider<AbsenceRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final remote = ref.watch(absenceDatasourceProvider(networkService));
  final localData = ref.watch(absenceLocalDatasourceProvider);

  return AbsenceRepositoryImpl(
    absenceDatasource: remote,
    absenceLocalData: localData,
  );
});
