import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/extensions/list_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:mobile_in_out/core/utils/widgets/app_filter_bar.dart';
import 'package:mobile_in_out/core/utils/widgets/app_list_tile.dart';
import 'package:mobile_in_out/core/utils/widgets/row_data_user.dart';
import 'package:mobile_in_out/feature/profile/page/profile_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ReservationListPage extends StatelessWidget {
  const ReservationListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarIconCenter(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            AppListTile(
              onTap: () => context.router.popForced(),
              title: 'Reservation List',
              style: AppStyle(
                color: AppColors.blackColor,
                weight: FontWeight.bold,
              ).headline2,
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.add,
                  color: AppColors.primaryColor,
                  size: 40,
                ),
              ),
            ).verticalPadded(10),
            const AppFilterBar(),
            Expanded(
              child: ListView.builder(
                itemCount: ListOf.dataUserReservation.length,
                itemBuilder: (context, index) {
                  final reservation = ListOf.dataUserReservation[index];
                  return BiodataContainer(
                    child: Column(
                      children: [
                        UserDataRow(
                          label: 'Date:',
                          value: reservation.date!,
                        ),
                        UserDataRow(
                          label: 'Guest Name:',
                          value: reservation.guestName!,
                        ),
                        UserDataRow(
                          label: 'Meet With:',
                          value: reservation.meetWith!,
                        ),
                        UserDataRow(
                          label: 'Reserved Time:',
                          value: reservation.reservedTime!,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}