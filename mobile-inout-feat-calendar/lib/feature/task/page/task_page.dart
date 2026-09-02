import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/base_response.dart';
import 'package:mobile_in_out/core/utils/dialogs.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/core/utils/widgets/app_button.dart';
import 'package:mobile_in_out/feature/board/model/profile_user_model.dart';
import 'package:mobile_in_out/feature/board/widget/img_profile_item_widget.dart';
import 'package:mobile_in_out/feature/task/model/request_add_attachment.dart';
import 'package:mobile_in_out/feature/task/model/request_comment.dart';
import 'package:mobile_in_out/feature/task/model/response_attachment.dart';
import 'package:mobile_in_out/feature/task/model/response_comment.dart';
import 'package:mobile_in_out/feature/task/model/response_task_item.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/provider/task_provider.dart';
import 'package:mobile_in_out/feature/task/widget/attachment_item_widget.dart';
import 'package:mobile_in_out/feature/task/widget/checklist_item_widget.dart';
import 'package:mobile_in_out/feature/task/widget/comment_item_widget.dart';

@RoutePage()
class TaskPage extends StatefulWidget {
  final String projectId;
  final String boardId;
  final String boardTitle;
  final String taskId;
  final String? taskTitle;
  final String? taskDescription;
  final String? taskDue;
  final List<ProfileUserModel>? dataMember;

  const TaskPage({
    super.key,
    required this.projectId,
    required this.boardId,
    required this.boardTitle,
    required this.taskId,
    this.taskTitle,
    this.taskDescription,
    this.taskDue,
    this.dataMember,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TaskProvider _taskProvider;
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingCheckedList = false;
  bool _isLoadingMoreChecked = false;
  bool _hasMoreDataChecked = true;
  int _pageChecked = 1;
  final List<ResponseTaskItem> _tasksItemList = [];

  bool _isLoadingAttachmentList = false;
  final List<ResponseAttachment> _attachmentsList = [];

  bool _isLoadingCommentList = false;
  final List<ResponseComment> _commentsList = [];

  List<ProfileUserModel> _dataProfile = [];

  String _commentId = '';
  String _replyName = '';
  String _dueDate = '';
  String _percentage = '';
  final String _module = 'Task';
  final String _typeUploadAttachment = 'attachment';
  final String _typeUploadComment = 'comment';
  String _contentType = '';
  double _percentageRaw = 0;
  bool _isReply = false;
  bool _isTyping = false;
  int _totalChecked = 0;
  int _totalItem = 0;
  int maxVisibleProfile = 4;

  final imageExtensions = ['jpg', 'jpeg', 'png'];
  final videoExtensions = ['mp4', 'mkv', 'mov', 'avi', 'webm', 'flv', 'wmv'];
  final documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  @override
  void initState() {
    _taskProvider = sl<TaskProvider>();

    super.initState();

    DateTime dateTime = widget.taskDue != null && widget.taskDue != ''
        ? DateTime.parse(widget.taskDue ?? '')
        : DateTime.now();
    String dateFormat = dateTime.toFormattedDateSecondary();

    setState(() {
      _dueDate = dateFormat;
      _dataProfile = widget.dataMember ?? [];
    });

    _textController.addListener(() {
      setState(() {
        _isTyping = _textController.text.trim().isNotEmpty;
      });
    });

    _onRefresh();
  }

  @override
  void dispose() {
    _textController.dispose();
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
        title: widget.boardTitle,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.taskTitle ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.taskDescription ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        widget.taskDue != null && widget.taskDue != ''
                            ? Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppTranslations.translate('due_date'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.greyFont,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _dueDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslations.translate('checklist'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.greyFont,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '$_totalChecked/$_totalItem',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.translate('members'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyFont,
                              ),
                            ),
                            SizedBox(height: 5),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: _percentageRaw),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            builder: (context, value, _) =>
                                LinearProgressIndicator(
                                  value: value,
                                  minHeight: 6,
                                  backgroundColor: AppColors.blackAlpha31Colors,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.greenColors,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "$_percentage%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyFont,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: AppColors.greyCard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasksItemList.length,
                      itemBuilder: (context, index) {
                        if (index < _tasksItemList.length) {
                          final item = _tasksItemList[index];
                          return ChecklistItemWidget(
                            title: item.title,
                            projectId: widget.projectId,
                            boardId: widget.boardId,
                            taskId: item.projectTaskItemId,
                            parentTaskId: widget.taskId,
                            checked: item.checked,
                            totalItem: item.totalItem ?? 0,
                            totalChecked: item.totalChecked ?? 0,
                            totalUnChecked: item.totalUnChecked ?? 0,
                            onUpdateDone: (success) {
                              if (!success) {
                                _fetchTasksItemList();
                              } else {
                                _fetchDetailTasks();
                              }
                            },
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
                    if (_hasMoreDataChecked)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: _isLoadingMoreChecked
                              ? const CircularProgressIndicator()
                              : TextButton.icon(
                                  onPressed: _onLoadMoreChecked,
                                  icon: const Icon(Icons.expand_more),
                                  label: Text(
                                    AppTranslations.translate('load_more'),
                                  ),
                                ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 20,
                                color: AppColors.blackColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppTranslations.translate('attachments'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _isLoadingAttachmentList
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: _attachmentsList.map((attachment) {
                                    return AttachmentItemWidget(
                                      attachmentId:
                                          attachment.attachmentId ?? '',
                                      taskId: attachment.taskId ?? '',
                                      attachmentUrl: attachment.attachmentUrl,
                                      attachmentName: attachment.attachmentName,
                                      attachmentType: attachment.attachmentType,
                                      isThumbnail: attachment.isThumbnail,
                                      onDelete: (attachmentId) {
                                        Dialogs.confirmDialog(
                                          context,
                                          title: AppTranslations.translate(
                                            'delete_attachment',
                                          ),
                                          message: AppTranslations.translate(
                                            'confirm_delete_attachment',
                                          ),
                                          positiveLabel:
                                              AppTranslations.translate(
                                                'delete',
                                              ),
                                          dialogCallback: () =>
                                              _removeAttachment(attachmentId),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 10),
                          AppButton.outline(
                            buttonName: AppTranslations.translate(
                              'upload_files',
                            ),
                            backgroundColor: AppColors.greyCard,
                            onPress: () {
                              _uploadFile(_typeUploadAttachment);
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.message_outlined,
                                size: 20,
                                color: AppColors.blackColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppTranslations.translate('activity'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _isLoadingCommentList
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: _commentsList.map((comment) {
                                    return Column(
                                      children: [
                                        CommentItemWidget(
                                          commentId: comment.commentId ?? '',
                                          parentCommentId:
                                              comment.parentCommentId ?? '',
                                          module: comment.module ?? '',
                                          moduleId: comment.moduleId ?? '',
                                          content: comment.content ?? '',
                                          contentType:
                                              comment.contentType ?? '',
                                          status: comment.status ?? '',
                                          createdAt: comment.createdAt ?? '',
                                          createdBy: comment.createdBy ?? '',
                                          updatedAt: comment.updatedAt ?? '',
                                          updatedBy: comment.updatedBy ?? '',
                                          onReply: (data) {
                                            setState(() {
                                              _isReply = true;
                                              _replyName = data.createdBy ?? '';
                                              _commentId = data.commentId ?? '';
                                            });

                                            _autoScrollToBottom();

                                            // not use since tag reply using chip
                                            // if (!_textController.text.startsWith('||')) {
                                            //   _textController.text = '||Reply to $_replyName||';

                                            //   WidgetsBinding.instance.addPostFrameCallback((_) {
                                            //     FocusScope.of(context).requestFocus(_focusNode);

                                            //     _textController.value = _textController.value.copyWith(
                                            //       selection: TextSelection.collapsed(offset: _textController.text.length),
                                            //     );

                                            //     _scrollController.animateTo(
                                            //       _scrollController.position.maxScrollExtent,
                                            //       duration: const Duration(milliseconds: 300),
                                            //       curve: Curves.easeOut,
                                            //     );
                                            //   });
                                            // }
                                          },
                                        ),
                                        const Divider(
                                          color: AppColors.greyDivider,
                                          height: 0,
                                          thickness: 0.5,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                          SizedBox(height: 20),
                          _isReply
                              ? Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: AppColors.greyComponent,
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                AppTranslations.translate(
                                                  'reply_to',
                                                ),
                                                style: TextStyle(
                                                  color: AppColors.whiteColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                _replyName,
                                                style: TextStyle(
                                                  color: AppColors.whiteColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: -4,
                                          right: -4,
                                          child: GestureDetector(
                                            onTap: () {
                                              _clearReply();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.redColors,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: EdgeInsets.all(2),
                                              child: Icon(
                                                Icons.close,
                                                size: 12,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                )
                              : SizedBox(),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _selectUploadAttachment();
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: TextField(
                                  // not use since tag reply using chip
                                  // ExtendedTextField(
                                  // specialTextSpanBuilder: ReplySpecialTextSpanBuilder(),
                                  focusNode: _focusNode,
                                  controller: _textController,
                                  decoration: InputDecoration(
                                    hintText: AppTranslations.translate(
                                      'start_typing',
                                    ),
                                    hintStyle: const TextStyle(
                                      color: AppColors.greyFont,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.whiteColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, animation) {
                                  final offsetAnimation = Tween<Offset>(
                                    begin: const Offset(0.5, 0),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _isTyping
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              String comment =
                                                  _textController.text;
                                              if (comment.isNotEmpty) {
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                                setState(() {
                                                  _contentType = 'text';
                                                });
                                                _addComment(comment);
                                              }
                                            },
                                            backgroundColor:
                                                AppColors.primaryColor,
                                            elevation: 0,
                                            shape: const StadiumBorder(),
                                            child: const Icon(
                                              Icons.arrow_upward,
                                              color: AppColors.whiteColor,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchTasksItemList({bool isLoadMore = false}) async {
    if (_isLoadingCheckedList) return;

    if (isLoadMore) {
      setState(() => _isLoadingMoreChecked = true);
    } else {
      setState(() {
        _isLoadingCheckedList = true;
        _tasksItemList.clear();
        _pageChecked = 1;
        _hasMoreDataChecked = true;
      });
    }

    await _taskProvider.getTaskItemList(
      widget.projectId,
      widget.boardId,
      widget.taskId,
      _pageChecked.toString(),
      AppConst.LIMIT_LIST.toString(),
      'created',
      'asc',
    );

    final List<ResponseTaskItem> newItems = _taskProvider.taskListData;

    await Future.delayed(const Duration(milliseconds: 500));

    if (newItems.isEmpty) {
      setState(() {
        _isLoadingCheckedList = false;
        _isLoadingMoreChecked = false;
        _hasMoreDataChecked = false;
      });
    } else {
      setState(() {
        _tasksItemList.addAll(newItems);
        _isLoadingCheckedList = false;
        _pageChecked++;
        _isLoadingMoreChecked = false;
        if (newItems.length < AppConst.LIMIT_LIST) {
          _hasMoreDataChecked = false;
        }
      });
    }
  }

  void _onLoadMoreChecked() {
    _fetchTasksItemList(isLoadMore: true);
  }

  Future<void> _fetchAttachmentItemList() async {
    if (_isLoadingAttachmentList) return;

    setState(() {
      _isLoadingAttachmentList = true;
      _attachmentsList.clear();
    });

    await _taskProvider.getAttachmentList(widget.taskId);

    final List<ResponseAttachment> newItems = _taskProvider.attachmentListData;
    if (newItems.isEmpty) {
      setState(() {
        _isLoadingAttachmentList = false;
      });
    } else {
      setState(() {
        _attachmentsList.addAll(newItems);
        _isLoadingAttachmentList = false;
      });
    }
  }

  Future<void> _fetchCommentList({bool isScrollToDown = false}) async {
    if (_isLoadingCommentList) return;

    setState(() {
      _isLoadingCommentList = true;
      _commentsList.clear();
    });

    await _taskProvider.getCommentList(widget.taskId);

    final List<ResponseComment> newItems = _taskProvider.commentListData;
    if (newItems.isEmpty) {
      setState(() {
        _isLoadingCommentList = false;
      });
    } else {
      setState(() {
        _commentsList.addAll(newItems);
        _isLoadingCommentList = false;
      });
      if (isScrollToDown) {
        await Future.delayed(const Duration(seconds: 2));
        _autoScrollToBottom();
      }
    }
  }

  Future<void> _onRefresh() async {
    _fetchDetailTasks();
    _fetchTasksItemList();
    _fetchAttachmentItemList();
    _fetchCommentList();
  }

  Future<void> _addComment(String comment) async {
    RequestComment request = RequestComment();
    if (_isReply) {
      request.parentCommentId = _commentId;
    }

    request.module = _module;
    request.moduleId = widget.taskId;
    request.content = comment;
    request.contentType = _contentType;

    await _taskProvider.addComment(request);

    BaseResponse response = _taskProvider.responseMessage;
    if (response.status == false) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.translate('update_comment_failed')),
        ),
      );
    } else {
      _textController.clear();
      _clearReply();
      _fetchCommentList(isScrollToDown: true);
    }
  }

  void _uploadFile(String typeUpload) async {
    List<String> allowedExtensions = [];

    if (_contentType == "image") {
      allowedExtensions = imageExtensions;
    } else if (_contentType == "video") {
      allowedExtensions = videoExtensions;
    } else {
      allowedExtensions = [
        ...imageExtensions,
        ...videoExtensions,
        ...documentExtensions,
      ];
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      if (!mounted) return;
      Dialogs.showLoadingDialog(context);

      File file = File(result.files.single.path ?? '');
      String? fileExtension = result.files.single.extension;

      await _taskProvider.uploadFile(file);

      final ResponseUploadFile resultUploadFile =
          _taskProvider.resultUploadFile;
      String? url = resultUploadFile.url;
      String? mimeType = fileExtension;
      String? fileName = resultUploadFile.fileName;

      if (url != null && url.isNotEmpty) {
        if (typeUpload == _typeUploadAttachment) {
          _sendUploadFile(url, mimeType ?? '', fileName ?? '');
        } else {
          _addComment(url);

          if (!mounted) return;
          Dialogs.dismissDialog(context);

          await Future.delayed(Duration(milliseconds: 200));

          if (!mounted) return;
          Dialogs.dismissDialog(context);
        }
      } else {
        if (!mounted) return;
        Dialogs.dismissDialog(context);
      }
    }
  }

  void _sendUploadFile(String url, String mimeType, String fileName) async {
    RequestAddAttachment request = RequestAddAttachment(
      taskId: widget.taskId,
      attachmentUrl: url,
      attachmentType: mimeType,
      attachmentName: fileName,
      isThumbnail: 1,
    );

    await _taskProvider.addAttachment(request);

    BaseResponse response = _taskProvider.responseMessage;
    if (response.status == false) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.translate('update_attachment_failed')),
        ),
      );
    }

    if (!mounted) return;
    Dialogs.dismissDialog(context);

    _fetchAttachmentItemList();
  }

  void _removeAttachment(String attachmentId) async {
    if (!mounted) return;
    Dialogs.showLoadingDialog(context);

    await _taskProvider.removeAttachment(attachmentId);

    BaseResponse response = _taskProvider.responseMessage;
    if (response.status == false) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.translate('delete_attachment_failed')),
        ),
      );
    }

    await Future.delayed(Duration(milliseconds: 500));

    if (!mounted) return;
    Dialogs.dismissDialog(context);

    _fetchAttachmentItemList();
  }

  Future<void> _fetchDetailTasks() async {
    await Future.delayed(Duration(milliseconds: 200));

    await _taskProvider.getDetailTask(
      widget.projectId,
      widget.boardId,
      widget.taskId,
      widget.taskId,
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

  Future<void> _clearReply() async {
    setState(() {
      _isReply = false;
      _replyName = "";
      _commentId = "";
    });
    _focusNode.unfocus();
  }

  void _selectUploadAttachment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(AppTranslations.translate('select_media_upload')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(AppTranslations.translate('upload_image')),
                onTap: () async {
                  setState(() {
                    _contentType = "image";
                  });
                  _uploadFile(_typeUploadComment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: Text(AppTranslations.translate('upload_video')),
                onTap: () async {
                  setState(() {
                    _contentType = "video";
                  });
                  _uploadFile(_typeUploadComment);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _autoScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }
}
