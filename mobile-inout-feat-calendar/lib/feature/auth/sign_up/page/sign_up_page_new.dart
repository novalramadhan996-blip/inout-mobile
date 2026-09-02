import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/**
 * Deprecated since update mobileinout v2
 * 09/21/2025
 */
@RoutePage()
class SignUpPageNew extends StatefulWidget {
  const SignUpPageNew({super.key});

  @override
  State<SignUpPageNew> createState() => _SignUpPageNewState();
}

class _SignUpPageNewState extends State<SignUpPageNew> {
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
        title: 'Register/Validate Accout',
      ),
      body: Consumer<RegisterProvider>(
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
                      label: 'Employee ID',
                      hinttext: 'Your employee ID here',
                      onchanged: (value) {},
                      controller: provider.nameCtrl,
                    ),

                    AppButton(
                      buttonName: "Register/Validate Account",
                      isLoading: provider.state == RequestState.Loading,
                      onPress: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_formKey.currentState!.validate()) {
                          provider.validateAccount().then((value) async {
                            if (provider.state == RequestState.Loaded) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("OTP already sent to email!"),
                                  backgroundColor: AppColors.greenColor,
                                ),
                              );
                              if (!context.mounted) return;
                              context.router.push(
                                OtpRoute(email: provider.nameCtrl.text),
                              );
                            }

                            if (provider.state == RequestState.Error) {
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
