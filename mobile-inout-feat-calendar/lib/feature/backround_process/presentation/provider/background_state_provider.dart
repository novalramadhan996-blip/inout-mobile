import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/backround_process/domain/provider/background_provider.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/provider/state/background_notifier.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:riverpod/riverpod.dart';

final backgroundNotifierProvider =
    StateNotifierProvider<BackgroundNotifier, BaseState<EmployeeDetailModel>>((
      ref,
    ) {
      final repository = ref.watch(backgroundRepositoryProvider);
      return BackgroundNotifier(repository)..getEmployeeDetail();
    });

final employeeDetailStateProvider = Provider<BaseState<EmployeeDetailModel>>((
  ref,
) {
  final rawState = ref.watch(backgroundNotifierProvider);

  return BaseState<EmployeeDetailModel>(
    state: rawState.state,
    isLoading: rawState.isLoading,
    message: rawState.message,
    data: rawState.data is EmployeeDetailModel
        ? rawState.data as EmployeeDetailModel
        : null,
  );
});
