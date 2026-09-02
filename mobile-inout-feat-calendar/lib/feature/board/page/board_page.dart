import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/feature/board/model/response_project.dart';
import 'package:mobile_in_out/feature/board/provider/board_provider.dart';
import 'package:mobile_in_out/feature/board/widget/board_item_widget.dart';

@RoutePage()
class BoardPage extends StatefulWidget {
  final String projectId;
  final String title;
  final String imgUrl;

  const BoardPage({
    super.key,
    required this.projectId,
    required this.title,
    required this.imgUrl
  });

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ScrollController _scrollController = ScrollController();
  late final BoardProvider _boardProvider;
  final List<ResponseBoard> _listData = [];

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _boardProvider = sl<BoardProvider>();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
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

    await _boardProvider.getProjectBoardList(
      widget.projectId,
      _page.toString(),
      AppConst.LIMIT_LIST_BOARD.toString(),
      'created_at',
      'asc'
    );

    final List<ResponseBoard> newItems = _boardProvider.projectListData;

    await Future.delayed(const Duration(milliseconds: 500));

    if (newItems.isNotEmpty) {
      setState(() {
        _listData.addAll(newItems);
        _isLoading = false;
        _page++;
        if (newItems.length < AppConst.LIMIT_LIST_BOARD) {
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
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: widget.title,
      ),
      body: Column(
        children: [
          Image.network(
            widget.imgUrl,
            width: double.infinity,
            height: 165,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image, 
                size: 165, 
                color: Colors.grey,
              );
            },
          ),
          Expanded(
            child:  RefreshIndicator(
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
                        BoardItemWidget(
                          projectId: widget.projectId,
                          boardId: item.projectBoardId,
                          boardTitle: item.projectBoardTitle,
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
        ]
      ),
    );
  }
}