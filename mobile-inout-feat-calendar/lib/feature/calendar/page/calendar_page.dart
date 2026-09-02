import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_in_out/core/resources/constants/app_font.dart';
import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:mobile_in_out/core/utils/widgets/app_coming_soon.dart';
import 'package:mobile_in_out/core/utils/widgets/app_line.dart';
import 'package:mobile_in_out/feature/calendar/data/model/google_calendar_event_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_schedule.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';
import 'package:mobile_in_out/feature/calendar/helper/calendar_helper.dart';
import 'package:mobile_in_out/feature/calendar/page/create_event_page.dart';
import 'package:mobile_in_out/app.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/calendar_state_provider.dart';
import 'package:table_calendar/table_calendar.dart';

@RoutePage()
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> with RouteAware {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  List<CalendarEventItem> _eventsForDay = [];
  List<ResponseEvents> _scheduleForDay = [];
  List<MenuItem> _menuItem = [];
  final bool _disableThisFeature = false;
  final int _page = 0;
  final int _limit = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
      _fetchSchedule();
      _setDataMenu();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _onRefresh();
  }

  void _clearEvent() {
    _eventsForDay.clear();
    _scheduleForDay.clear();
  }

  List<ResponseEvents> _getScheduleForDay(
    DateTime day,
    List<ResponseEvents> scheduleData,
  ) {
    return scheduleData.where((e) {
      final start = DateTime.tryParse(e.eventDateStart ?? '');
      final end = e.eventDateEnd != null
          ? DateTime.tryParse(e.eventDateEnd!)
          : null;

      if (start == null) return false;

      final dayOnly = DateTime(day.year, day.month, day.day);
      final startOnly = DateTime(start.year, start.month, start.day);

      if (end != null) {
        final endOnly = DateTime(end.year, end.month, end.day);
        return !dayOnly.isBefore(startOnly) && !dayOnly.isAfter(endOnly);
      }

      return isSameDay(startOnly, dayOnly);
    }).toList();
  }

  void _fetchEvents() {
    final range = getCalendarRange(
      focusedDay: _selectedDay,
      format: _calendarFormat,
    );
    ref
        .read(calendarEventsNotifierProvider.notifier)
        .fetchEvents(timeMin: range.start, timeMax: range.end);
  }

  void _fetchSchedule() {
    final range = getCalendarRange(
      focusedDay: _selectedDay,
      format: _calendarFormat,
    );
    log('range start : ${range.start}');
    log('range end : ${range.end}');

    String startDate =
        DateHelper.convertStringToDateTimeFormat(range.start, "yyyy-MM-dd") ??
        '';
    String endDate =
        DateHelper.convertStringToDateTimeFormat(range.end, "yyyy-MM-dd") ?? '';

    log('start date : $startDate');
    log('end date : $endDate');

    ref
        .read(scheduleNotifierProvider.notifier)
        .getSchedule(
          RequestSchedule(
            offset: _page,
            limit: _limit,
            sortBy: 'created',
            orderBy: 'asc',
            eventDateStart: startDate,
            eventDateEnd: endDate,
          ),
        );
  }

  Future<void> _setDataMenu() async {
    setState(() {
      _menuItem.clear();
      _menuItem.add(
        MenuItem(
          typeMenu: TypeMenu.meeting,
          icon: Assets.icMeeting,
          title: 'Meeting',
        ),
      );
      _menuItem.add(
        MenuItem(
          typeMenu: TypeMenu.offsiteRequest,
          icon: Assets.icOffsetRequest,
          title: 'Offsite Request',
        ),
      );
      _menuItem.add(
        MenuItem(
          typeMenu: TypeMenu.visitor,
          icon: Assets.icVisitor,
          title: 'Visitor',
        ),
      );
      _menuItem.add(
        MenuItem(
          typeMenu: TypeMenu.leaveRequest,
          icon: Assets.icLeaveRequest,
          title: 'Leave Request',
        ),
      );
    });
  }

  Future<void> _onRefresh() async {
    _fetchEvents();
    _fetchSchedule();
  }

  List<CalendarEventItem> _getEventsForDay(DateTime day) {
    final state = ref.watch(calendarEventsNotifierProvider);
    final items = state.data?.items ?? [];
    return items.where((e) {
      final start = e.startDate;
      final end = e.endDate;
      if (start == null) return false;
      if (end != null) {
        return !day.isBefore(start) && !day.isAfter(end);
      }
      return isSameDay(start, day);
    }).toList();
  }

  List<CalendarDayEvent> _getAllEventsForDay(
    DateTime day,
    List<ResponseEvents> scheduleData,
  ) {
    final googleEvents = _getEventsForDay(day);
    final scheduleEvents = scheduleData.where((e) {
      final start = DateTime.tryParse(e.eventDateStart ?? '');
      final end = e.eventDateEnd != null
          ? DateTime.tryParse(e.eventDateEnd!)
          : null;

      if (start == null) return false;

      final dayOnly = DateTime(day.year, day.month, day.day);
      final startOnly = DateTime(start.year, start.month, start.day);

      if (end != null) {
        final endOnly = DateTime(end.year, end.month, end.day);
        return !dayOnly.isBefore(startOnly) && !dayOnly.isAfter(endOnly);
      }

      return isSameDay(startOnly, dayOnly);
    }).toList();

    final allEvents = <CalendarDayEvent>[
      ...googleEvents.map((e) => CalendarDayEvent(googleEvent: e)),
      ...scheduleEvents.map((e) => CalendarDayEvent(scheduleEvent: e)),
    ];

    allEvents.sort((a, b) {
      final aDate =
          a.googleEvent?.startDate ??
          DateTime.tryParse(a.scheduleEvent?.eventDateStart ?? '');
      final bDate =
          b.googleEvent?.startDate ??
          DateTime.tryParse(b.scheduleEvent?.eventDateStart ?? '');

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return allEvents;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    setState(() {
      _eventsForDay = _getEventsForDay(selectedDay);
      final scheduleData = ref.read(scheduleNotifierProvider).data ?? [];
      _scheduleForDay = _getScheduleForDay(selectedDay, scheduleData);
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _selectedDay = focusedDay;
    });
    _clearEvent();
    _fetchEvents();
    _fetchSchedule();
  }

  Widget _itemViewData(ResponseEvents schedule) {
    return InkWell(
      onTap: () async {
        log('Clicked: ${schedule.eventId}');
        final result = await context.router.push(
          DetailEventRoute(scheduleEvent: schedule),
        );
        if (result == true) {
          _clearEvent();
          _fetchEvents();
          _fetchSchedule();
        }
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (schedule.eventDateStart != null)
                    ? DateHelper.convertDateStringToFormat(
                            schedule.eventDateStart!,
                            "HH:mm",
                          ) ??
                          '-'
                    : '-',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.black,
                  fontFamily: AppFont.fontMontserrat,
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.eventName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.black,
                        fontFamily: AppFont.fontMontserrat,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      schedule.locationId ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.black,
                        fontFamily: AppFont.fontMontserrat,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          AppLine(),
        ],
      ),
    );
  }

  Widget _itemView(CalendarEventItem event) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.summary ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.black,
                      fontFamily: AppFont.fontMontserrat,
                    ),
                  ),
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    SizedBox(height: 7),
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.black.withOpacity(0.6),
                        fontFamily: AppFont.fontMontserrat,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 7),
        AppLine(),
      ],
    );
  }

  Widget _itemMenu(MenuItem item) {
    return InkWell(
      onTap: () async {
        context.router.pop();
        switch (item.typeMenu) {
          case TypeMenu.meeting:
            final result = await context.router.push(
              CreateEventRoute(typeEvent: TypeEvent.meeting),
            );
            if (result == true) {
              _clearEvent();
              _fetchEvents();
              _fetchSchedule();
            }
            break;
          case TypeMenu.offsiteRequest:
            final result = await context.router.push(
              CreateEventRoute(typeEvent: TypeEvent.offsiteRequest),
            );
            if (result == true) {
              _clearEvent();
              _fetchEvents();
              _fetchSchedule();
            }
            break;
          case TypeMenu.visitor:
            //Todo: navigate to visitor page
            break;
          case TypeMenu.leaveRequest:
            //Todo: navigate to leave request page
            break;
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(item.icon, width: 32),
              SizedBox(width: 7),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                  fontFamily: AppFont.fontMontserrat,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          AppLine(height: 1),
        ],
      ),
    );
  }

  void _bottomSheetCreateEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.whiteColor,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => context.router.popForced(),
                  icon: Image.asset(Assets.icCloseCircle, width: 32),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menuItem.length,
                itemBuilder: (context, index) {
                  return _itemMenu(_menuItem[index]);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 15),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarEventsNotifierProvider);
    final scheduleState = ref.watch(scheduleNotifierProvider);
    final scheduleData = scheduleState.data ?? [];
    _eventsForDay = _getEventsForDay(_selectedDay);
    _scheduleForDay = _getScheduleForDay(_selectedDay, scheduleData);

    if (_disableThisFeature) {
      return Scaffold(
        appBar: const AppBarIconCenter(),
        body: const SafeArea(
          child: AppComingSoon(
            title: 'Calendar Feature',
            message: 'This feature is currently disabled.',
            icon: Icons.calendar_today,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const AppBarIconCenter(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppTranslations.translate('calendar'),
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontMontserrat,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => {_bottomSheetCreateEvent()},
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Image.asset(Assets.icPlush, width: 32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _calendarFormat = CalendarFormat.week;
                                });
                                _fetchEvents();
                                _fetchSchedule();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _calendarFormat == CalendarFormat.week
                                      ? AppColors.primaryColor
                                      : AppColors.grey,
                                ),
                                child: Center(
                                  child: Text(
                                    AppTranslations.translate('week'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _calendarFormat = CalendarFormat.month;
                                });
                                _fetchEvents();
                                _fetchSchedule();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _calendarFormat == CalendarFormat.month
                                      ? AppColors.primaryColor
                                      : AppColors.grey,
                                ),
                                child: Center(
                                  child: Text(
                                    AppTranslations.translate('month'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableCalendar(
                        firstDay: DateTime.utc(2010, 1, 1),
                        lastDay: DateTime.utc(2050, 12, 31),
                        focusedDay: _selectedDay,
                        calendarFormat: _calendarFormat,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                        ),
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                          CalendarFormat.week: 'Week',
                        },
                        eventLoader: (day) {
                          return _getAllEventsForDay(day, scheduleData);
                        },
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          todayDecoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(color: Colors.black),
                          markersMaxCount: 3,
                          markerSize: 8,
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            if (events.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final hasGoogle = events.any(
                              (e) => e is CalendarDayEvent && e.isGoogleEvent,
                            );
                            final hasSchedule = events.any(
                              (e) => e is CalendarDayEvent && e.isScheduleEvent,
                            );
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasGoogle)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (hasSchedule)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          dowTextFormatter: (date, locale) {
                            return DateFormat.E(locale).format(date)[0];
                          },
                        ),
                        onPageChanged: _onPageChanged,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: _onDaySelected,
                      ),
                    ],
                  ),
                ),
              ),
              if (_eventsForDay.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      AppTranslations.translate('public_holiday'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.black,
                        fontFamily: AppFont.fontMontserrat,
                      ),
                    ),
                  ),
                ),
              if (calendarState.state == ConcreteState.loading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (calendarState.state == ConcreteState.failure)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        calendarState.message,
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: AppFont.fontMontserrat,
                        ),
                      ),
                    ),
                  ),
                )
              else if (_selectedDay != null)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _eventsForDay.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                AppTranslations.translate('no_events_calendar'),
                                style: TextStyle(
                                  color: AppColors.black.withOpacity(0.5),
                                  fontFamily: AppFont.fontMontserrat,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: _eventsForDay.length,
                          itemBuilder: (context, index) {
                            return _itemView(_eventsForDay[index]);
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                        ),
                ),
              if (_scheduleForDay.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Text(
                      AppTranslations.translate('event'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.black,
                        fontFamily: AppFont.fontMontserrat,
                      ),
                    ),
                  ),
                ),
              if (scheduleState.state == ConcreteState.loading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (scheduleState.state == ConcreteState.failure)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        scheduleState.message,
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: AppFont.fontMontserrat,
                        ),
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _scheduleForDay.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              AppTranslations.translate('no_events_schedule'),
                              style: TextStyle(
                                color: AppColors.black.withOpacity(0.5),
                                fontFamily: AppFont.fontMontserrat,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _scheduleForDay.length,
                        itemBuilder: (context, index) {
                          return _itemViewData(_scheduleForDay[index]);
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  String icon;
  String title;
  TypeMenu typeMenu;

  MenuItem({required this.icon, required this.title, required this.typeMenu});
}

enum TypeMenu { meeting, offsiteRequest, visitor, leaveRequest }

class CalendarDayEvent {
  final CalendarEventItem? googleEvent;
  final ResponseEvents? scheduleEvent;

  const CalendarDayEvent({this.googleEvent, this.scheduleEvent});

  bool get isGoogleEvent => googleEvent != null;
  bool get isScheduleEvent => scheduleEvent != null;
}
