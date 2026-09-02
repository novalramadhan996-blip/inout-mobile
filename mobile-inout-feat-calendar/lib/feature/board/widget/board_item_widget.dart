import 'dart:math';

import 'package:flutter/material.dart';
import 'package:expansion_tile_list/expansion_tile_list.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/feature/board/model/response_task.dart';
import 'package:mobile_in_out/feature/board/provider/board_provider.dart';
import 'package:mobile_in_out/feature/board/widget/task_item_widget.dart';

class BoardItemWidget extends StatefulWidget {
  final String? projectId;
  final String? boardId;
  final String? boardTitle;

  const BoardItemWidget({
    super.key,
    this.projectId,
    this.boardId,
    this.boardTitle,
  });

  @override
  State<BoardItemWidget> createState() => _BoardItemWidgetState();
}

class _BoardItemWidgetState extends State<BoardItemWidget> {
  final List<ResponseTask> _tasksList = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isExpanded = false;
  late final BoardProvider _boardProvider;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    _boardProvider = sl<BoardProvider>();
    super.initState();
  }

  void _onExpansionChanged(bool expanded) {
    if (expanded && !_isExpanded) {
      _isExpanded = true;
      _fetchTasks();
    } else {
      _isExpanded = false;
    }
  }

  Future<void> _fetchTasks({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    await _boardProvider.getProjectTaskList(
      widget.projectId ?? '',
      widget.boardId ?? '',
      _page.toString(),
      AppConst.LIMIT_LIST.toString(),
      'created_at',
      'asc',
    );

    final List<ResponseTask> newItems = _boardProvider.taskListData;

    await Future.delayed(const Duration(milliseconds: 500));

    if (newItems.isNotEmpty) {
      setState(() {
        _tasksList.addAll(newItems);
        _isLoading = false;
        _page++;
        _isLoadingMore = false;
        if (newItems.length < AppConst.LIMIT_LIST) {
          _hasMoreData = false;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasMoreData = false;
      });
    }
  }

  void _onLoadMore() {
    _fetchTasks(isLoadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTileList(
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
          title: Text(
            widget.boardTitle ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          onExpansionChanged: _onExpansionChanged,
          children: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              ..._tasksList.map(
                (task) => TaskItemWidget(
                  projectId: widget.projectId ?? '',
                  boardId: widget.boardId ?? '',
                  boardTitle: widget.boardTitle ?? '',
                  projectTaskId: task.projectTaskId,
                  projectTaskTitle: task.projectTaskTitle,
                  projectTaskDescription: task.projectTaskDescription,
                  projectTaskDue: task.projectTaskDueDate,
                  projectStartDate: task.projectTaskStartDate,
                  projectTaskStatus: task.projectTaskStatus,
                  totalItem: task.totalItem ?? 0,
                  totalChecked: task.totalChecked ?? 0,
                  totalUnChecked: task.totalUnChecked ?? 0,
                ),
              ),

              // Tombol Load More di bawah list
              if (_hasMoreData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: _isLoadingMore
                        ? const CircularProgressIndicator()
                        : TextButton.icon(
                            onPressed: _onLoadMore,
                            icon: const Icon(Icons.expand_more),
                            label: Text(AppTranslations.translate('load_more')),
                          ),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}
