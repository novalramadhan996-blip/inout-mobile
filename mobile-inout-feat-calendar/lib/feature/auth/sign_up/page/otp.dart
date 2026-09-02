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

@RoutePage()
class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
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
        title: 'Validate OTP',
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
                      label: 'Enter OTP',
                      hinttext: 'Your OTP here',
                      onchanged: (value) {},
                      controller: provider.otpCtrl,
                    ),

                    AppButton(
                      buttonName: "Validate OTP",
                      isLoading: provider.stateOtp == RequestState.Loading,
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          provider.validateOtp(widget.email).then((
                            value,
                          ) async {
                            if (provider.stateOtp == RequestState.Loaded) {
                              if (context.mounted) {
                                // disable direct to register face, because api register face must be set authorization
                                // context.router.push(
                                //   RegisterFaceRoute(isRegister: true),
                                // );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Validation Success"),
                                    backgroundColor: AppColors.greenColor,
                                  ),
                                );
                                context.router.replaceAll([
                                  const SignInRoute(),
                                ]);
                              }
                            }

                            if (provider.stateOtp == RequestState.Error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("OTP is invalid"),
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
