import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/base_response.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/feature/board/model/profile_user_model.dart';
import 'package:mobile_in_out/feature/board/widget/img_profile_item_widget.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';

class TaskItemCheckedWidget extends StatefulWidget {
  final String projectId;
  final String projectBoardId;
  final String projectTaskId;
  final String projectTaskItemId;
  final String? title;
  final String? description;
  final String? status;
  final bool? checked;
  final List<ProfileUserModel>? dataMember;
  final Function(bool success)? onUpdateDone;

  const TaskItemCheckedWidget({
    super.key,
    required this.projectId,
    required this.projectBoardId,
    required this.projectTaskId,
    required this.projectTaskItemId,
    required this.title,
    required this.description,
    required this.status,
    required this.checked,
    this.dataMember,
    this.onUpdateDone,
  });

  @override
  State<TaskItemCheckedWidget> createState() => _TaskItemCheckedWidgetState();
}

class _TaskItemCheckedWidgetState extends State<TaskItemCheckedWidget> {
  late final TaskProvider _taskProvider;

  bool _isChecked = false;

  List<ProfileUserModel> _dataProfile = [];
  int maxVisibleProfile = 4;

  @override
  void initState() {
    _taskProvider = sl<TaskProvider>();
    setState(() {
      _isChecked = widget.checked ?? false;
      _dataProfile = widget.dataMember ?? [];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _isChecked,
            onChanged: (bool? newValue) {
              LogHelper.logDebug('checked $newValue');
              setState(() {
                _isChecked = newValue ?? false;
              });
              _updateTasksItemList(newValue ?? false);
            },
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              ImgProfileItemWidget(
                profileUser: _dataProfile,
                maxVisible: maxVisibleProfile,
              ),
              SizedBox(width: 3),
              _dataProfile.length > maxVisibleProfile
                  ? Text(
                      '+${_dataProfile.length - maxVisibleProfile}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackColor,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateTasksItemList(bool checked) async {
    await _taskProvider.updateTaskItemList(
      widget.projectId,
      widget.projectBoardId,
      widget.projectTaskId,
      widget.projectTaskItemId,
      checked,
    );

    BaseResponse response = _taskProvider.responseMessage;
    if (response.status == false) {
      widget.onUpdateDone?.call(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.translate('update_checklist_failed')),
        ),
      );
    } else {
      widget.onUpdateDone?.call(true);
    }
  }
}
