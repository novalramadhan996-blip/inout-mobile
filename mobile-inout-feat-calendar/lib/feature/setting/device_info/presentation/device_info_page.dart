import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony_info_plus/telephony_info_plus.dart';
import 'package:flutter_sim_info/flutter_sim_info.dart';

@RoutePage()
class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  Map<String, dynamic> deviceData = {};
  String? imei;
  String? imsi;
  final _telephonyInfoPlusPlugin = TelephonyInfoPlus();
  List<AppInfo>? _apps;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    getTelephoneInfo();
    getDeviceIMEI();
    getSimInfo();
    getAllPackages();
  }

  Future<void> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    final android = await deviceInfo.androidInfo;

    setState(() {
      deviceData = {
        "Model": android.model,
        "Manufacturer": android.manufacturer,
        "Brand": android.brand,
        "Android Version": android.version.release,
        "SDK": android.version.sdkInt,
        "Hardware": android.hardware,
        "Board": android.board,
        "Device": android.device,
        "Product": android.product,
        "Supported ABIs": android.supportedAbis.join(", "),
      };
    });
  }

  Future<void> getTelephoneInfo() async {
    // minta permission
    var status = await Permission.phone.request();
    if (!status.isGranted) return;

    try {
      final info = await _telephonyInfoPlusPlugin.getSimInfos();
      LogHelper.logDebug('infoSim $info');
    } catch (e) {
      // setState(() {
      //   imei = "Error: $e";
      //   imsi = "Error: $e";
      // });
    }
  }

  void getDeviceIMEI() async {
    String? imei = await FlutterDeviceImei.instance.getIMEI();
    LogHelper.logDebug("Device IMEI/Identifier: $imei");
  }

  void getSimInfo() async {
    List<SimInfo>? simNumber = await FlutterSimInfo.getSimInfo();
    List<String>? carrier = await FlutterSimInfo.getCarrierNames();
    LogHelper.logDebug('sim number $simNumber');
    LogHelper.logDebug('carrier $carrier');
  }

  void getAllPackages() async {
    final newestApps = (await getNewestInstalledApps()).take(10).toList();
    LogHelper.logDebug('newest apps: $newestApps');
    final apps = await FlutterDeviceApps.listApps(
      includeSystem: false, // Skip system apps (Settings, Phone, etc.)
      onlyLaunchable: true, // Only apps with launcher icons
      includeIcons: false, // Don't load icon bytes (better performance)
    );

    for (final app in newestApps) {
      LogHelper.logDebug('${app.appName}  •  ${app.packageName}');
    }

    setState(() {
      _apps = newestApps;
    });
  }

  Future<List<AppInfo>> getNewestInstalledApps() async {
    final apps = await FlutterDeviceApps.listApps(
      includeSystem: false,
      onlyLaunchable: true,
      includeIcons: false,
    );

    if (apps.isEmpty) {
      return [];
    }

    apps.sort((a, b) => b.firstInstallTime!.compareTo(a.firstInstallTime!));

    return apps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Info")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              AppTranslations.translate("hardware_info"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...deviceData.entries.map((e) {
              return ListTile(title: Text(e.key), subtitle: Text("${e.value}"));
            }),

            // const SizedBox(height: 20),
            // const Divider(color: AppColors.blackColor),
            // const SizedBox(height: 20),

            // const Text(
            //   "Telephony (IMEI / IMSI)",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 12),

            // ListTile(
            //   title: const Text("IMEI"),
            //   subtitle: Text(imei ?? "Loading..."),
            // ),
            // ListTile(
            //   title: const Text("IMSI"),
            //   subtitle: Text(imsi ?? "Loading..."),
            // ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.blackColor),
            const SizedBox(height: 20),

            Text(
              AppTranslations.translate("new_installed_apps"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _apps?.length ?? 0,
              itemBuilder: (context, index) {
                final app = _apps?[index];

                return ListTile(
                  title: Text(app?.appName ?? ''),
                  subtitle: Text(app?.packageName ?? ''),
                  trailing: Text(app?.versionName ?? ""),
                  onTap: () {
                    FlutterDeviceApps.openApp(app?.packageName ?? '');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
