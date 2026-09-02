// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/feature/change_password/provider/change_password_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool isShowOldPassword = false;
  bool isShowNewPassword = false;
  bool isShowConfirmNewPassword = false;

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
        title: AppTranslations.translate('change_password'),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),
          Consumer<ChangePasswordProvider>(
            builder: (context, watch, _) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    AppInput(
                      controller: watch.oldpassword,
                      hintText: AppTranslations.translate('old_password'),
                      showText: isShowOldPassword,
                      onChanged: (value) {},
                      suffixIcon: IconButton(
                        icon: Icon(
                          isShowOldPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.greyColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isShowOldPassword = !isShowOldPassword;
                          });
                        },
                      ),
                    ),
                    AppInput(
                      controller: watch.newpassword,
                      hintText: AppTranslations.translate('new_password'),
                      onChanged: (value) {},
                      showText: isShowNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isShowNewPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.greyColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isShowNewPassword = !isShowNewPassword;
                          });
                        },
                      ),
                    ),
                    AppInput(
                      controller: watch.confirmNewpassword,
                      hintText: AppTranslations.translate(
                        'confirm_new_password',
                      ),
                      onChanged: (value) {},
                      showText: isShowConfirmNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isShowConfirmNewPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.greyColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isShowConfirmNewPassword =
                                !isShowConfirmNewPassword;
                          });
                        },
                      ),
                    ),
                    AppButton(
                      buttonName: AppTranslations.translate('submit'),
                      isLoading: watch.state == RequestState.Loading,
                      onPress: () {
                        if (watch.getIsValidPassword) {
                          Dialogs.showLoadingDialog(context);
                          watch
                              .changePassword(
                                watch.oldpassword.text,
                                watch.newpassword.text,
                              )
                              .then((value) {
                                if (!context.mounted) return;
                                context.router.popForced();

                                if (watch.state == RequestState.Loaded) {
                                  if (!context.mounted) return;
                                  context.router.popForced();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppTranslations.translate(
                                          'change_password_success',
                                        ),
                                      ),
                                      backgroundColor: AppColors.greenColor,
                                    ),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppTranslations.translate(
                                          'change_password_failed',
                                        ),
                                      ),
                                      backgroundColor: AppColors.redColors,
                                    ),
                                  );
                                }
                              });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
