import 'package:mobile_in_out/feature/backround_process/presentation/workmanager_callback.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerService {
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }
}
