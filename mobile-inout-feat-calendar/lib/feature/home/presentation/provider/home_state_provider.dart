import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home/domain/provider/home_provider.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/state/home_notifier.dart';
import 'package:mobile_in_out/feature/home/presentation/provider/state/profile_notifier.dart';
import 'package:riverpod/riverpod.dart';

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, BaseState<Map<String, dynamic>>>((ref) {
      final repository = ref.watch(homeRepositoryProvider);
      final notifier = HomeNotifier(repository);

      notifier.insertDeviceInfo(ref as DeviceInfoModel);

      return notifier;
    });

final insertDeviceInfoStateProvider = Provider<BaseState<Map<String, dynamic>>>(
  (ref) {
    return ref.watch(homeNotifierProvider);
  },
);

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, BaseState<ProfileModel>>((ref) {
      final repository = ref.watch(homeRepositoryProvider);
      return ProfileNotifier(repository);
    });
