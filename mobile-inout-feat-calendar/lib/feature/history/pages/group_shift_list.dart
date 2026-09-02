import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/group_shift_model.dart';
import 'package:mobile_in_out/core/utils/models/history/history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/in_and_out/providers/in_out_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late InOutProvider _inOutProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    _inOutProvider = context.read<InOutProvider>();
    _authProvider = context.read<AuthProvider>();

    _getSroupShift();
    super.initState();
  }

  _getSroupShift() {
    Future.microtask(() {
      context.read<InOutProvider>()
        ..getWorkSschedule(
          request: ListDataRequest(
            page: 0,
            limit: 100,
            search: "",
            sortBy: "created",
            orderBy: "desc",
            filter: {"employee_id": _authProvider.profileModel.userId},
          ),
        )
        ..getGroupShiftList(
          request: ListDataRequest(
            page: 0,
            limit: 100,
            search: "",
            sortBy: "created",
            orderBy: "desc",
            filter: {"employee_id": _authProvider.profileModel.userId},
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate('work_schedule'))),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Consumer<InOutProvider>(
      builder: (context, provider, child) {
        switch (provider.groupShiftListState) {
          case RequestState.Loading:
            return const Center(child: CircularProgressIndicator());
          case RequestState.Loaded:
            return _buildList(provider.groupShiftList);
          case RequestState.Error:
            return Center(child: Text(provider.errMsg ?? ''));
          default:
            return SizedBox(child: Text(AppTranslations.translate('no_data')));
        }
      },
    );
  }

  Widget _buildList(
    // Comment because deprecated, when already stable please removed
    // List<GroupShiftModel> listShift
    List<GroupShiftScheduleResponse> listShift,
  ) {
    return ListView.builder(
      itemCount: listShift.length,
      itemBuilder: (context, index) {
        final item = listShift[index];

        return InkWell(
          onTap: () {
            // Handle tap event
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.translate('day'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  getDayName(item.businessDayId ?? 0),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ).bottomPadded(8),
                Text(
                  AppTranslations.translate('time_in'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ).bottomPadded(8),
                Text(
                  item.shiftStartTime ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ).bottomPadded(8),
                Text(
                  AppTranslations.translate('time_out'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ).bottomPadded(8),
                Text(
                  item.shiftEndTime ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ).bottomPadded(8),
                Text(
                  AppTranslations.translate('location'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.locationName ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ).bottomPadded(8),
                Text(
                  AppTranslations.translate('effective_date'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  // Comment because deprecated, when already stable please removed
                  // item.groupShift?.startDate?.formatTime() ?? "",
                  item.shiftStartTime ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ).bottomPadded(8),
              ],
            ).horizontalPadded(8).verticalPadded(8),
          ),
        );
      },
    );
  }

  // Get total hours by calculate time in and time out on each item
  String getTotalHours(AbsenceRecord item) {
    final hoursLabel = AppTranslations.translate('hours');
    final minutesLabel = AppTranslations.translate('minutes');
    final timeIn = item.timeIn ?? '';
    final timeOut = item.timeOut ?? '';

    final duration = DateTime.tryParse(
      timeOut,
    )?.difference(DateTime.parse(timeIn));

    // return duration in hours and minutes
    return '${duration?.inHours ?? 0} $hoursLabel ${duration?.inMinutes.remainder(60) ?? 0} $minutesLabel';
  }
}

String getDayName(int dayNumber) {
  final daysOfWeek = [
    AppTranslations.translate('minggu'),
    AppTranslations.translate('senin'),
    AppTranslations.translate('selasa'),
    AppTranslations.translate('rabu'),
    AppTranslations.translate('kamis'),
    AppTranslations.translate('jumat'),
    AppTranslations.translate('sabtu'),
  ];

  if (dayNumber < 0 || dayNumber > 6) {
    throw ArgumentError('Day number must be between 0 and 6');
  }

  return daysOfWeek[dayNumber];
}
