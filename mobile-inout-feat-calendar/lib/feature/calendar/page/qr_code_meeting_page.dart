import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage()
class QrCodeMeetingPage extends ConsumerStatefulWidget {
  final String data;

  const QrCodeMeetingPage({super.key, required this.data});

  @override
  ConsumerState<QrCodeMeetingPage> createState() => _QrCodeMeetingPageState();
}

class _QrCodeMeetingPageState extends ConsumerState<QrCodeMeetingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: AppTranslations.translate('qr_code_meeting'),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: AppButton(
          buttonName: AppTranslations.translate('close'),
          onPress: () => {context.router.pop()},
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black, width: 1),
                  ),
                  child: QrImageView(
                    data: widget.data,
                    version: QrVersions.auto,
                    size: 300,
                    gapless: false,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
