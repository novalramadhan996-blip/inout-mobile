import 'dart:developer';

import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/feature/home/data/model/device_info_model.dart';
import 'package:mobile_in_out/feature/home/data/model/profile_model.dart';
import 'package:mobile_in_out/feature/home/domain/provider/home_provider.dart';
import 'package:riverpod/riverpod.dart';

class HomeRemote {
  static Future<void> insertDeviceInfo(DeviceInfoModel payload) async {
    final container = ProviderContainer();

    LogHelper.logDebug('payload $payload');

    try {
      final repository = container.read(homeRepositoryProvider);

      final result = await repository.insertDeviceInfo(payload);

      final response = result.getOrElse(() => <String, dynamic>{});

      LogHelper.logDebug('Post device info response: $response');
    } finally {
      container.dispose();
    }
  }

  static Future<ProfileModel?> getProfile() async {
    final container = ProviderContainer();

    try {
      final repository = container.read(homeRepositoryProvider);

      final result = await repository.getProfile();

      return result.fold(
        (failed) {
          return ProfileModel();
        },
        (success) {
          return success;
        },
      );
    } finally {
      container.dispose();
    }
  }
}
