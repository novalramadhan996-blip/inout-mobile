import 'dart:math';
import 'dart:developer' as log;

import 'package:flutter/material.dart';
import 'package:expansion_tile_list/expansion_tile_list.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/base_response.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/member_list_model.dart';
import 'package:mobile_in_out/feature/board/model/profile_user_model.dart';
import 'package:mobile_in_out/feature/board/provider/board_provider.dart';
import 'package:mobile_in_out/feature/task/model/response_task_item.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:mobile_in_out/feature/task/widget/task_item_checked_widget.dart';

class ChecklistItemWidget extends StatefulWidget {
  final String? title;
  final String? projectId;
  final String? boardId;
  final String? taskId;
  final String? parentTaskId;
  final bool? checked;
  final int totalItem;
  final int totalChecked;
  final int totalUnChecked;
  final Function(bool success)? onUpdateDone;

  const ChecklistItemWidget({
    super.key,
    this.title,
    this.projectId,
    this.boardId,
    this.taskId,
    this.parentTaskId,
    required this.checked,
    required this.totalItem,
    required this.totalChecked,
    required this.totalUnChecked,
    this.onUpdateDone,
  });

  @override
  State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<ChecklistItemWidget> {
  late final TaskProvider _taskProvider;
  late final BoardProvider _boardProvider;

  final List<ResponseTaskItem> _tasksItemList = [];
  List<ProfileUserModel> _dataProfile = [];

  double _percentageRaw = 0;
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _isChecked = false;
  // workaround all checked or unchecked when load more
  // bool _isLoadingMore = false;
  // bool _hasMoreData = true;
  int _page = 1;
  String _percentage = '';

  @override
  void initState() {
    _boardProvider = sl<BoardProvider>();
    _taskProvider = sl<TaskProvider>();

    super.initState();

    double percentageRaw = 0;
    if (widget.totalItem != 0) {
      percentageRaw = (widget.totalChecked / widget.totalItem);
    }
    int percentage = 0;
    if (percentageRaw != 0) {
      percentage = (percentageRaw * 100).round();
    }
    String percentageText = percentage.toString();
    setState(() {
      _percentageRaw = percentageRaw;
      _percentage = percentageText;
      _isChecked = widget.checked ?? false;
    });

    _fetchMember();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTileList(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        trailing: Icon(Icons.arrow_drop_down),
        trailingAnimation: ExpansionTileAnimation(
          animate: Tween<double>(begin: 0, end: 0.5),
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          builder: (context, index, value, child) {
            return Transform.rotate(angle: value * pi, child: child);
          },
        ),
        children: <ExpansionTile>[
          ExpansionTile(
            title: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: Checkbox(
                      value: _isChecked,
                      onChanged: (bool? newValue) {
                        LogHelper.logDebug('checked $newValue');
                        setState(() {
                          _isChecked = newValue ?? false;
                        });
                        _updateTasksItemList(newValue ?? false);
                      },
                      activeColor: Colors.transparent,
                      checkColor: Colors.black,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
              ],
            ),
            onExpansionChanged: _onExpansionChanged,
            children: _isLoading
                ? [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ]
                : [
                    _tasksItemList.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: 0,
                                      end: _percentageRaw,
                                    ),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    builder: (context, value, _) =>
                                        LinearProgressIndicator(
                                          value: value,
                                          minHeight: 6,
                                          backgroundColor:
                                              AppColors.blackAlpha31Colors,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.greenColors,
                                              ),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  _percentage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.greyFont,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    const SizedBox(height: 8),
                    ..._tasksItemList.map((task) {
                      return TaskItemCheckedWidget(
                        projectId: widget.projectId ?? '',
                        projectBoardId: widget.boardId ?? '',
                        projectTaskId: widget.taskId ?? '',
                        projectTaskItemId: task.projectTaskItemId ?? '',
                        title: task.title ?? '',
                        description: task.description ?? '',
                        status: task.status ?? '',
                        checked: task.checked ?? false,
                        dataMember: _dataProfile,
                        onUpdateDone: (success) {
                          LogHelper.logDebug('update task id child $success');
                          _fetchTasksItemList();
                          _fetchDetailTasks();
                        },
                      );
                    }),
                    // workaround all checked or unchecked when load more
                    // if (_hasMoreData)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //     child: Center(
                    //       child: _isLoadingMore
                    //           ? const CircularProgressIndicator()
                    //           : TextButton.icon(
                    //               onPressed: _onLoadMore,
                    //               icon: const Icon(Icons.expand_more),
                    //               label: const Text("Load More"),
                    //             ),
                    //     ),
                    //   ),
                  ],
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTasksItemList({bool isLoadMore = false}) async {
    if (_isLoading) return;

    // workaround all checked or unchecked when load more
    // if (isLoadMore) {
    //   setState(() => _isLoadingMore = true);
    // } else {
    //   setState(() {
    //     _isLoading = true;
    //     _tasksItemList.clear();
    //     _page = 1;
    //     _hasMoreData = true;
    //   });
    // }

    setState(() {
      _isLoading = true;
      _tasksItemList.clear();
      _page = 1;
    });

    await _taskProvider.getTaskItemList(
      widget.projectId ?? '',
      widget.boardId ?? '',
      widget.taskId ?? '',
      _page.toString(),
      // workaround all checked or unchecked when load more
      // AppConst.LIMIT_LIST.toString(),
      widget.totalItem.toString(),
      'created',
      'asc',
    );

    await Future.delayed(const Duration(milliseconds: 500));

    final List<ResponseTaskItem> taskItem = _taskProvider.taskListData;

    if (taskItem.isEmpty) {
      setState(() {
        _isLoading = false;
        // workaround all checked or unchecked when load more
        // _isLoadingMore = false;
        // _hasMoreData = false;
      });
    } else {
      bool isAllChecked = true;
      for (var item in taskItem) {
        if (item.checked == false) {
          isAllChecked = false;
        }
      }
      if (isAllChecked != _isChecked) {
        await _taskProvider.updateTaskItemList(
          widget.projectId ?? '',
          widget.boardId ?? '',
          widget.parentTaskId ?? '',
          widget.taskId ?? '',
          isAllChecked,
        );
        _fetchDetailTasks();
        widget.onUpdateDone?.call(true);
      }
      setState(() {
        _tasksItemList.addAll(taskItem);
        _isLoading = false;
        // workaround all checked or unchecked when load more
        // _page++;
        // _isLoadingMore = false;
        // if (taskItem.length < AppConst.LIMIT_LIST) {
        //   _hasMoreData = false;
        // }
      });
    }
  }

  void _onLoadMore() {
    _fetchTasksItemList(isLoadMore: true);
  }

  Future<void> _fetchDetailTasks() async {
    await Future.delayed(Duration(milliseconds: 200));

    await _taskProvider.getDetailTask(
      widget.projectId ?? '',
      widget.boardId ?? '',
      widget.parentTaskId ?? '',
      widget.taskId ?? '',
    );

    final ResponseTaskItem detailTask = _taskProvider.detailTask;
    int totalChecked = detailTask.totalChecked ?? 0;
    int totalItem = detailTask.totalItem ?? 0;
    double percentageRaw = 0;
    if (totalItem != 0) {
      percentageRaw = (totalChecked / totalItem);
    }
    int percentage = 0;
    if (percentageRaw != 0) {
      percentage = (percentageRaw * 100).round();
    }
    String percentageText = percentage.toString();

    Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _percentageRaw = percentageRaw;
      _percentage = percentageText;
      _isChecked = detailTask.checked ?? false;
    });
  }

  void _onExpansionChanged(bool expanded) {
    if (expanded && !_isExpanded) {
      _isExpanded = true;
      _fetchTasksItemList();
    } else {
      _isExpanded = false;
    }
  }

  Future<void> _fetchMember() async {
    await _boardProvider.getMemberList(
      widget.projectId ?? '',
      widget.boardId ?? '',
      widget.taskId ?? '',
      _page.toString(),
      AppConst.LIMIT_LIST_MEMBER.toString(),
      'created',
      'asc',
    );

    final List<ProjectTaskMemberModel> newItems = _boardProvider.memberListData;
    List<ProfileUserModel> dataProfile = [];
    for (var member in newItems) {
      ProfileUserModel profileUserModel = ProfileUserModel(
        imgUrl: member.member?.profileUrl,
        userName: member.member?.employeeName,
      );
      dataProfile.add(profileUserModel);
    }

    if (!mounted) return;
    setState(() {
      _dataProfile = dataProfile;
    });
  }

  Future<void> _updateTasksItemList(bool checked) async {
    await _taskProvider.updateTaskItemList(
      widget.projectId ?? '',
      widget.boardId ?? '',
      widget.parentTaskId ?? '',
      widget.taskId ?? '',
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
      for (var item in _tasksItemList) {
        LogHelper.logDebug('item checklist ${item.projectTaskItemId}');
        await _taskProvider.updateTaskItemList(
          widget.projectId ?? '',
          widget.boardId ?? '',
          widget.taskId ?? '',
          item.projectTaskItemId ?? '',
          checked,
        );
      }
      _fetchDetailTasks();
      _fetchTasksItemList();
    }
  }
}
