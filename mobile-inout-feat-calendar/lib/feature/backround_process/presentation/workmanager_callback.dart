import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/config/app_config.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/background_service.dart';
import 'package:mobile_in_out/feature/backround_process/presentation/geofance_checkin.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final token = inputData?['token'];

    await dotenv.load(fileName: AppConfig.envFileName);
    BackgroundService.initializeDI();

    if (token == null || token.isEmpty) return true;

    await GeofanceCheckin.fetchEmployeeDetailInBackground();

    return true;
  });
}
