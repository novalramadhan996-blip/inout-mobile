import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/backround_process/domain/repositories/background_repository.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';

class BackgroundNotifier extends StateNotifier<BaseState<EmployeeDetailModel>> {
  final BackgroundRepository backgroundRepository;

  BackgroundNotifier(this.backgroundRepository)
    : super(const BaseState<EmployeeDetailModel>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getEmployeeDetail() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await backgroundRepository.getEmployeeDetail();

    if (!mounted) return;

    response.fold(
      (failure) {
        state = state.copyWith(
          state: ConcreteState.failure,
          message: failure.message,
          isLoading: false,
          data: null,
        );
      },
      (data) {
        state = state.copyWith(
          state: ConcreteState.loaded,
          isLoading: false,
          message: 'success',
          data: data,
        );
      },
    );
  }

  void resetState() {
    state = const BaseState();
  }
}
