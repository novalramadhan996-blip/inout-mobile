import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/history/history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late HistoryProvider _historyProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    _historyProvider = context.read<HistoryProvider>();
    _authProvider = context.read<AuthProvider>();

    _getHistory();
    super.initState();
  }

  _getHistory() {
    // please using param accountId when api not using dummy data
    final String accountId = _authProvider.profileModel.accountId ?? '';

    Future.microtask(
      () => _historyProvider.getHistory(
        ListDataRequest(
          page: 0,
          limit: 100,
          search: "",
          orderBy: "desc",
          sortBy: "created",
          filter: {"employee_id": _authProvider.profileModel.userId},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate('history_pages'))),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        LogHelper.logDebug(
          'provider state: ${provider.state}'
          'name: HistoryPage',
        );
        switch (provider.state) {
          case RequestState.Loading:
            return const Center(child: CircularProgressIndicator());
          case RequestState.Loaded:
            LogHelper.logDebug(
              'History data loaded: ${provider.history}'
              'name: HistoryPage',
            );
            return _buildList(provider.history);
          case RequestState.Error:
            LogHelper.logDebug(
              'Error: ${provider.errorMessage}'
              'name: HistoryPage',
            );
            return Center(child: Text(provider.errorMessage));
          default:
            return SizedBox(child: Text(AppTranslations.translate('no_data')));
        }
      },
    );
  }

  Widget _buildList(
    // Comment because deprecated, when already stable please removed
    // List<AbsenceRecord> history
    List<AbsenceHistoryModel> history,
  ) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];

        return InkWell(
          onTap: () {
            context.router.push(
              DetailHistory(absenceId: item.attendanceId ?? ''),
            );
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
                AppLabel(label: AppTranslations.translate('check_in')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(getTimeByStatus('IN', item)),
                ).bottomPadded(),
                AppLabel(label: AppTranslations.translate('check_out')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(getTimeByStatus('OUT', item)),
                ).bottomPadded(),
                AppLabel(label: AppTranslations.translate('address_in')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.addressIn ?? ''),
                ).bottomPadded(),
                AppLabel(label: AppTranslations.translate('address_out')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.addressOut ?? ''),
                ).bottomPadded(),
                AppLabel(label: AppTranslations.translate('total_hours')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(getTotalHours(item)),
                ).bottomPadded(),
              ],
            ).horizontalPadded(8).verticalPadded(8),
          ),
        );
      },
    );
  }

  String getTimeByStatus(String status, AbsenceHistoryModel item) {
    String? timeString = (status == 'IN') ? item.dateIn : item.dateOut;

    if (timeString == null || timeString.isEmpty) return '';

    DateTime dateTime;
    try {
      // Fix timezone if needed
      timeString = timeString.replaceFirst(
        RegExp(r'\+(\d):(\d)$'),
        r'+0$1:0$2',
      );

      dateTime = DateTime.parse(timeString);
    } catch (e) {
      return timeString ?? '-';
    }

    // Convert to GMT+7
    dateTime = dateTime.add(Duration(hours: 7));

    final formatted = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    return formatted;
  }

  String getTotalHours(AbsenceHistoryModel item) {
    final hoursLabel = AppTranslations.translate('hours');
    final minutesLabel = AppTranslations.translate('minutes');

    if (item.dateIn == null || item.dateOut == null) {
      return '0 $minutesLabel';
    }

    // Fix timezone if needed and parse
    String timeInStr = item.dateIn!.replaceFirst(
      RegExp(r'\+(\d):(\d)$'),
      r'+0$1:0$2',
    );
    String timeOutStr = item.dateOut!.replaceFirst(
      RegExp(r'\+(\d):(\d)$'),
      r'+0$1:0$2',
    );

    DateTime timeIn = DateTime.parse(timeInStr).add(Duration(hours: 7));
    DateTime timeOut = DateTime.parse(timeOutStr).add(Duration(hours: 7));

    Duration diff = timeOut.difference(timeIn);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    if (hours == 0 && minutes == 0) return '0 $minutesLabel';
    if (hours == 0) return '$minutes $minutesLabel';
    if (minutes == 0) return '$hours $hoursLabel';

    return '$hours $hoursLabel $minutes $minutesLabel';
  }
}
