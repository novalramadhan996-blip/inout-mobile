import 'dart:developer';

import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/home/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home/domain/repositories/home_repository.dart';

class ProfileNotifier extends StateNotifier<BaseState<ProfileModel>> {
  final HomeRepository homeRepository;

  ProfileNotifier(this.homeRepository) : super(const BaseState<ProfileModel>());

  bool get isFetching =>
      state.state != ConcreteState.loading &&
      state.state != ConcreteState.fetchingMore;

  Future<void> getProfile() async {
    if (!isFetching || !mounted) return;

    final response = await homeRepository.getProfile();

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
