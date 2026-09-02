import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/config/app_config.dart';
import 'package:mobile_in_out/main_common.dart';

void main() async {
  AppConfig.setEnvFileName(".env.prod");
  await dotenv.load(fileName: AppConfig.envFileName);
  await mainCommon();
}
