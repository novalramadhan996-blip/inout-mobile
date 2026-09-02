import 'dart:convert';
import 'dart:developer';

import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_icons_center.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/feature/auth/provider/auth_provider.dart';
import 'package:mobile_in_out/feature/home_v2/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/todo/model/response_project.dart';
import 'package:mobile_in_out/feature/todo/provider/todo_provider.dart';
import 'package:mobile_in_out/feature/todo/widget/todo_item_widget.dart';

@RoutePage()
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final ScrollController _scrollController = ScrollController();
  late final TodoProvider _todoProvider;
  late final ShardPrefService _prefService;
  final List<ResponseProject> _listData = [];
  EmployeeDetailModel? _employeeDetail;

  int _page = 1;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    _todoProvider = sl<TodoProvider>();
    _prefService = sl<ShardPrefService>();
    getEmployeeDetail();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void getEmployeeDetail() async {
    final value = await _prefService.getString(PrefServiceKey.employeeDetail);

    final result = EmployeeDetailModel.fromJson(
      value != null ? jsonDecode(value) as Map<String, dynamic> : {},
    );

    setState(() {
      _employeeDetail = result;
    });

    _fetchData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchData();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _listData.clear();
      _page = 1;
      _hasMore = true;
    });
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    await _todoProvider.getProjectList(
      ListDataRequest(
        page: _page,
        limit: _limit,
        search: "",
        sortBy: "created_at",
        orderBy: "asc",
        filter: {
          "organization_id":
              _employeeDetail?.organization?.organizationId ?? "",
        },
      ),
    );

    final List<ResponseProject> newItems = _todoProvider.projectListData;
    LogHelper.logDebug('Debug => ProjectList : _fetchData newItems $newItems');
    if (newItems.isNotEmpty) {
      setState(() {
        _listData.addAll(newItems);
        _isLoading = false;
        _page++;
        if (newItems.length < _limit) {
          _hasMore = false;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarIconCenter(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Text(
              AppTranslations.translate('todo'),
              style: TextStyle(
                fontSize: 18,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _listData.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _listData.length) {
                    final item = _listData[index];
                    return Column(
                      children: [
                        TodoItemWidget(
                          todoId: item.projectId,
                          todoTitle: item.projectName,
                          todoDescription: item.descr,
                          todoTotalTask: 0,
                          todoImageUrl: item.thumbnailUrl,
                          totalBoard: item.totalBoard,
                        ),
                        const Divider(
                          color: AppColors.greyDivider,
                          height: 0,
                          thickness: 0.5,
                        ),
                      ],
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
