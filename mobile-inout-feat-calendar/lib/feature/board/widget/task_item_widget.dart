import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/member_list_model.dart';
import 'package:mobile_in_out/feature/board/model/profile_user_model.dart';
import 'package:mobile_in_out/feature/board/provider/board_provider.dart';
import 'package:mobile_in_out/feature/board/widget/img_profile_item_widget.dart';
import 'package:mobile_in_out/feature/task/model/response_task_item.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';

class TaskItemWidget extends StatefulWidget {
  final String projectId;
  final String boardId;
  final String boardTitle;
  final String? projectTaskId;
  final String? projectTaskTitle;
  final String? projectTaskDescription;
  final String? projectTaskDue;
  final String? projectStartDate;
  final String? projectTaskStatus;
  final int totalItem;
  final int totalChecked;
  final int totalUnChecked;

  const TaskItemWidget({
    super.key,
    required this.projectId,
    required this.boardId,
    required this.boardTitle,
    this.projectTaskId,
    this.projectTaskTitle,
    this.projectTaskDescription,
    this.projectTaskDue,
    this.projectStartDate,
    this.projectTaskStatus,
    required this.totalItem,
    required this.totalChecked,
    required this.totalUnChecked
  });

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget> {

  late final BoardProvider _boardProvider;
  late final TaskProvider _taskProvider;
  
  List<ProfileUserModel> _dataProfile = [];

  final int _page = 1;
  final int _limit = 100;
  int _totalChecked = 0;
  int _totalItem = 0;
  double _percentageRaw = 0;
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
      _totalChecked = widget.totalChecked;
      _totalItem = widget.totalItem;
    });

    _fetchMember();
  }

  @override
  Widget build(BuildContext context) {

    int maxVisibleProfile = 4;
    DateTime dateTime = widget.projectTaskDue != null && widget.projectTaskDue != '' ? DateTime.parse(widget.projectTaskDue ?? '') : DateTime.now();
    String dateFormat = dateTime.toFormattedDateSecondary();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (widget.totalItem != 0) {
            context.router.push(
              TaskRoute(
                projectId: widget.projectId,
                boardId: widget.boardId,
                boardTitle: widget.boardTitle,
                taskId: widget.projectTaskId ?? '',
                taskTitle: widget.projectTaskTitle,
                taskDescription: widget.projectTaskDescription,
                taskDue: widget.projectTaskDue,
                dataMember: _dataProfile,
              ),
            ) .then((_) {
              _fetchDetailTasks();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTranslations.translate('there_is_no_task')),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.greyCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.projectTaskTitle ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _percentageRaw),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: AppColors.blackAlpha31Colors,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenColors),
                      ),
                    )
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "$_percentage%", 
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyFont
                    )
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            widget.projectTaskDue != null && widget.projectTaskDue != '' ?
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time, 
                                    size: 16, 
                                    color: AppColors.blackColor
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    dateFormat,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blackColor
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ],
                              )
                              : SizedBox.shrink(), 
                            Icon(
                              Icons.check_box_outlined , 
                              size: 16, 
                              color: AppColors.blackColor
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                                '$_totalChecked/$_totalItem',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.blackColor
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                              ), 
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
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
                        color: AppColors.blackColor
                      ),
                    ) : SizedBox.shrink()
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _fetchMember() async {

    await _boardProvider.getMemberList(
      widget.projectId,
      widget.boardId,
      widget.projectTaskId ?? '',
      _page.toString(),
      _limit.toString(),
      'created_at',
      'asc'
    );

    final List<ProjectTaskMemberModel> newItems = _boardProvider.memberListData;
    List<ProfileUserModel> dataProfile = [];
    for (var member in newItems) {
      ProfileUserModel profileUserModel = ProfileUserModel(
        imgUrl: member.member?.profileUrl,
        userName: member.member?.employeeName
      );
      dataProfile.add(profileUserModel);
    }

    if (!mounted) return;
    setState(() {
      _dataProfile = dataProfile;
    });

    await Future.delayed(Duration(seconds: 1));

  }

  Future<void> _fetchDetailTasks() async {

    await Future.delayed(Duration(milliseconds: 200));
  
    await _taskProvider.getDetailTask(
      widget.projectId,
      widget.boardId,
      widget.projectTaskId ?? '',
      widget.projectTaskId ?? ''
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
    
    if (!mounted) return;
    setState(() {
      _percentageRaw = percentageRaw;
      _percentage = percentageText;
      _totalChecked = totalChecked;
      _totalItem = totalItem;
    });
   
  }
}