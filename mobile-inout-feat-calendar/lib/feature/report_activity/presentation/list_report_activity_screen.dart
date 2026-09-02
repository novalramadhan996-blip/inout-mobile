import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/base_state/base_state.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/activity_model.dart';
import 'package:mobile_in_out/feature/report_activity/data/model/list_activity_request_model.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/provider/report_activity_state_provider.dart';
import 'package:mobile_in_out/feature/report_activity/presentation/widget/item_report_activity.dart';

@RoutePage()
class ListReportActivityScreen extends ConsumerStatefulWidget {
  const ListReportActivityScreen({super.key});

  @override
  ConsumerState<ListReportActivityScreen> createState() =>
      _ListReportActivityScreenState();
}

class _ListReportActivityScreenState
    extends ConsumerState<ListReportActivityScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ActivityModel> _listData = [];

  int _page = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  BaseState<List<ActivityModel>> state = const BaseState();

  @override
  void initState() {
    _fetchData(ref);
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchData(ref);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _listData.clear();
      _page = 0;
      _hasMore = true;
    });

    await _fetchData(ref);
  }

  Future<void> _fetchData(WidgetRef ref) async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    ListActivityRequestModel listActivityRequestModel =
        ListActivityRequestModel(
          sort: "activity_type",
          order: "asc",
          offset: _page,
          limit: _limit,
        );

    await ref
        .read(listReportActivityNotifierProvider.notifier)
        .getListActivity(listActivityRequestModel);

    setState(() {
      state = ref.read(listReportActivityNotifierProvider);
    });

    final List<ActivityModel> newItems = state.data ?? [];

    if (newItems.isNotEmpty) {
      setState(() {
        _listData.addAll(newItems);
        _isLoading = false;
        _page = _page + _limit;
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
      appBar: AppBar(
        title: Text(AppTranslations.translate('report_activity')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.router.push<bool>(
                const ReportActivityRoute(),
              );

              if (result == true) {
                _onRefresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                        ItemReportActivity(
                          id: item.activityId,
                          image: item.photoUrl,
                          title: item.activityType,
                          desc: item.descr,
                          date: item.created,
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
