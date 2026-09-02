import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/helper/notification_service.dart';
import 'package:mobile_in_out/feature/backround_process/domain/provider/background_provider.dart';
import 'package:riverpod/riverpod.dart';

class LocationTracker {
  static Future<void> postLocation(Map<String, dynamic> payload) async {
    final container = ProviderContainer();

    LogHelper.logDebug('payload $payload');

    try {
      final repository = container.read(backgroundRepositoryProvider);

      final result = await repository.insertLocation(payload);

      result.fold(
        (error) {
          LogHelper.logDebug('Post location error: $error');
          if (AppConst.isShowNotifTrackingLocation) {
            NotificationService.showInstantNotification(
              title: 'Location Tracking',
              body: 'Gagal mengirim lokasi: ${error.message}',
            );
          }
        },
        (response) {
          LogHelper.logDebug('Post location response: $response');
          if (AppConst.isShowNotifTrackingLocation) {
            NotificationService.showInstantNotification(
              title: 'Location Tracking',
              body: 'Lokasi berhasil dikirim',
            );
          }
        },
      );
    } finally {
      container.dispose();
    }
  }
}
