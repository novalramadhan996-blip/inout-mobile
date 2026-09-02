import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/biodata_user.dart';
import 'package:mobile_in_out/core/utils/widgets/switch.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  bool _switchValue = false;
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
        title: 'Profile',
        action: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 100,
            height: 40,
            child: AppButton(
              buttonName: 'Submit',
              onPress: () => context.router.replaceAll([HomeRouteV2()]),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              // height: 230,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(Assets.imageExample),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: Colors.grey[300]!),
              ),
            ),
            const BiodataContainer(
              child: Column(
                children: [
                  BiodataUser(
                    field: 'Name',
                    value: 'Adelina',
                    height: 60,
                    marginRight: 70,
                  ),
                  BiodataUser(
                    field: 'Reg. Number',
                    value: '20230277001',
                    height: 60,
                    marginRight: 10,
                  ),
                  BiodataUser(
                    field: 'Email',
                    value: 'nina.adelia@inandout.com',
                    height: 60,
                    marginRight: 65,
                  ),
                  BiodataUser(
                    field: 'Division',
                    value: 'AdSales and Marketingelina',
                    height: 60,
                    marginRight: 45,
                  ),
                  BiodataUser(
                    field: 'Position',
                    value: 'Director',
                    height: 60,
                    marginRight: 45,
                  ),
                  BiodataUser(
                    field: 'Contact Num.',
                    value: '+628117007770',
                    height: 60,
                    marginRight: 0,
                  ),
                ],
              ),
            ),
            const BiodataContainer(
              // height: 103,
              child: Column(
                children: [
                  BiodataUser(
                    field: 'Check In Time',
                    value: '15:00',
                    height: 60,
                    marginRight: 0,
                  ),
                  BiodataUser(
                    field: 'Check Out Time',
                    value: '16:30',
                    height: 60,
                    marginRight: 0,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.blackColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Allow app to track your location',
                      style: subtitle4,
                    ),
                  ),
                  SwitchCtsm(
                    onChanged: (newValue) {
                      setState(() {
                        _switchValue = newValue;
                      });
                    },
                    value: _switchValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BiodataContainer extends StatelessWidget {
  final Widget child;
  // final double height;
  const BiodataContainer({
    super.key,
    required this.child,
    // this.height = 303,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      // height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColors.greyColor.withOpacity(0.3),
        border: Border.all(
          width: 1,
          color: AppColors.greyButtonColor.withOpacity(0.5),
        ),
      ),
      child: child,
    );
  }
}
