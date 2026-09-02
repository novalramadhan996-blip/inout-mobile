import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/constants/app_font.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_employee_model.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/core/utils/widgets/app_form_profile.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input_date.dart';
import 'package:mobile_in_out/core/utils/models/dropdown_item.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input_dropdown.dart';
import 'package:mobile_in_out/core/utils/widgets/app_search_dropdown.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input_time.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/feature/calendar/data/model/location_model.dart';
import 'package:mobile_in_out/feature/calendar/data/model/request/request_events.dart';
import 'package:mobile_in_out/feature/calendar/data/model/response/response_events.dart';
import 'package:mobile_in_out/feature/calendar/presentation/provider/calendar_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class CreateEventPage extends ConsumerStatefulWidget {
  final TypeEvent typeEvent;
  final String? eventId;
  final String? eventName;
  final String? eventDateStart;
  final String? eventDateEnd;
  final String? locationId;
  const CreateEventPage({
    super.key,
    required this.typeEvent,
    this.eventId,
    this.eventName,
    this.eventDateStart,
    this.eventDateEnd,
    this.locationId,
  });

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _startTimeCtrl = TextEditingController();
  final TextEditingController _endTimeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _invitesCtrl = TextEditingController();
  final ShardPrefService _prefService = sl<ShardPrefService>();
  List<String> _selectedUserIds = [];
  bool _isFormValid = false;
  bool _isDelete = false;
  Timer? _searchDebounce;
  String _selectLocation = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _eventNameCtrl.addListener(_checkFormValidity);
    _startDateCtrl.addListener(_checkFormValidity);
    _endDateCtrl.addListener(_checkFormValidity);
    _startTimeCtrl.addListener(_checkFormValidity);
    _endTimeCtrl.addListener(_checkFormValidity);
    _locationCtrl.addListener(_checkFormValidity);
    _invitesCtrl.addListener(_checkFormValidity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation('');
      _getEmployeeList('');
      _prefillFormData();
    });
  }

  void _prefillFormData() {
    if (widget.typeEvent == TypeEvent.editEvent) {
      _eventNameCtrl.text = widget.eventName ?? '';
      _selectLocation = widget.locationId ?? '';
      _locationCtrl.text = widget.locationId ?? '';
      if (widget.eventDateStart != null &&
          widget.eventDateStart!.contains('T')) {
        final parts = widget.eventDateStart!.split('T');
        _startDateCtrl.text = parts[0];
        _startTimeCtrl.text = _extractTime(parts.length > 1 ? parts[1] : '');
      }
      if (widget.eventDateEnd != null && widget.eventDateEnd!.contains('T')) {
        final parts = widget.eventDateEnd!.split('T');
        _endDateCtrl.text = parts[0];
        _endTimeCtrl.text = _extractTime(parts.length > 1 ? parts[1] : '');
      }
      _checkFormValidity();
    }
  }

  String _extractTime(String timePart) {
    if (timePart.isEmpty) return '';
    final match = RegExp(r'^(\d{2}:\d{2})').firstMatch(timePart);
    return match != null ? match.group(1)! : '';
  }

  void _getLocation(String? search) async {
    String? appsId = await _prefService.getString(PrefServiceKey.appsId);
    ref
        .read(locationEventsNotifierProvider.notifier)
        .getDataLocation(
          ListDataRequest(
            search: search,
            sortBy: 'location_name',
            orderBy: 'asc',
            offset: 0,
            limit: 12,
            filter: {"apps_id": appsId},
          ),
        );
  }

  void _getEmployeeList(String? search) async {
    String? appsId = await _prefService.getString(PrefServiceKey.appsId);
    ref
        .read(employeeListEventsNotifierProvider.notifier)
        .getEmployeeList(
          ListDataRequest(
            search: search,
            sortBy: 'employee_name',
            orderBy: 'asc',
            offset: 0,
            limit: 12,
            filter: {"apps_id": appsId},
          ),
        );
  }

  void _checkFormValidity() {
    final valid =
        _eventNameCtrl.text.isNotEmpty &&
        _startDateCtrl.text.isNotEmpty &&
        _endDateCtrl.text.isNotEmpty &&
        _startTimeCtrl.text.isNotEmpty &&
        _endTimeCtrl.text.isNotEmpty &&
        _locationCtrl.text.isNotEmpty &&
        _selectedUserIds.isNotEmpty;
    if (_isFormValid != valid) {
      setState(() => _isFormValid = valid);
    }
  }

  List<DropdownItem> _toDropdownItems(List<OrganizationEmployee> employees) {
    return employees
        .map(
          (e) => DropdownItem(
            label: e.employeeName ?? '',
            value: e.employeeId ?? '',
            item: e,
          ),
        )
        .toList();
  }

  Widget _showDataSelectUser(List<OrganizationEmployee> employees) {
    final selectedLabels = employees
        .where((e) => _selectedUserIds.contains(e.employeeId))
        .map((e) => e.employeeName ?? '')
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectedLabels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 7,
      ),
      itemBuilder: (_, index) {
        return Row(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.grey),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                selectedLabels[index],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFont.fontMontserrat,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final startDate = DateHelper.toIso8601(
      _startDateCtrl.text,
      _startTimeCtrl.text,
    );
    final endDate = DateHelper.toIso8601(_endDateCtrl.text, _endTimeCtrl.text);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (startDate != null) {
      final parsedStart = DateTime.parse(startDate);
      final startDay = DateTime(
        parsedStart.year,
        parsedStart.month,
        parsedStart.day,
      );
      if (startDay.isBefore(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppTranslations.translate('event_start_before_today_error'),
            ),
          ),
        );
        return;
      }
    }

    if (startDate != null &&
        endDate != null &&
        DateTime.parse(endDate).isBefore(DateTime.parse(startDate))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.translate('event_end_before_start_error'),
          ),
        ),
      );
      return;
    }

    final request = RequestEvents(
      eventName: _eventNameCtrl.text,
      eventDateStart: startDate,
      eventDateEnd: endDate,
      locationId: _selectLocation,
      status: 'pending',
      employeeIds: _selectedUserIds,
    );

    if (widget.typeEvent == TypeEvent.editEvent) {
      ref
          .read(scheduleEventNotifierProvider.notifier)
          .updateEvent(request, widget.eventId!);
    } else {
      ref.read(scheduleEventNotifierProvider.notifier).insertEvent(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationEventsNotifierProvider);
    final employeeListState = ref.watch(employeeListEventsNotifierProvider);
    final scheduleEventState = ref.watch(scheduleEventNotifierProvider);

    ref.listen<BaseState<ResponseEvents>>(scheduleEventNotifierProvider, (
      previous,
      next,
    ) {
      if (next.state == ConcreteState.loading) {
        Dialogs.showLoadingDialog(context);
      } else if (next.state == ConcreteState.loaded) {
        Dialogs.dismissDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.typeEvent == TypeEvent.editEvent
                  ? _isDelete == true
                        ? AppTranslations.translate('event_deleted_success')
                        : AppTranslations.translate('event_updated_success')
                  : AppTranslations.translate('event_created_success'),
            ),
          ),
        );
        if (_isDelete == true) _isDelete = false;
        context.pop(true);
      } else if (next.state == ConcreteState.failure) {
        Dialogs.dismissDialog(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
        if (_isDelete == true) _isDelete = false;
      }
    });

    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: widget.typeEvent == TypeEvent.meeting
            ? AppTranslations.translate('new_event')
            : widget.typeEvent == TypeEvent.editEvent
            ? AppTranslations.translate('edit_event')
            : AppTranslations.translate('offsite_request'),
        action: [
          if (widget.typeEvent == TypeEvent.editEvent) ...[
            AppButton(
              color: AppColors.redColors,
              buttonName: AppTranslations.translate('delete'),
              width: 100,
              onPress: () {
                Dialogs.confirmDialog(
                  context,
                  title: AppTranslations.translate('delete'),
                  message: AppTranslations.translate('are_you_sure_delete'),
                  positiveLabel: AppTranslations.translate('yes'),
                  negativeLabel: AppTranslations.translate('cancel'),
                  dialogCallback: () {
                    _isDelete = true;
                    ref
                        .read(scheduleEventNotifierProvider.notifier)
                        .deleteEvent(widget.eventId!);
                  },
                );
              },
            ),
            SizedBox(width: 10),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppFormProfile(
                  label: AppTranslations.translate('event_name'),
                  hinttext: AppTranslations.translate('event_name'),
                  onchanged: (value) {},
                  controller: _eventNameCtrl,
                  isRequired: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppInputDatePicker(
                        controller: _startDateCtrl,
                        label: AppTranslations.translate('starts'),
                        hintText: AppTranslations.translate('date'),
                        readOnly: true,
                        isRequired: true,
                        lastDate: DateTime(2999),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '${AppTranslations.translate('starts')} ${AppTranslations.translate('date')} is required!';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTimePicker(
                        controller: _startTimeCtrl,
                        label: '',
                        hintText: AppTranslations.translate('time'),
                        readOnly: true,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '${AppTranslations.translate('starts')} ${AppTranslations.translate('time')} is required!';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppInputDatePicker(
                        controller: _endDateCtrl,
                        label: AppTranslations.translate('ends'),
                        hintText: AppTranslations.translate('date'),
                        readOnly: true,
                        isRequired: true,
                        lastDate: DateTime(2999),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '${AppTranslations.translate('ends')} ${AppTranslations.translate('date')} is required!';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputTimePicker(
                        controller: _endTimeCtrl,
                        label: '',
                        hintText: AppTranslations.translate('time'),
                        readOnly: true,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '${AppTranslations.translate('ends')} ${AppTranslations.translate('time')} is required!';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                AppSearchDropdown<LocationModel>(
                  controller: _locationCtrl,
                  label: AppTranslations.translate('location'),
                  hintText: AppTranslations.translate('select_location'),
                  items: locationState.data ?? [],
                  isLoading: locationState.isLoading,
                  itemBuilder: (location) => location.locationName ?? '',
                  filterFn: (location, query) =>
                      (location.locationName ?? '').toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      (location.locationName ?? '').toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                  onSearchChanged: (search) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(seconds: 1),
                      () => _getLocation(search),
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '${AppTranslations.translate('location')} is required!';
                    }
                    return null;
                  },
                  onSelected: (location) {
                    log('selected ${location?.locationId}');
                    _selectLocation = location?.locationId ?? '';
                  },
                ),
                AppInputDropdown(
                  controller: _invitesCtrl,
                  label: AppTranslations.translate('invitees'),
                  hintText: AppTranslations.translate('add_invitees'),
                  multiple: true,
                  items: _toDropdownItems(employeeListState.data ?? []),
                  isLoading: employeeListState.isLoading,
                  selectedValues: _selectedUserIds,
                  filterFn: (item, query) =>
                      item.label.toLowerCase().contains(query.toLowerCase()),
                  onSearchChanged: (search) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(seconds: 1),
                      () => _getEmployeeList(search),
                    );
                  },
                  validator: (value) {
                    if (_selectedUserIds.isEmpty) {
                      return '${AppTranslations.translate('invitees')} is required!';
                    }
                    return null;
                  },
                  onMultipleChanged: (values) {
                    log('values dropdown $values');
                    setState(() {
                      _selectedUserIds = values;
                    });
                    _checkFormValidity();
                  },
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: _showDataSelectUser(employeeListState.data ?? []),
                ),
                SizedBox(height: 20),
                AppButton(
                  isDisabled: !_isFormValid || scheduleEventState.isLoading,
                  isLoading: scheduleEventState.isLoading,
                  buttonName: AppTranslations.translate('submit'),
                  onPress: _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum TypeEvent { meeting, offsiteRequest, editEvent }
