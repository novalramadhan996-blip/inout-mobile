import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:mobile_in_out/feature/forgot_password/provider/reset_password_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ForgotPasswordUsername extends StatefulWidget {
  const ForgotPasswordUsername({super.key});

  @override
  State<ForgotPasswordUsername> createState() => _ForgotPasswordUsernameState();
}

class _ForgotPasswordUsernameState extends State<ForgotPasswordUsername> {
  late RegisterProvider registerProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    registerProvider = Provider.of<RegisterProvider>(context, listen: false);
    super.initState();
  }

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
        title: AppTranslations.translate('request_reset_password'),
      ),
      body: Consumer<ResetPasswordProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppFormProfile(
                      label: AppTranslations.translate('email'),
                      hinttext: AppTranslations.translate('email_hint'),
                      onchanged: (value) {},
                      controller: provider.nameCtrl,
                    ),

                    AppButton(
                      buttonName: AppTranslations.translate('validate_account'),
                      isLoading: provider.requestState == RequestState.Loading,
                      onPress: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_formKey.currentState!.validate()) {
                          provider.requestResetPassword().then((value) async {
                            if (provider.requestState == RequestState.Loaded) {
                              if (!context.mounted) return;
                              context.router.push(const ForgotPasswordPass());
                            }

                            if (provider.requestState == RequestState.Error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
