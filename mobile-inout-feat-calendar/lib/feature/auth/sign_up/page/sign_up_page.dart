import 'dart:developer';

import 'package:mobile_in_out/core/global/provider/location_provider.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/work_location/work_location_model.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input_date.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input_dropdown.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';
import 'package:mobile_in_out/feature/auth/provider/register_provider_old.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SignUpPageOri extends StatefulWidget {
  const SignUpPageOri({super.key});

  @override
  State<SignUpPageOri> createState() => _SignUpPageOriState();
}

class _SignUpPageOriState extends State<SignUpPageOri> {
  late RegisterProviderOld registerProvider;
  final _formKey = GlobalKey<FormState>();
  // late LocationProvider locationProvider;

  @override
  void initState() {
    // locationProvider = Provider.of<LocationProvider>(context, listen: false);
    registerProvider = Provider.of<RegisterProviderOld>(context, listen: false);

    // Fetch Work Location
    // Future.microtask(
    //   () => locationProvider.fetchWorkLocation(
    //     ListDataRequest(
    //       page: 0,
    //       limit: 100,
    //       search: "",
    //       sortBy: "created",
    //       orderBy: "desc",
    //     ),
    //   ),
    // );
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
        title: 'Regsiter Account',
      ),
      body: Consumer<RegisterProviderOld>(
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
                      label: 'Username',
                      hinttext: 'Your username here',
                      onchanged: (value) {},
                      controller: provider.usernameCtrl,
                    ),
                    AppFormProfile(
                      label: 'Email',
                      hinttext: 'Your email here',
                      onchanged: (value) {},
                      controller: provider.emailCtrl,
                    ),
                    AppFormProfile(
                      label: 'Name',
                      hinttext: 'Your name here',
                      onchanged: (value) {},
                      controller: provider.nameCtrl,
                    ),
                    AppFormProfile(
                      label: 'Password',
                      hinttext: 'Your password here',
                      onchanged: (value) {},
                      controller: provider.passwordCtrl,
                      showText: false,
                    ),
                    SizedBox(height: 20),

                    // AppFormProfile(
                    //   label: 'Employee Resgistration Number',
                    //   hinttext: 'Your resgistration number here',
                    //   onchanged: (value) {},
                    //   controller: provider.employIdCtrl,
                    // ),
                    // AppInputDatePicker(
                    //   label: "Date of Birth",
                    //   controller: provider.birthdateCtrl,
                    //   hintText: "Your date of birth here",
                    //   onChanged: (value) {

                    //   },
                    // ),

                    // AppInputDropdown<String>(
                    //   label: "Gender",
                    //   controller: provider.genderCtrl,

                    //   items: const [
                    //     "Male",
                    //     "Female",
                    //   ],
                    //   hintText: "Your gender here",
                    //   onChanged: (value) {
                    //     provider.genderCtrl.text = value;
                    //   },
                    //   valueBuilder: (value) => value,
                    // ),

                    // AppFormProfile(
                    //   label: 'Division',
                    //   hinttext: 'Your division here',
                    //   onchanged: (value) {},
                    //   controller: provider.divisionCtrl,
                    // ),
                    // AppFormProfile(
                    //   label: 'Position',
                    //   hinttext: 'Your position here',
                    //   onchanged: (value) {},
                    //   controller: provider.positionCtrl,
                    // ),

                    // Selector<LocationProvider, List<Location>>(
                    //   selector: (context, provider) => provider.workLocation,
                    //   builder: (context, workLocation, _) {
                    //     return AppInputDropdown<Location>(
                    //       label: "Work Location",
                    //       controller: registerProvider.workLocationCtrl,
                    //       items: workLocation,
                    //       hintText: "Your work location here",
                    //       onChanged: (value) {
                    //         registerProvider.workLocationCtrl.text = value.locationId ?? '';
                    //       },
                    //       valueBuilder: (value) => value.locationName ??   '',
                    //     );
                    //   },
                    // ),

                    // AppFormProfile(
                    //   label: 'Contact Number',
                    //   hinttext: 'Your contact number here',
                    //   onchanged: (value) {},
                    //   controller: provider.contactCtrl,
                    // ),

                    // const SizedBox(height: 10),

                    // const AppLabel(
                    //   label: "Face Registration",
                    //   isRequired: false,
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     // context.router.push(const FaceregistrationRoute());
                    //   },
                    //   child: Container(
                    //     height: 100,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       border: Border.all(
                    //         color: AppColors.greyColor,
                    //         width: 1,
                    //       ),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: const Center(
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Text(
                    //             'Register your face here',
                    //             style: subtitle4,
                    //           ),
                    //           SizedBox(
                    //             width: 10,
                    //           ),
                    //           Icon(
                    //             Icons.camera_alt_outlined,
                    //             color: AppColors.greyColor,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ).topPadded(10),
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    AppButton(
                      buttonName: "Register",
                      isLoading: provider.state == RequestState.Loading,
                      onPress: () {
                        // LogHelper.logDebug('email ${provider.emailCtrl.text}');
                        // context.router.push(
                        //   OtpRoute(email: provider.emailCtrl.text),
                        // );
                        if (_formKey.currentState!.validate()) {
                          provider.register().then((value) async {
                            final providerState = context
                                .read<RegisterProviderOld>()
                                .state;

                            if (providerState == RequestState.Loaded) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("OTP already sent to email!"),
                                  backgroundColor: AppColors.greenColor,
                                ),
                              );
                              if (!context.mounted) return;
                              context.router.push(
                                OtpRoute(email: provider.emailCtrl.text),
                              );
                            }

                            if (providerState == RequestState.Error) {
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
