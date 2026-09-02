import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/feature/absence/domain/repositories/absence_repository.dart';

class LocalDataNotifier extends StateNotifier<BaseState<dynamic>> {
  final AbsenceRepository absenceRepository;

  LocalDataNotifier(this.absenceRepository) : super(const BaseState<dynamic>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getProfileLocal() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await absenceRepository.getProfileLocal();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> getEmployeeDetailLocal() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await absenceRepository.getEmployeeDetailLocal();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> saveCheckInLocal(CheckInResponseModel inResponseModel) async {
    if (!isFetching || !mounted) return;

    await absenceRepository.saveCheckInLocal(inResponseModel);
  }

  Future<void> deleteInOutLocal() async {
    if (!isFetching || !mounted) return;

    await absenceRepository.deleteCheckInOut();
  }

  void resetState() {
    state = const BaseState();
  }
}
