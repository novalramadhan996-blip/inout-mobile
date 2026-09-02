// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i44;
import 'package:collection/collection.dart' as _i49;
import 'package:flutter/material.dart' as _i45;
import 'package:geolocator/geolocator.dart' as _i47;
import 'package:mobile_in_out/feature/absence/presentation/absence_page.dart'
    as _i1;
import 'package:mobile_in_out/feature/auth/sign_in/sign_in_page.dart' as _i38;
import 'package:mobile_in_out/feature/auth/sign_up/page/face_registration_page.dart'
    as _i16;
import 'package:mobile_in_out/feature/auth/sign_up/page/otp.dart' as _i29;
import 'package:mobile_in_out/feature/auth/sign_up/page/register_face.dart'
    as _i33;
import 'package:mobile_in_out/feature/auth/sign_up/page/sign_up_page.dart'
    as _i40;
import 'package:mobile_in_out/feature/auth/sign_up/page/sign_up_page_new.dart'
    as _i39;
import 'package:mobile_in_out/feature/board/model/profile_user_model.dart'
    as _i50;
import 'package:mobile_in_out/feature/board/page/board_page.dart' as _i2;
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart'
    as _i46;
import 'package:mobile_in_out/feature/calendar/page/calendar_page.dart' as _i3;
import 'package:mobile_in_out/feature/calendar/page/checkin_meeting_page.dart'
    as _i10;
import 'package:mobile_in_out/feature/calendar/page/create_event_page.dart'
    as _i11;
import 'package:mobile_in_out/feature/calendar/page/detail_event_page.dart'
    as _i12;
import 'package:mobile_in_out/feature/calendar/page/qr_code_meeting_page.dart'
    as _i32;
import 'package:mobile_in_out/feature/change_password/change_password_page.dart'
    as _i4;
import 'package:mobile_in_out/feature/chat/chat_list_screen.dart' as _i5;
import 'package:mobile_in_out/feature/chat/chat_room_screen.dart' as _i6;
import 'package:mobile_in_out/feature/forgot_password/pages/fp_password.dart'
    as _i17;
import 'package:mobile_in_out/feature/forgot_password/pages/fp_username.dart'
    as _i18;
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart'
    as _i48;
import 'package:mobile_in_out/feature/history/pages/detail_history.dart'
    as _i13;
import 'package:mobile_in_out/feature/history/pages/group_shift_list.dart'
    as _i19;
import 'package:mobile_in_out/feature/history/pages/history_page.dart' as _i21;
import 'package:mobile_in_out/feature/home/presentation/home_page.dart' as _i22;
import 'package:mobile_in_out/feature/home/presentation/main_page.dart' as _i27;
import 'package:mobile_in_out/feature/home_v2/presentation/home_page_scroll_v2.dart'
    as _i23;
import 'package:mobile_in_out/feature/home_v2/presentation/home_page_v2.dart'
    as _i24;
import 'package:mobile_in_out/feature/in_and_out/checkin/checkin_page.dart'
    as _i7;
import 'package:mobile_in_out/feature/in_and_out/checkin/checkin_submit.dart'
    as _i8;
import 'package:mobile_in_out/feature/in_and_out/checkin/checkout_submit.dart'
    as _i9;
import 'package:mobile_in_out/feature/maps/page/map_page.dart' as _i28;
import 'package:mobile_in_out/feature/profile/page/profile_page.dart' as _i31;
import 'package:mobile_in_out/feature/profile/page/settings/face_registration_page.dart'
    as _i15;
import 'package:mobile_in_out/feature/profile/page/settings/profile_registration_page.dart'
    as _i30;
import 'package:mobile_in_out/feature/reception/guest/guest_list_page.dart'
    as _i20;
import 'package:mobile_in_out/feature/reception/home/home_reservation.dart'
    as _i25;
import 'package:mobile_in_out/feature/reception/reservation/reservation_list.dart'
    as _i36;
import 'package:mobile_in_out/feature/report_activity/presentation/list_report_activity_screen.dart'
    as _i26;
import 'package:mobile_in_out/feature/report_activity/presentation/report_activity_screen.dart'
    as _i35;
import 'package:mobile_in_out/feature/setting/device_info/presentation/device_info_page.dart'
    as _i14;
import 'package:mobile_in_out/feature/setting/page/setting_page.dart' as _i37;
import 'package:mobile_in_out/feature/setting/reminder_absensi/page/reminder_absensi_page.dart'
    as _i34;
import 'package:mobile_in_out/feature/splash/presentation/splash_page.dart'
    as _i41;
import 'package:mobile_in_out/feature/task/page/task_page.dart' as _i42;
import 'package:mobile_in_out/feature/todo/page/todo_page.dart' as _i43;

/// generated route for
/// [_i1.AbsencePage]
class AbsenceRoute extends _i44.PageRouteInfo<AbsenceRouteArgs> {
  AbsenceRoute({
    _i45.Key? key,
    required bool showBackButton,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         AbsenceRoute.name,
         args: AbsenceRouteArgs(key: key, showBackButton: showBackButton),
         initialChildren: children,
       );

  static const String name = 'AbsenceRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AbsenceRouteArgs>();
      return _i1.AbsencePage(
        key: args.key,
        showBackButton: args.showBackButton,
      );
    },
  );
}

class AbsenceRouteArgs {
  const AbsenceRouteArgs({this.key, required this.showBackButton});

  final _i45.Key? key;

  final bool showBackButton;

  @override
  String toString() {
    return 'AbsenceRouteArgs{key: $key, showBackButton: $showBackButton}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AbsenceRouteArgs) return false;
    return key == other.key && showBackButton == other.showBackButton;
  }

  @override
  int get hashCode => key.hashCode ^ showBackButton.hashCode;
}

/// generated route for
/// [_i2.BoardPage]
class BoardRoute extends _i44.PageRouteInfo<BoardRouteArgs> {
  BoardRoute({
    _i45.Key? key,
    required String projectId,
    required String title,
    required String imgUrl,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         BoardRoute.name,
         args: BoardRouteArgs(
           key: key,
           projectId: projectId,
           title: title,
           imgUrl: imgUrl,
         ),
         initialChildren: children,
       );

  static const String name = 'BoardRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BoardRouteArgs>();
      return _i2.BoardPage(
        key: args.key,
        projectId: args.projectId,
        title: args.title,
        imgUrl: args.imgUrl,
      );
    },
  );
}

class BoardRouteArgs {
  const BoardRouteArgs({
    this.key,
    required this.projectId,
    required this.title,
    required this.imgUrl,
  });

  final _i45.Key? key;

  final String projectId;

  final String title;

  final String imgUrl;

  @override
  String toString() {
    return 'BoardRouteArgs{key: $key, projectId: $projectId, title: $title, imgUrl: $imgUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardRouteArgs) return false;
    return key == other.key &&
        projectId == other.projectId &&
        title == other.title &&
        imgUrl == other.imgUrl;
  }

  @override
  int get hashCode =>
      key.hashCode ^ projectId.hashCode ^ title.hashCode ^ imgUrl.hashCode;
}

/// generated route for
/// [_i3.CalendarPage]
class CalendarRoute extends _i44.PageRouteInfo<void> {
  const CalendarRoute({List<_i44.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i3.CalendarPage();
    },
  );
}

/// generated route for
/// [_i4.ChangePasswordPage]
class ChangePasswordRoute extends _i44.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i44.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i4.ChangePasswordPage();
    },
  );
}

/// generated route for
/// [_i5.ChatPage]
class ChatRoute extends _i44.PageRouteInfo<void> {
  const ChatRoute({List<_i44.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i5.ChatPage();
    },
  );
}

/// generated route for
/// [_i6.ChatRoomPage]
class ChatRoomRoute extends _i44.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i45.Key? key,
    required String nameUser,
    required String imageUrl,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(
           key: key,
           nameUser: nameUser,
           imageUrl: imageUrl,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRoomRouteArgs>();
      return _i6.ChatRoomPage(
        key: args.key,
        nameUser: args.nameUser,
        imageUrl: args.imageUrl,
      );
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({
    this.key,
    required this.nameUser,
    required this.imageUrl,
  });

  final _i45.Key? key;

  final String nameUser;

  final String imageUrl;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, nameUser: $nameUser, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRoomRouteArgs) return false;
    return key == other.key &&
        nameUser == other.nameUser &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode => key.hashCode ^ nameUser.hashCode ^ imageUrl.hashCode;
}

/// generated route for
/// [_i7.CheckInPage]
class CheckInRoute extends _i44.PageRouteInfo<void> {
  const CheckInRoute({List<_i44.PageRouteInfo>? children})
    : super(CheckInRoute.name, initialChildren: children);

  static const String name = 'CheckInRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i7.CheckInPage();
    },
  );
}

/// generated route for
/// [_i8.CheckInSubmitPage]
class CheckInSubmitRoute extends _i44.PageRouteInfo<CheckInSubmitRouteArgs> {
  CheckInSubmitRoute({
    _i45.Key? key,
    required String typeAbsence,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         CheckInSubmitRoute.name,
         args: CheckInSubmitRouteArgs(key: key, typeAbsence: typeAbsence),
         initialChildren: children,
       );

  static const String name = 'CheckInSubmitRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckInSubmitRouteArgs>();
      return _i8.CheckInSubmitPage(
        key: args.key,
        typeAbsence: args.typeAbsence,
      );
    },
  );
}

class CheckInSubmitRouteArgs {
  const CheckInSubmitRouteArgs({this.key, required this.typeAbsence});

  final _i45.Key? key;

  final String typeAbsence;

  @override
  String toString() {
    return 'CheckInSubmitRouteArgs{key: $key, typeAbsence: $typeAbsence}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckInSubmitRouteArgs) return false;
    return key == other.key && typeAbsence == other.typeAbsence;
  }

  @override
  int get hashCode => key.hashCode ^ typeAbsence.hashCode;
}

/// generated route for
/// [_i9.CheckOutSubmitPage]
class CheckOutSubmitRoute extends _i44.PageRouteInfo<void> {
  const CheckOutSubmitRoute({List<_i44.PageRouteInfo>? children})
    : super(CheckOutSubmitRoute.name, initialChildren: children);

  static const String name = 'CheckOutSubmitRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i9.CheckOutSubmitPage();
    },
  );
}

/// generated route for
/// [_i10.CheckinMeetingPage]
class CheckinMeetingRoute extends _i44.PageRouteInfo<CheckinMeetingRouteArgs> {
  CheckinMeetingRoute({
    _i45.Key? key,
    bool isCheckin = false,
    String? checkInId,
    String? eventId,
    String? eventEmployeeId,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         CheckinMeetingRoute.name,
         args: CheckinMeetingRouteArgs(
           key: key,
           isCheckin: isCheckin,
           checkInId: checkInId,
           eventId: eventId,
           eventEmployeeId: eventEmployeeId,
         ),
         initialChildren: children,
       );

  static const String name = 'CheckinMeetingRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckinMeetingRouteArgs>(
        orElse: () => const CheckinMeetingRouteArgs(),
      );
      return _i10.CheckinMeetingPage(
        key: args.key,
        isCheckin: args.isCheckin,
        checkInId: args.checkInId,
        eventId: args.eventId,
        eventEmployeeId: args.eventEmployeeId,
      );
    },
  );
}

class CheckinMeetingRouteArgs {
  const CheckinMeetingRouteArgs({
    this.key,
    this.isCheckin = false,
    this.checkInId,
    this.eventId,
    this.eventEmployeeId,
  });

  final _i45.Key? key;

  final bool isCheckin;

  final String? checkInId;

  final String? eventId;

  final String? eventEmployeeId;

  @override
  String toString() {
    return 'CheckinMeetingRouteArgs{key: $key, isCheckin: $isCheckin, checkInId: $checkInId, eventId: $eventId, eventEmployeeId: $eventEmployeeId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckinMeetingRouteArgs) return false;
    return key == other.key &&
        isCheckin == other.isCheckin &&
        checkInId == other.checkInId &&
        eventId == other.eventId &&
        eventEmployeeId == other.eventEmployeeId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      isCheckin.hashCode ^
      checkInId.hashCode ^
      eventId.hashCode ^
      eventEmployeeId.hashCode;
}

/// generated route for
/// [_i11.CreateEventPage]
class CreateEventRoute extends _i44.PageRouteInfo<CreateEventRouteArgs> {
  CreateEventRoute({
    _i45.Key? key,
    required _i11.TypeEvent typeEvent,
    String? eventId,
    String? eventName,
    String? eventDateStart,
    String? eventDateEnd,
    String? locationId,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         CreateEventRoute.name,
         args: CreateEventRouteArgs(
           key: key,
           typeEvent: typeEvent,
           eventId: eventId,
           eventName: eventName,
           eventDateStart: eventDateStart,
           eventDateEnd: eventDateEnd,
           locationId: locationId,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateEventRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateEventRouteArgs>();
      return _i11.CreateEventPage(
        key: args.key,
        typeEvent: args.typeEvent,
        eventId: args.eventId,
        eventName: args.eventName,
        eventDateStart: args.eventDateStart,
        eventDateEnd: args.eventDateEnd,
        locationId: args.locationId,
      );
    },
  );
}

class CreateEventRouteArgs {
  const CreateEventRouteArgs({
    this.key,
    required this.typeEvent,
    this.eventId,
    this.eventName,
    this.eventDateStart,
    this.eventDateEnd,
    this.locationId,
  });

  final _i45.Key? key;

  final _i11.TypeEvent typeEvent;

  final String? eventId;

  final String? eventName;

  final String? eventDateStart;

  final String? eventDateEnd;

  final String? locationId;

  @override
  String toString() {
    return 'CreateEventRouteArgs{key: $key, typeEvent: $typeEvent, eventId: $eventId, eventName: $eventName, eventDateStart: $eventDateStart, eventDateEnd: $eventDateEnd, locationId: $locationId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateEventRouteArgs) return false;
    return key == other.key &&
        typeEvent == other.typeEvent &&
        eventId == other.eventId &&
        eventName == other.eventName &&
        eventDateStart == other.eventDateStart &&
        eventDateEnd == other.eventDateEnd &&
        locationId == other.locationId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      typeEvent.hashCode ^
      eventId.hashCode ^
      eventName.hashCode ^
      eventDateStart.hashCode ^
      eventDateEnd.hashCode ^
      locationId.hashCode;
}

/// generated route for
/// [_i12.DetailEventPage]
class DetailEventRoute extends _i44.PageRouteInfo<DetailEventRouteArgs> {
  DetailEventRoute({
    _i45.Key? key,
    _i46.ResponseEvents? scheduleEvent,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         DetailEventRoute.name,
         args: DetailEventRouteArgs(key: key, scheduleEvent: scheduleEvent),
         initialChildren: children,
       );

  static const String name = 'DetailEventRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailEventRouteArgs>(
        orElse: () => const DetailEventRouteArgs(),
      );
      return _i12.DetailEventPage(
        key: args.key,
        scheduleEvent: args.scheduleEvent,
      );
    },
  );
}

class DetailEventRouteArgs {
  const DetailEventRouteArgs({this.key, this.scheduleEvent});

  final _i45.Key? key;

  final _i46.ResponseEvents? scheduleEvent;

  @override
  String toString() {
    return 'DetailEventRouteArgs{key: $key, scheduleEvent: $scheduleEvent}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailEventRouteArgs) return false;
    return key == other.key && scheduleEvent == other.scheduleEvent;
  }

  @override
  int get hashCode => key.hashCode ^ scheduleEvent.hashCode;
}

/// generated route for
/// [_i13.DetailHistory]
class DetailHistory extends _i44.PageRouteInfo<DetailHistoryArgs> {
  DetailHistory({
    _i45.Key? key,
    required String absenceId,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         DetailHistory.name,
         args: DetailHistoryArgs(key: key, absenceId: absenceId),
         initialChildren: children,
       );

  static const String name = 'DetailHistory';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailHistoryArgs>();
      return _i13.DetailHistory(key: args.key, absenceId: args.absenceId);
    },
  );
}

class DetailHistoryArgs {
  const DetailHistoryArgs({this.key, required this.absenceId});

  final _i45.Key? key;

  final String absenceId;

  @override
  String toString() {
    return 'DetailHistoryArgs{key: $key, absenceId: $absenceId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailHistoryArgs) return false;
    return key == other.key && absenceId == other.absenceId;
  }

  @override
  int get hashCode => key.hashCode ^ absenceId.hashCode;
}

/// generated route for
/// [_i14.DeviceInfoPage]
class DeviceInfoRoute extends _i44.PageRouteInfo<void> {
  const DeviceInfoRoute({List<_i44.PageRouteInfo>? children})
    : super(DeviceInfoRoute.name, initialChildren: children);

  static const String name = 'DeviceInfoRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i14.DeviceInfoPage();
    },
  );
}

/// generated route for
/// [_i15.FaceregistrationPage]
class FaceregistrationRoute extends _i44.PageRouteInfo<void> {
  const FaceregistrationRoute({List<_i44.PageRouteInfo>? children})
    : super(FaceregistrationRoute.name, initialChildren: children);

  static const String name = 'FaceregistrationRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i15.FaceregistrationPage();
    },
  );
}

/// generated route for
/// [_i16.FaceregistrationRegisterPage]
class FaceregistrationRegisterRoute extends _i44.PageRouteInfo<void> {
  const FaceregistrationRegisterRoute({List<_i44.PageRouteInfo>? children})
    : super(FaceregistrationRegisterRoute.name, initialChildren: children);

  static const String name = 'FaceregistrationRegisterRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i16.FaceregistrationRegisterPage();
    },
  );
}

/// generated route for
/// [_i17.ForgotPasswordPass]
class ForgotPasswordPass extends _i44.PageRouteInfo<void> {
  const ForgotPasswordPass({List<_i44.PageRouteInfo>? children})
    : super(ForgotPasswordPass.name, initialChildren: children);

  static const String name = 'ForgotPasswordPass';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i17.ForgotPasswordPass();
    },
  );
}

/// generated route for
/// [_i18.ForgotPasswordUsername]
class ForgotPasswordUsername extends _i44.PageRouteInfo<void> {
  const ForgotPasswordUsername({List<_i44.PageRouteInfo>? children})
    : super(ForgotPasswordUsername.name, initialChildren: children);

  static const String name = 'ForgotPasswordUsername';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i18.ForgotPasswordUsername();
    },
  );
}

/// generated route for
/// [_i19.GroupListPage]
class GroupListRoute extends _i44.PageRouteInfo<void> {
  const GroupListRoute({List<_i44.PageRouteInfo>? children})
    : super(GroupListRoute.name, initialChildren: children);

  static const String name = 'GroupListRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i19.GroupListPage();
    },
  );
}

/// generated route for
/// [_i20.GuestListPage]
class GuestListRoute extends _i44.PageRouteInfo<void> {
  const GuestListRoute({List<_i44.PageRouteInfo>? children})
    : super(GuestListRoute.name, initialChildren: children);

  static const String name = 'GuestListRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i20.GuestListPage();
    },
  );
}

/// generated route for
/// [_i21.HistoryPage]
class HistoryRoute extends _i44.PageRouteInfo<void> {
  const HistoryRoute({List<_i44.PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i21.HistoryPage();
    },
  );
}

/// generated route for
/// [_i22.HomePage]
class HomeRoute extends _i44.PageRouteInfo<void> {
  const HomeRoute({List<_i44.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i22.HomePage();
    },
  );
}

/// generated route for
/// [_i23.HomePageScrollV2]
class HomeRouteScrollV2 extends _i44.PageRouteInfo<void> {
  const HomeRouteScrollV2({List<_i44.PageRouteInfo>? children})
    : super(HomeRouteScrollV2.name, initialChildren: children);

  static const String name = 'HomeRouteScrollV2';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i23.HomePageScrollV2();
    },
  );
}

/// generated route for
/// [_i24.HomePageV2]
class HomeRouteV2 extends _i44.PageRouteInfo<HomeRouteV2Args> {
  HomeRouteV2({
    _i45.Key? key,
    bool? isFromSignIn = false,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         HomeRouteV2.name,
         args: HomeRouteV2Args(key: key, isFromSignIn: isFromSignIn),
         initialChildren: children,
       );

  static const String name = 'HomeRouteV2';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteV2Args>(
        orElse: () => const HomeRouteV2Args(),
      );
      return _i24.HomePageV2(key: args.key, isFromSignIn: args.isFromSignIn);
    },
  );
}

class HomeRouteV2Args {
  const HomeRouteV2Args({this.key, this.isFromSignIn = false});

  final _i45.Key? key;

  final bool? isFromSignIn;

  @override
  String toString() {
    return 'HomeRouteV2Args{key: $key, isFromSignIn: $isFromSignIn}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteV2Args) return false;
    return key == other.key && isFromSignIn == other.isFromSignIn;
  }

  @override
  int get hashCode => key.hashCode ^ isFromSignIn.hashCode;
}

/// generated route for
/// [_i25.HomeReservationPage]
class HomeReservationRoute extends _i44.PageRouteInfo<void> {
  const HomeReservationRoute({List<_i44.PageRouteInfo>? children})
    : super(HomeReservationRoute.name, initialChildren: children);

  static const String name = 'HomeReservationRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i25.HomeReservationPage();
    },
  );
}

/// generated route for
/// [_i26.ListReportActivityScreen]
class ListReportActivityRoute extends _i44.PageRouteInfo<void> {
  const ListReportActivityRoute({List<_i44.PageRouteInfo>? children})
    : super(ListReportActivityRoute.name, initialChildren: children);

  static const String name = 'ListReportActivityRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i26.ListReportActivityScreen();
    },
  );
}

/// generated route for
/// [_i27.MainPage]
class MainRoute extends _i44.PageRouteInfo<void> {
  const MainRoute({List<_i44.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i27.MainPage();
    },
  );
}

/// generated route for
/// [_i28.MapPage]
class MapRoute extends _i44.PageRouteInfo<MapRouteArgs> {
  MapRoute({
    _i45.Key? key,
    required _i47.Position currentPosition,
    required String detailAddress,
    required List<_i48.GroupShiftScheduleResponse> workLocation,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         MapRoute.name,
         args: MapRouteArgs(
           key: key,
           currentPosition: currentPosition,
           detailAddress: detailAddress,
           workLocation: workLocation,
         ),
         initialChildren: children,
       );

  static const String name = 'MapRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MapRouteArgs>();
      return _i28.MapPage(
        key: args.key,
        currentPosition: args.currentPosition,
        detailAddress: args.detailAddress,
        workLocation: args.workLocation,
      );
    },
  );
}

class MapRouteArgs {
  const MapRouteArgs({
    this.key,
    required this.currentPosition,
    required this.detailAddress,
    required this.workLocation,
  });

  final _i45.Key? key;

  final _i47.Position currentPosition;

  final String detailAddress;

  final List<_i48.GroupShiftScheduleResponse> workLocation;

  @override
  String toString() {
    return 'MapRouteArgs{key: $key, currentPosition: $currentPosition, detailAddress: $detailAddress, workLocation: $workLocation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapRouteArgs) return false;
    return key == other.key &&
        currentPosition == other.currentPosition &&
        detailAddress == other.detailAddress &&
        const _i49.ListEquality<_i48.GroupShiftScheduleResponse>().equals(
          workLocation,
          other.workLocation,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      currentPosition.hashCode ^
      detailAddress.hashCode ^
      const _i49.ListEquality<_i48.GroupShiftScheduleResponse>().hash(
        workLocation,
      );
}

/// generated route for
/// [_i29.OtpPage]
class OtpRoute extends _i44.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    _i45.Key? key,
    required String email,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return _i29.OtpPage(key: args.key, email: args.email);
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({this.key, required this.email});

  final _i45.Key? key;

  final String email;

  @override
  String toString() {
    return 'OtpRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [_i30.ProfilePage]
class ProfileRoute extends _i44.PageRouteInfo<void> {
  const ProfileRoute({List<_i44.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i30.ProfilePage();
    },
  );
}

/// generated route for
/// [_i31.ProfileUser]
class ProfileUser extends _i44.PageRouteInfo<void> {
  const ProfileUser({List<_i44.PageRouteInfo>? children})
    : super(ProfileUser.name, initialChildren: children);

  static const String name = 'ProfileUser';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i31.ProfileUser();
    },
  );
}

/// generated route for
/// [_i32.QrCodeMeetingPage]
class QrCodeMeetingRoute extends _i44.PageRouteInfo<QrCodeMeetingRouteArgs> {
  QrCodeMeetingRoute({
    _i45.Key? key,
    required String data,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         QrCodeMeetingRoute.name,
         args: QrCodeMeetingRouteArgs(key: key, data: data),
         initialChildren: children,
       );

  static const String name = 'QrCodeMeetingRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QrCodeMeetingRouteArgs>();
      return _i32.QrCodeMeetingPage(key: args.key, data: args.data);
    },
  );
}

class QrCodeMeetingRouteArgs {
  const QrCodeMeetingRouteArgs({this.key, required this.data});

  final _i45.Key? key;

  final String data;

  @override
  String toString() {
    return 'QrCodeMeetingRouteArgs{key: $key, data: $data}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QrCodeMeetingRouteArgs) return false;
    return key == other.key && data == other.data;
  }

  @override
  int get hashCode => key.hashCode ^ data.hashCode;
}

/// generated route for
/// [_i33.RegisterFacePage]
class RegisterFaceRoute extends _i44.PageRouteInfo<RegisterFaceRouteArgs> {
  RegisterFaceRoute({
    _i45.Key? key,
    bool isRegister = false,
    bool showBackButton = true,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         RegisterFaceRoute.name,
         args: RegisterFaceRouteArgs(
           key: key,
           isRegister: isRegister,
           showBackButton: showBackButton,
         ),
         initialChildren: children,
       );

  static const String name = 'RegisterFaceRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterFaceRouteArgs>(
        orElse: () => const RegisterFaceRouteArgs(),
      );
      return _i33.RegisterFacePage(
        key: args.key,
        isRegister: args.isRegister,
        showBackButton: args.showBackButton,
      );
    },
  );
}

class RegisterFaceRouteArgs {
  const RegisterFaceRouteArgs({
    this.key,
    this.isRegister = false,
    this.showBackButton = true,
  });

  final _i45.Key? key;

  final bool isRegister;

  final bool showBackButton;

  @override
  String toString() {
    return 'RegisterFaceRouteArgs{key: $key, isRegister: $isRegister, showBackButton: $showBackButton}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RegisterFaceRouteArgs) return false;
    return key == other.key &&
        isRegister == other.isRegister &&
        showBackButton == other.showBackButton;
  }

  @override
  int get hashCode =>
      key.hashCode ^ isRegister.hashCode ^ showBackButton.hashCode;
}

/// generated route for
/// [_i34.ReminderAbsensiPage]
class ReminderAbsensiRoute extends _i44.PageRouteInfo<void> {
  const ReminderAbsensiRoute({List<_i44.PageRouteInfo>? children})
    : super(ReminderAbsensiRoute.name, initialChildren: children);

  static const String name = 'ReminderAbsensiRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i34.ReminderAbsensiPage();
    },
  );
}

/// generated route for
/// [_i35.ReportActivityScreen]
class ReportActivityRoute extends _i44.PageRouteInfo<void> {
  const ReportActivityRoute({List<_i44.PageRouteInfo>? children})
    : super(ReportActivityRoute.name, initialChildren: children);

  static const String name = 'ReportActivityRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i35.ReportActivityScreen();
    },
  );
}

/// generated route for
/// [_i36.ReservationListPage]
class ReservationListRoute extends _i44.PageRouteInfo<void> {
  const ReservationListRoute({List<_i44.PageRouteInfo>? children})
    : super(ReservationListRoute.name, initialChildren: children);

  static const String name = 'ReservationListRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i36.ReservationListPage();
    },
  );
}

/// generated route for
/// [_i37.SettingPage]
class SettingRoute extends _i44.PageRouteInfo<void> {
  const SettingRoute({List<_i44.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i37.SettingPage();
    },
  );
}

/// generated route for
/// [_i38.SignInPage]
class SignInRoute extends _i44.PageRouteInfo<void> {
  const SignInRoute({List<_i44.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i38.SignInPage();
    },
  );
}

/// generated route for
/// [_i39.SignUpPageNew]
class SignUpRouteNew extends _i44.PageRouteInfo<void> {
  const SignUpRouteNew({List<_i44.PageRouteInfo>? children})
    : super(SignUpRouteNew.name, initialChildren: children);

  static const String name = 'SignUpRouteNew';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i39.SignUpPageNew();
    },
  );
}

/// generated route for
/// [_i40.SignUpPageOri]
class SignUpRouteOri extends _i44.PageRouteInfo<void> {
  const SignUpRouteOri({List<_i44.PageRouteInfo>? children})
    : super(SignUpRouteOri.name, initialChildren: children);

  static const String name = 'SignUpRouteOri';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i40.SignUpPageOri();
    },
  );
}

/// generated route for
/// [_i41.SplashPage]
class SplashRoute extends _i44.PageRouteInfo<void> {
  const SplashRoute({List<_i44.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i41.SplashPage();
    },
  );
}

/// generated route for
/// [_i42.TaskPage]
class TaskRoute extends _i44.PageRouteInfo<TaskRouteArgs> {
  TaskRoute({
    _i45.Key? key,
    required String projectId,
    required String boardId,
    required String boardTitle,
    required String taskId,
    String? taskTitle,
    String? taskDescription,
    String? taskDue,
    List<_i50.ProfileUserModel>? dataMember,
    List<_i44.PageRouteInfo>? children,
  }) : super(
         TaskRoute.name,
         args: TaskRouteArgs(
           key: key,
           projectId: projectId,
           boardId: boardId,
           boardTitle: boardTitle,
           taskId: taskId,
           taskTitle: taskTitle,
           taskDescription: taskDescription,
           taskDue: taskDue,
           dataMember: dataMember,
         ),
         initialChildren: children,
       );

  static const String name = 'TaskRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskRouteArgs>();
      return _i42.TaskPage(
        key: args.key,
        projectId: args.projectId,
        boardId: args.boardId,
        boardTitle: args.boardTitle,
        taskId: args.taskId,
        taskTitle: args.taskTitle,
        taskDescription: args.taskDescription,
        taskDue: args.taskDue,
        dataMember: args.dataMember,
      );
    },
  );
}

class TaskRouteArgs {
  const TaskRouteArgs({
    this.key,
    required this.projectId,
    required this.boardId,
    required this.boardTitle,
    required this.taskId,
    this.taskTitle,
    this.taskDescription,
    this.taskDue,
    this.dataMember,
  });

  final _i45.Key? key;

  final String projectId;

  final String boardId;

  final String boardTitle;

  final String taskId;

  final String? taskTitle;

  final String? taskDescription;

  final String? taskDue;

  final List<_i50.ProfileUserModel>? dataMember;

  @override
  String toString() {
    return 'TaskRouteArgs{key: $key, projectId: $projectId, boardId: $boardId, boardTitle: $boardTitle, taskId: $taskId, taskTitle: $taskTitle, taskDescription: $taskDescription, taskDue: $taskDue, dataMember: $dataMember}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskRouteArgs) return false;
    return key == other.key &&
        projectId == other.projectId &&
        boardId == other.boardId &&
        boardTitle == other.boardTitle &&
        taskId == other.taskId &&
        taskTitle == other.taskTitle &&
        taskDescription == other.taskDescription &&
        taskDue == other.taskDue &&
        const _i49.ListEquality<_i50.ProfileUserModel>().equals(
          dataMember,
          other.dataMember,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      projectId.hashCode ^
      boardId.hashCode ^
      boardTitle.hashCode ^
      taskId.hashCode ^
      taskTitle.hashCode ^
      taskDescription.hashCode ^
      taskDue.hashCode ^
      const _i49.ListEquality<_i50.ProfileUserModel>().hash(dataMember);
}

/// generated route for
/// [_i43.TodoPage]
class TodoRoute extends _i44.PageRouteInfo<void> {
  const TodoRoute({List<_i44.PageRouteInfo>? children})
    : super(TodoRoute.name, initialChildren: children);

  static const String name = 'TodoRoute';

  static _i44.PageInfo page = _i44.PageInfo(
    name,
    builder: (data) {
      return const _i43.TodoPage();
    },
  );
}
