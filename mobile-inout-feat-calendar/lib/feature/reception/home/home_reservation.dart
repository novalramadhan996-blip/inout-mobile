import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeReservationPage extends StatelessWidget {
  const HomeReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarIconCenter(),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 60,
          children: <Widget>[
            CategoryItem(
              imageUrl: Assets.imageCategory1,
              label: "Reception",
              onTap: () => context.router.push(const ReservationListRoute()),
            ),
            CategoryItem(
              imageUrl: Assets.imageCategory2,
              label: "Guest List",
              onTap: () => context.router.push(const GuestListRoute()),
            ),
            CategoryItem(
              imageUrl: Assets.imageCategory3,
              label: "Room Management",
              onTap: () {},
            ),
            CategoryItem(
              imageUrl: Assets.imageCategory4,
              label: "Calendar",
              onTap: () {},
            ),
            CategoryItem(
              imageUrl: Assets.imageCategory5,
              label: "Setting",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;
  const CategoryItem(
      {super.key,
      required this.imageUrl,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Image.asset(
            imageUrl,
            width: 130.0,
            height: 120.0,
            fit: BoxFit.contain,
          ),
          Text(
            label,
            style: AppStyle(
              color: AppColors.blackColor,
              weight: bold,
            ).headline2,
          )
        ],
      ),
    ).horizontalPadded(16);
  }
}
