import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/localizations/locale_provider.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? versionName;
  String? versionCode;

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  Future<void> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      versionName = info.version;
      versionCode = info.buildNumber;
    });
  }

  void _showLanguageDialog() {
    final localeProvider = context.read<LocaleProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTranslations.supportedLanguages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang.name),
              value: lang.code,
              groupValue: localeProvider.languageCode,
              onChanged: (value) {
                if (value != null) {
                  localeProvider.setLocale(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: AppTranslations.translate('setting'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.perm_device_info),
            title: Text(AppTranslations.translate('device_info')),
            subtitle: Text(AppTranslations.translate('device_info_subtitle')),
            onTap: () {
              context.router.push(const DeviceInfoRoute());
            },
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
            child: const Divider(height: 1, color: AppColors.blackColor),
          ),

          ListTile(
            leading: const Icon(Icons.notification_important_outlined),
            title: Text(AppTranslations.translate('reminder_attendance')),
            subtitle: Text(
              AppTranslations.translate('reminder_attendance_subtitle'),
            ),
            onTap: () {
              context.router.push(const ReminderAbsensiRoute());
            },
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
            child: const Divider(height: 1, color: AppColors.blackColor),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppTranslations.translate('language')),
            subtitle: Text(
              AppTranslations.supportedLanguages
                  .firstWhere((l) => l.code == localeProvider.languageCode)
                  .name,
            ),
            onTap: _showLanguageDialog,
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
            child: const Divider(height: 1, color: AppColors.blackColor),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(AppTranslations.translate('version_app')),
            subtitle: Text('$versionName - $versionCode'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
