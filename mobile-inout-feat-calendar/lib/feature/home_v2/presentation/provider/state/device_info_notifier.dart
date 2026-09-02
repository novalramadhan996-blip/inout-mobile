import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home_v2/domain/repositories/home_v2_repository.dart';

class DeviceInfoNotifier
    extends StateNotifier<BaseState<Map<String, dynamic>>> {
  final HomeV2Repository homeV2Repository;

  DeviceInfoNotifier(this.homeV2Repository)
    : super(const BaseState<Map<String, dynamic>>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> insertDeviceInfo(DeviceInfoModel payload) async {
    if (!isFetching || !mounted) return;

    state = state.copyWith(
      isLoading: true,
      state: ConcreteState.loading,
      data: null,
    );

    final response = await homeV2Repository.insertDeviceInfo(payload);

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
