import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';

class LocalDataNotifier extends StateNotifier<BaseState<dynamic>> {
  final HomeV2Repository homeV2Repository;

  LocalDataNotifier(this.homeV2Repository) : super(const BaseState<dynamic>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getToken() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await homeV2Repository.getToken();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> getIsReminder() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await homeV2Repository.getIsReminder();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> getGroupShiftSchedule() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await homeV2Repository.getGroupShiftSchedule();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> updateGroupShiftSchedule(String groupShift) async {
    if (!isFetching || !mounted) return;

    await homeV2Repository.updateGroupShiftSchedule(groupShift);
  }

  Future<void> getIsOpenUsageApps() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await homeV2Repository.getIsOpenUsageApps();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> updateOpenUsageApps(bool isOpenUsageApps) async {
    if (!isFetching || !mounted) return;

    await homeV2Repository.updateOpenUsageApps(isOpenUsageApps);
  }

  Future<void> saveCheckInLocal(CheckInResponseModel inResponseModel) async {
    if (!isFetching || !mounted) return;

    await homeV2Repository.saveCheckInLocal(inResponseModel);
  }

  Future<void> fetchCheckInLocal() async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await homeV2Repository.fetchCheckInLocal();

    if (!mounted) return;

    state = state.copyWith(
      state: ConcreteState.loaded,
      isLoading: false,
      message: 'success',
      data: response,
    );
  }

  Future<void> saveProfile(String profile) async {
    if (!isFetching || !mounted) return;

    await homeV2Repository.saveProfile(profile);
  }

  Future<void> saveEmployeeDetail(String employeeDetail) async {
    if (!isFetching || !mounted) return;

    await homeV2Repository.saveEmployeeDetail(employeeDetail);
  }

  void resetState() {
    state = const BaseState();
  }
}
