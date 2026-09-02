import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/domain/repositories/home_repository.dart';

class HomeNotifier extends StateNotifier<BaseState<Map<String, dynamic>>> {
  final HomeRepository homeRepository;

  HomeNotifier(this.homeRepository)
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

    final response = await homeRepository.insertDeviceInfo(payload);

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
