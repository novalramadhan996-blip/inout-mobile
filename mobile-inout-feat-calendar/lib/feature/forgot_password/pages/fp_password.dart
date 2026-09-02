import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:mobile_in_out/feature/forgot_password/provider/reset_password_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ForgotPasswordPass extends StatefulWidget {
  const ForgotPasswordPass({super.key});

  @override
  State<ForgotPasswordPass> createState() => _ForgotPasswordPassState();
}

class _ForgotPasswordPassState extends State<ForgotPasswordPass> {
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
        title: 'Reset Password',
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
                      label: 'Email',
                      hinttext: 'Your email here',
                      readOnly: true,
                      onchanged: (value) {},
                      controller: provider.nameCtrl,
                    ),

                    AppFormProfile(
                      label: 'OTP',
                      hinttext: 'Your OTP here',
                      onchanged: (value) {},
                      controller: provider.otpCtrl,
                    ),

                    AppButton(
                      buttonName: "Reset Password",
                      isLoading: provider.resetState == RequestState.Loading,
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          provider.resetPassword().then((value) async {
                            if (provider.resetState == RequestState.Loaded) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Reset Password Success, New Password send to your email",
                                  ),
                                  backgroundColor: AppColors.greenColor,
                                ),
                              );
                              if (!context.mounted) return;
                              context.router.replaceAll([const SignInRoute()]);
                            }

                            if (provider.resetState == RequestState.Error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Reset Password Failed"),
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
