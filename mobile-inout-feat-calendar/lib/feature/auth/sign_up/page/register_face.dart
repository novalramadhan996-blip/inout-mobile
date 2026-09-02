import 'dart:developer';
import 'dart:io';

import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class RegisterFacePage extends StatefulWidget {
  final bool isRegister;
  final bool showBackButton;
  const RegisterFacePage({
    super.key,
    this.isRegister = false,
    this.showBackButton = true,
  });

  @override
  State<RegisterFacePage> createState() => _RegisterFacePageState();
}

class _RegisterFacePageState extends State<RegisterFacePage> {
  late RegisterProvider registerProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    registerProvider = Provider.of<RegisterProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerProvider.reload();
    });
  }

  void _snackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        onBackPressed: () {
          // if (context.mounted)
          //   {
          //     context.router.replaceAll([HomeRouteV2()]),
          //   },
          if (widget.isRegister) {
            if (!context.mounted) return;
            context.router.replaceAll([const SignInRoute()]);
          } else {
            if (!context.mounted) return;
            context.router.replaceAll([HomeRouteV2()]);
          }
        },
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: AppTranslations.translate('register_face'),
        showBackButton: widget.showBackButton,
      ),
      body: Consumer<RegisterProvider>(
        builder: (context, provider, _) {
          // LogHelper.logDebug("IMAGE PATH : ${provider.imagePath}"); // "lib/feature/auth/sign_up/page/register_face.dart
          // LogHelper.logDebug("IS PICTURE TAKEN : ${provider.pictureTaken}"); // "lib/feature/auth/sign_up/page/register_face.dart
          // LogHelper.logDebug("INITIALIZING : ${provider.initializing}"); // "lib/feature/auth/sign_up/page/register_face.dart
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: AppColors.blackColor,
                        strokeWidth: 1,
                        radius: const Radius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          context.router.push(
                            const FaceregistrationRegisterRoute(),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.face, color: AppColors.blackColor),
                              SizedBox(width: 10),
                              Text(
                                AppTranslations.translate('register_face'),
                                style: subtitle4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).bottomPadded(10),

                    Visibility(
                      visible:
                          !provider.initializing &&
                          provider.pictureTaken &&
                          provider.imagePath != null,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        width: 200,
                        height: 200,
                        child: Image.file(
                          File(provider.imagePath ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    AppFormProfile(
                      label: AppTranslations.translate('email_or_employee_id'),
                      hinttext: AppTranslations.translate(
                        'your_email_or_employee_id_here',
                      ),
                      onchanged: (value) {},
                      controller: provider.nameCtrl,
                    ),

                    AppFormProfile(
                      label: AppTranslations.translate('password'),
                      hinttext: AppTranslations.translate('password_hint'),
                      onchanged: (value) {},
                      controller: provider.pwdCtrl,
                      showText: false,
                    ),

                    AppFormProfile(
                      label: AppTranslations.translate('retype_password'),
                      hinttext: AppTranslations.translate('password_hint'),
                      onchanged: (value) {},
                      controller: provider.reTypePwdCtrl,
                      showText: false,
                    ),

                    AppButton(
                      buttonName: AppTranslations.translate('register_face'),
                      isLoading: provider.stateFace == RequestState.Loading,
                      onPress: () {
                        if (provider.pwdCtrl.text !=
                            provider.reTypePwdCtrl.text) {
                          _snackBar(
                            AppTranslations.translate('password_not_match'),
                            AppColors.redColors,
                          );
                          return;
                        }

                        if (provider.imagePath == null) {
                          _snackBar(
                            AppTranslations.translate('please_take_picture'),
                            AppColors.redColors,
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          provider.regsiterFace().then((value) async {
                            if (provider.stateFace == RequestState.Loaded) {
                              _snackBar(
                                AppTranslations.translate(
                                  'face_registration_success',
                                ),
                                AppColors.greenColor,
                              );

                              provider.disposeCtrlFace();

                              if (widget.isRegister) {
                                if (!context.mounted) return;
                                context.router.replaceAll([
                                  const SignInRoute(),
                                ]);
                              } else {
                                if (!context.mounted) return;
                                context.router.replaceAll([HomeRouteV2()]);
                              }
                            }

                            if (provider.stateFace == RequestState.Error) {
                              _snackBar(
                                AppTranslations.translate(
                                  'face_registration_failed',
                                ),
                                AppColors.redColors,
                              );
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
