import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service_provider.dart';
import 'package:mobile_in_out/feature/report_activity/data/datasource/report_activity_datasource.dart';
import 'package:mobile_in_out/feature/report_activity/data/repositories/report_activity_repository.dart';
import 'package:mobile_in_out/feature/report_activity/domain/repositories/report_activity_repository.dart';
import 'package:riverpod/riverpod.dart';

final reportActivityDatasourceProvider =
    Provider.family<ReportActivityDatasource, NetworkService>(
      (_, networkService) => ReportActivityRemoteDatasource(networkService),
    );

final reportActivityRepositoryProvider = Provider<ReportActivityRepository>((
  ref,
) {
  final networkService = ref.watch(networkServiceProvider);
  final datasource = ref.watch(
    reportActivityDatasourceProvider(networkService),
  );
  final repository = ReportActivityRepositoryImpl(datasource);

  return repository;
});
