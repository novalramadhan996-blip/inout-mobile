import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';

class EmployeeDetailNotifier
    extends StateNotifier<BaseState<EmployeeDetailModel>> {
  final HomeV2Repository homeV2Repository;

  EmployeeDetailNotifier(this.homeV2Repository)
    : super(const BaseState<EmployeeDetailModel>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getEmployeeDetail() async {
    if (!isFetching || !mounted) return;

    final response = await homeV2Repository.getEmployeeDetail();

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
      (response) {
        state = state.copyWith(
          state: ConcreteState.loaded,
          isLoading: false,
          message: 'success',
          data: response,
        );

        return response;
      },
    );
  }

  void resetState() {
    state = const BaseState();
  }
}
