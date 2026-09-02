import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat/controllers/user_status_controller.dart';
import 'package:chat/core/resources/constants/app_constants.dart';
import 'package:chat/core/resources/injector/di.dart';
import 'package:chat/core/utils/global_utils.dart';
import 'package:chat/core/utils/request_state.dart';
import 'package:chat/core/widget/circle_image.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/response_upload_model.dart';
import 'package:chat/models/user_list_model.dart';
import 'package:chat/models/user_status_model.dart';
import 'package:chat/viewmodel/chat_view_model.dart';
import 'package:chat/viewmodel/user_list_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:chat/core/route_change_notifier.dart';
import 'package:chat/core/widget/bubble_chat.dart';
import 'package:chat/models/last_message_model.dart';
import 'package:chat/controllers/message_controller.dart';
import 'package:chat/models/message_model.dart';

@RoutePage()
class ChatDetailScreen extends StatefulWidget {
  final ChatData? chatData;
  final String? navFrom;

  const ChatDetailScreen(
      {super.key, this.chatData, this.navFrom = 'gsm_tracker'});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final MessageController _messageController = MessageController();
  StreamSubscription<QuerySnapshot>? _subscription;
  final UserStatusController _userStatusController = UserStatusController();
  UserStatusModel _userStatus = UserStatusModel();
  late final UserListViewModel _userListViewModel;
  late final ChatViewModel _chatViewModel;

  bool _isLoading = false;
  bool _isButtonVisible = false;
  String? _chatId = '';
  String? _userId = '';
  String? _senderId;
  String? _type = '';
  String? _userName = '';
  String? _userImage = '';
  int _totalParticipants = 0;
  DocumentSnapshot? _lastDoc;
  final int _limit = AppConstants.limitLoadData;
  List<MessageModel> _messageList = [];
  List<UserListModel> _userListData = [];

  final imageExtensions = ['jpg', 'jpeg', 'png'];
  final videoExtensions = ['mp4', 'mkv', 'mov', 'avi', 'webm', 'flv', 'wmv'];
  final documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  @override
  void initState() {
    super.initState();
    initView();
  }

  void initView() async {
    _userListViewModel = sl<UserListViewModel>();
    _chatViewModel = sl<ChatViewModel>();
    _chatId = widget.chatData?.id;
    _userId = widget.chatData?.userId;
    _senderId = widget.chatData?.senderId;
    _type = widget.chatData?.type;
    _userName = widget.chatData?.userName;
    _userImage = widget.chatData?.userImage;
    _totalParticipants = widget.chatData?.totalParticipants ?? 0;
    _scrollController.addListener(_scrollListener);
    if (_type == 'private') _getUserStatus();
    await _loadUserList();
    _loadMessage();
    _listenToFirestoreCollection();
    _readMessage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserList() async {
    FilterListModelRequest filterListModelRequest = FilterListModelRequest(
      // page: 1,
      limit: 100,
      search: "",
      sort: "employee_name",
      order: "asc",
      offset: 0,
    );

    await _userListViewModel.getUserList(filterListModelRequest);

    _userListData = _userListViewModel.userListData.where((user) {
      String userId = user.employeeId.toString();
      log('name _filterContactList $userId vs $_userId');
      return userId != _userId;
    }).toList();
  }

  void _scrollListener() {
    //load more data when scrolled to the top
    const threshold =
        100.0; // jarak (dalam pixel) sebelum mencapai ujung scroll
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - threshold &&
        !_isLoading) {
      _loadMoreMessage();
    }

    // show or hide button to scroll to bottom
    if ((_scrollController.position.minScrollExtent -
                _scrollController.position.pixels)
            .abs() <
        300) {
      setState(() {
        _isButtonVisible = false;
      });
    } else {
      setState(() {
        _isButtonVisible = true;
      });
    }
  }

  Future<void> _loadMessage() async {
    if (!mounted) return;
    setState(() {
      _messageList = [];
      _lastDoc = null;
    });

    final result =
        await _messageController.fetchMessage(_chatId, _lastDoc, _limit);

    if (!mounted) return;
    setState(() {
      _messageList = result.messages;
      _lastDoc = result.lastDoc;
    });
  }

  Future<void> _loadMoreMessage() async {
    log('loadmoreMessage called');
    log('Debug -> chat_detail_screen : _lastDoc $_lastDoc');
    log('Debug -> chat_detail_screen : _messageList ${_messageList.length}');

    if (_lastDoc == null && _messageList.isNotEmpty) {
      // If lastDoc is null and there are already messages, do not fetch again
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final result =
        await _messageController.fetchMessage(_chatId, _lastDoc, _limit);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _messageList.addAll(result.messages);
      _lastDoc = result.lastDoc;
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        setState(() {
          _isButtonVisible = false;
        });
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  void _sendMessage() async {
    final String textMessage = _textController.text;
    log('Debug -> chat_detail_screen : _sendMessage $textMessage');
    if (textMessage.isNotEmpty) {
      final newLastMessage = LastMessageModel(
          content: textMessage,
          senderId: _userId ?? '',
          timestamp: Timestamp.fromDate(DateTime.now()),
          type: 'text',
          readBy: [_userId]);
      final newMessage = MessageModel(
          id: '',
          content: textMessage,
          timestamp: Timestamp.fromDate(DateTime.now()),
          type: 'text',
          sender: _userId ?? '',
          readBy: [_userId]);
      await _messageController.createAndUpdateMessage(
          _userId ?? '', newLastMessage, newMessage, _chatId);
      _textController.clear();
      await _loadMessage();
    }
  }

  void _sendUploadFile(ResponseUploadModel uploadModel) async {
    String fileType = uploadModel.mimetype ?? '';
    String fileName = uploadModel.filename ?? '';
    String fileUrl = uploadModel.url ?? '';

    log('fileType $fileType');
    log('fileName $fileName');
    log('fileUrl $fileUrl');

    String textMessage = '';
    String type = '';

    if (imageExtensions.any((ext) => fileName.toLowerCase().endsWith(ext))) {
      textMessage = 'Photo';
      type = 'image';
    } else if (videoExtensions
        .any((ext) => fileName.toLowerCase().endsWith(ext))) {
      textMessage = 'Video';
      type = 'video';
    } else {
      textMessage = fileName;
      type = 'file';
    }

    final newLastMessage = LastMessageModel(
      content: textMessage,
      senderId: _userId ?? '',
      timestamp: Timestamp.fromDate(DateTime.now()),
      type: type,
      readBy: [_userId],
    );
    final newMessage = MessageModel(
      id: '',
      content: '',
      timestamp: Timestamp.fromDate(DateTime.now()),
      type: type,
      sender: _userId ?? '',
      readBy: [_userId],
      fileName: fileName,
      fileType: fileType,
      fileUrl: fileUrl,
    );

    await _messageController.createAndUpdateMessage(
        _userId ?? '', newLastMessage, newMessage, _chatId);
    await _loadMessage();
  }

  void _readMessage() async {
    await _messageController.readBy(_userId != '' ? _userId : '-1', _chatId);
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      // The message will be automatically removed from the UI through the Firestore listener
      await _messageController.deleteMessage(_chatId ?? '', messageId);
    } catch (e) {
      log('Debug -> chat_detail_screen : Error deleting message: $e');
    }
  }

  Future<bool> _handleBackButtonSystem() async {
    log('Debug -> chat_detail_screen : _handleBackButtonSystem');
    context.read<RouteChangeNotifier>().notifyRouteChange();
    return true;
  }

  void _handleBackButtonHeader(BuildContext context) {
    log('Debug -> chat_detail_screen : _handleBackButtonHeader');
    context.read<RouteChangeNotifier>().notifyRouteChange();
    context.router.maybePop();
  }

  String? _getNameUser(String? id) {
    UserListModel userList = _userListData.firstWhere(
        (user) => user.employeeId.toString() == id,
        orElse: () => UserListModel());
    log('userList Name ${userList.employeeName}');
    return userList.employeeName;
  }

  String? _getImageUser(String? id) {
    UserListModel userList = _userListData.firstWhere(
        (user) => user.employeeId.toString() == id,
        orElse: () => UserListModel());
    log('userList Image ${userList.profileUrl}');
    return userList.profileUrl;
  }

  bool _checkIsAllRead(int readByCount) {
    return readByCount == _totalParticipants;
  }

  void _listenToFirestoreCollection() {
    _subscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var docChange in snapshot.docChanges) {
        log('Debug -> chat_screen : listenToFirestoreCollection docChange $docChange');
        log('Debug -> chat_screen : listenToFirestoreCollection docChange.doc.data() ${docChange.doc.data()}');
        if (docChange.type == DocumentChangeType.added) {
          log('Document Added: ${docChange.doc.data()}');
        } else if (docChange.type == DocumentChangeType.modified) {
          log('Document Modified: ${docChange.doc.data()}');
        } else if (docChange.type == DocumentChangeType.removed) {
          log('Document Removed: ${docChange.doc.data()}');
        }
      }
      if (mounted) {
        _loadMessage();
      }
    });
  }

  Future<void> _getUserStatus() async {
    final userStatus = await _userStatusController.fetchUsers(_senderId);
    log('Debug => ChatDetailScreen : _getUserStatus ${userStatus.status}');
    log('Debug => ChatDetailScreen : _getUserStatusId ${userStatus.id}');
    setState(() {
      _userStatus = userStatus;
    });
  }

  void _uploadFile() async {
    final allowedExtensions = [
      ...imageExtensions,
      ...videoExtensions,
      ...documentExtensions,
    ];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        // allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions);

    if (result != null) {
      File file = File(result.files.single.path ?? '');
      log('files $file');

      await _chatViewModel.uploadFile(file);

      if (_chatViewModel.stateView == RequestState.Loaded) {
        _sendUploadFile(_chatViewModel.responseData);
      }
    }
  }

  bool isDifferentDate(int index) {
    if (_messageList.isEmpty || index < 0 || index >= _messageList.length)
      return false;

    final currentDate = _messageList[index].timestamp;
    final nextIndex = index + 1;
    final nextDate = nextIndex < _messageList.length
        ? _messageList[nextIndex].timestamp
        : null;

    return nextDate == null || !GlobalUtils.isSameDate(currentDate, nextDate);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = await _handleBackButtonSystem();
        return shouldPop;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => _handleBackButtonHeader(context),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.router.maybePop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 2),
                  CircleImage(
                      imageUrl: _userImage,
                      height: 45,
                      width: 45,
                      iconDefault: _type == AppConstants.typeChatGroup
                          ? Icons.group
                          : Icons.person),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(_userName ?? '',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(
                          height: 6,
                        ),
                        if (_type != AppConstants.typeChatGroup)
                          Text(_userStatus.status ?? 'Offline',
                              style: TextStyle(
                                  color: _userStatus.status == 'online'
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messageList.length +
                  (_isLoading ? 1 : 0), // Add one for the loading indicator
              padding: const EdgeInsets.only(top: 10, bottom: 70),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == _messageList.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }

                bool isDifferent = isDifferentDate(index);

                if (isDifferent) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: Text(
                            GlobalUtils.dateConversation(
                                _messageList[index].timestamp),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      BubbleChat(
                        id: _messageList[index].id,
                        type: _type ?? "",
                        sender: _messageList[index].sender,
                        userId: _userId ?? "",
                        content: _messageList[index].content,
                        senderName: _getNameUser(_messageList[index].sender),
                        senderImage: _getImageUser(_messageList[index].sender),
                        typeMessage: _messageList[index].type,
                        fileName: _messageList[index].fileName,
                        fileType: _messageList[index].fileType,
                        fileUrl: _messageList[index].fileUrl,
                        isAllRead:
                            _checkIsAllRead(_messageList[index].readBy.length),
                        onDelete: () => _deleteMessage(_messageList[index].id),
                      ),
                    ],
                  );
                } else {
                  return BubbleChat(
                    id: _messageList[index].id,
                    type: _type ?? "",
                    sender: _messageList[index].sender,
                    userId: _userId ?? "",
                    content: _messageList[index].content,
                    senderName: _getNameUser(_messageList[index].sender),
                    senderImage: _getImageUser(_messageList[index].sender),
                    typeMessage: _messageList[index].type,
                    fileName: _messageList[index].fileName,
                    fileType: _messageList[index].fileType,
                    fileUrl: _messageList[index].fileUrl,
                    isAllRead:
                        _checkIsAllRead(_messageList[index].readBy.length),
                    onDelete: () => _deleteMessage(_messageList[index].id),
                  );
                }
              },
            ),
            if (_isButtonVisible)
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 90),
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: FloatingActionButton(
                        heroTag: 'btnScrollToBottom',
                        onPressed: () => _scrollToBottom(),
                        backgroundColor: Colors.grey,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        child: const Icon(Icons.arrow_drop_down,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  )),
            Align(
              alignment: Alignment.bottomLeft,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          _uploadFile();
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: FloatingActionButton(
                            onPressed: () => {
                              FocusScope.of(context).unfocus(),
                              _sendMessage()
                            },
                            backgroundColor: Colors.blue,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            child: const Icon(Icons.send,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatData {
  final String id;
  final String userId;
  final String type;
  final String userName;
  final String userImage;
  final String? senderId;
  final int? totalParticipants;

  ChatData({
    required this.id,
    required this.userId,
    required this.type,
    required this.userName,
    required this.userImage,
    this.senderId,
    this.totalParticipants,
  });
}
