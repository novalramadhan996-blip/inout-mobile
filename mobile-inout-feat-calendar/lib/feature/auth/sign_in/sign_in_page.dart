// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  AuthProvider? _providerAuth;

  String latitude = '';
  String longitude = '';
  String accuracy = '';
  String altitude = '';
  String bearing = '';
  String speed = '';
  String time = '';

  @override
  void initState() {
    super.initState();
    _providerAuth = context.read<AuthProvider>();
    _providerAuth?.clearAllLocalStorage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionLocation();
      // _checkAndRequestBatteryOptimization();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<AuthProvider>(
            builder: (context, provider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      Assets.logoPng,
                      width: 150,
                      height: 150,
                    ).topPadded(100),
                    Text(
                      AppTranslations.translate('login'),
                      style: AppTheme.bodyText.copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Text(
                    //   AppTranslations.translate('app_name'),
                    //   style: AppTheme.bodyText.copyWith(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    Text(
                      AppTranslations.translate('please_login_to_account'),
                      style: AppTheme.bodyText.copyWith(fontSize: 14),
                    ).bottomPadded(65),
                    AppInput(
                      controller: provider.emailController,
                      hintText: AppTranslations.translate(
                        'input_email_or_employee_id',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppTranslations.translate(
                            'email_or_employee_id_required',
                          );
                        }
                        return null;
                      },
                      onChanged: (value) {},
                    ),
                    Selector<AuthProvider, bool>(
                      selector: (context, AuthProvider provider) =>
                          provider.showPassword,
                      builder: (context, showPassword, child) {
                        return AppInput(
                          controller: provider.passwordController,
                          hintText: AppTranslations.translate('password'),
                          showText: showPassword,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppTranslations.translate(
                                'password_required',
                              );
                            }
                            return null;
                          },
                          suffixIcon: InkWell(
                            onTap: () =>
                                provider.setSHowPassword(!showPassword),
                            child: showPassword
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                          ),
                          onChanged: (value) {},
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.router.push(const ForgotPasswordUsername());
                        },
                        child: Text(
                          AppTranslations.translate('forgot_password'),
                        ),
                      ),
                    ),
                    AppButton(
                      buttonName: AppTranslations.translate('login'),
                      isLoading: provider.stateLogin == RequestState.Loading,
                      onPress: () async {
                        PermissionStatus status =
                            await Permission.locationAlways.status;
                        if (!status.isGranted) {
                          _checkPermissionLocation();
                          return;
                        }

                        // bool isBatteryOptimizationDisabled =
                        //     await DisableBatteryOptimizationLatest
                        //         .isBatteryOptimizationDisabled ??
                        //     false;
                        // if (!isBatteryOptimizationDisabled) {
                        //   _checkAndRequestBatteryOptimization();
                        //   return;
                        // }

                        if (_formKey.currentState?.validate() ?? false) {
                          provider.login().then((value) async {
                            final providerState = context
                                .read<AuthProvider>()
                                .stateLogin;

                            if (providerState == RequestState.Loaded) {
                              context.router.replace(
                                HomeRouteV2(isFromSignIn: true),
                              );
                            }

                            if (providerState == RequestState.Error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${AppTranslations.translate('something_went_wrong')} ${provider.errorMessage}",
                                  ),
                                ),
                              );
                            }
                          });
                        }
                      },
                    ),

                    // AppButton.outline(
                    //   buttonName: "Register",
                    //   onPress: () {
                    //     context.router.push(const SignUpRouteNew());
                    //   },
                    // ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue,
                        ),
                        onPressed: () {
                          // context.router.push(const SignUpRouteNew());
                          // context.router.push(const SignUpRouteOri());
                          context.router.push(
                            RegisterFaceRoute(
                              showBackButton: true,
                              isRegister: true,
                            ),
                          );
                        },
                        child: Text(AppTranslations.translate('register')),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ).horizontalPadded(16),
              );
            },
          ),
        ),
      ),
    );
  }

  //check battery optimization
  Future<void> _checkAndRequestBatteryOptimization() async {
    bool isBatteryOptimizationDisabled =
        await DisableBatteryOptimizationLatest.isBatteryOptimizationDisabled ??
        false;
    bool isManBatteryOptimizationDisabled =
        await DisableBatteryOptimizationLatest
            .isManufacturerBatteryOptimizationDisabled ??
        false;

    LogHelper.logDebug(
      "isBatteryOptimizationDisabled $isBatteryOptimizationDisabled",
    );
    LogHelper.logDebug(
      "isManBatteryOptimizationDisabled $isManBatteryOptimizationDisabled",
    );

    if (!isBatteryOptimizationDisabled) {
      if (isManBatteryOptimizationDisabled) {
        LogHelper.logDebug(
          "isManBatteryOptimizationDisabled true $isManBatteryOptimizationDisabled",
        );
        _requestLocationPermission(
          AppTranslations.translate('battery_optimization'),
          AppTranslations.translate('battery_optimization_desc'),
          '',
        );
      } else {
        LogHelper.logDebug(
          "isManBatteryOptimizationDisabled false $isManBatteryOptimizationDisabled",
        );
        await DisableBatteryOptimizationLatest.showDisableBatteryOptimizationSettings();
      }
    }
  }

  Future<void> _checkPermissionLocation() async {
    PermissionStatus status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      _requestLocationPermission(
        AppTranslations.translate('location_permission_required'),
        AppTranslations.translate('location_permission_desc'),
        '',
      );
    }
  }

  Future<void> _requestLocationPermission(title, message_1, message_2) async {
    // Get the current permission status

    Future.delayed(const Duration(microseconds: 3000), () {
      // Show the permission dialog
      showDialog(
        context: context,
        barrierDismissible: true, // Prevent dismissal by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message_1),
                if (message_2.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(message_2, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Open app settings for user to enable permission manually
                  await openAppSettings();

                  Navigator.pop(context); // This dismisses the dialog
                },
                child: Text(AppTranslations.translate('go_to_settings')),
              ),
            ],
          );
        },
      );
    });
  }
}
