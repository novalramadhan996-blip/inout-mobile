import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service_provider.dart';
import 'package:mobile_in_out/feature/calendar/data/datasource/calendar_remote_datasource.dart';
import 'package:mobile_in_out/feature/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:mobile_in_out/feature/calendar/domain/repositories/calendar_repository.dart';
import 'package:riverpod/riverpod.dart';

final calendarDatasourceProvider =
    Provider.family<CalendarDatasource, NetworkService>(
      (_, networkService) => CalendarRemoteDatasource(networkService),
    );

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final networkService = ref.watch(calendarNetworkServiceProvider);
  final remote = ref.watch(calendarDatasourceProvider(networkService));

  return CalendarRepositoryImpl(calendarDatasource: remote);
});

final networkRepositoryProvider = Provider<CalendarRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final remote = ref.watch(calendarDatasourceProvider(networkService));

  return CalendarRepositoryImpl(calendarDatasource: remote);
});
