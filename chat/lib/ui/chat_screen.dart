import 'dart:async';
import 'dart:developer';
import 'package:auto_route/annotations.dart';
import 'package:chat/controllers/chats_controller.dart';
import 'package:chat/controllers/user_status_controller.dart';
import 'package:chat/core/resources/injector/di.dart';
import 'package:chat/core/resources/storage/shared_preference_service.dart';
import 'package:chat/core/route_change_notifier.dart';
import 'package:chat/core/utils/global_utils.dart';
import 'package:chat/core/widget/bottom_sheet_widget.dart';
import 'package:chat/core/widget/contact_list_component.dart';
import 'package:chat/core/widget/conversation_list.dart';
import 'package:chat/models/chats_model.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/organization_model.dart';
// import 'package:chat/models/project_model.dart';
import 'package:chat/models/profile_model.dart';
import 'package:chat/models/user_list_model.dart';
import 'package:chat/models/user_status_model.dart';
import 'package:chat/ui/chat_detail_screen.dart';
import 'package:chat/viewmodel/chat_view_model.dart';
import 'package:chat/viewmodel/group_list_view_model.dart';
import 'package:chat/viewmodel/user_list_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, String? navFrom});

  final String navFrom = 'gsm_tracker';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatsController _chatsController = ChatsController();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<QuerySnapshot>? _subscription;

  late final UserListViewModel _userListViewModel;
  late final GroupListViewModel _groupListViewModel;
  late final ChatViewModel _chatViewModel;

  ProfileModel? _profileModel = ProfileModel();
  final UserStatusController _userStatusController = UserStatusController();
  final SharedPreferenceService _prefService = sl<SharedPreferenceService>();

  List<ChatsModel> _originChat = [];
  List<ChatsModel> _chatsList = [];
  List<UserListModel> _originUserListData = [];
  List<UserListModel> _userListData = [];
  // List<ProjectModel> _originGroupListData = [];
  // List<ProjectModel> _groupListData = [];
  List<OrganizationModel> _originGroupListData = [];
  List<OrganizationModel> _groupListData = [];
  String? _userId;
  String? _appsId;
  bool _isOnResume = false;
  bool _firstLoad = true;
  bool _isAdmin = false;

  @override
  void initState() {
    _userListViewModel = sl<UserListViewModel>();
    _groupListViewModel = sl<GroupListViewModel>();
    _initData();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("Debug : chat_screen => onPopBack");
      _isOnResume = false;
    });

    WidgetsBinding.instance.addObserver(this);
    _listenToFirestoreCollection();
    _searchController.addListener(_filterChats);
  }

  void _initData() async {
    _chatViewModel = sl<ChatViewModel>();
    _profileModel = await _userListViewModel.getProfileLocal();
    _userId = _profileModel?.userId.toString();
    _appsId = _profileModel?.appsId;
    List<String>? roles = _profileModel?.roles;
    if (roles != null) {
      if (roles.isNotEmpty) {
        _isAdmin = roles.any((role) => role == 'Administrator');
      }
    }

    await GlobalUtils.clearNotification();
    await _prefService.setBool(PrefServiceKey.isNotifChat, false);

    await _loadUserList();
    await _loadGroupList();
    await _loadChats();
    _updateUserStatus('online');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _searchController.dispose();
    _updateUserStatus('offline');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("Debug : chat_screen => onResume");
    switch (state) {
      case AppLifecycleState.resumed:
        log("Debug : chat_screen => App resumed");
        log("Debug : chat_screen => App resumed _isOnResume $_isOnResume");
        if (_isOnResume) {
          if (!_firstLoad) _loadChats();
          _updateUserStatus('online');
          _isOnResume = false;
        }
        break;
      case AppLifecycleState.inactive:
        log("Debug : chat_screen => App inactive");
        _updateUserStatus('offline');
        break;
      case AppLifecycleState.paused:
        log("Debug : chat_screen => App paused");
        _updateUserStatus('offline');
        _isOnResume = true;
        break;
      case AppLifecycleState.detached:
        log("Debug : chat_screen => App detached");
        _updateUserStatus('offline');
        break;
      case AppLifecycleState.hidden:
        log("Debug : chat_screen => App hidden");
        _updateUserStatus('offline');
        _isOnResume = true;
    }
  }

  Future<void> _loadChats() async {
    final chatsController = await _chatsController.fetchChats(_userId);
    log('Debug -> chat_screen : chatsController $chatsController');

    // if (_userListData.isNotEmpty) {
    //   chatsController.asMap().forEach((index, value) {
    //     if (value.type == 'group') {

    //     } else {
    //       value.participants?.forEach((userId) {
    //         if (userId != _userId) {
    //           UserListModel userList = _originUserListData.firstWhere((user) => user.id.toString() == _userId, orElse: () => UserListModel());
    //           log('userList $userList');
    //           chatsController[index].name = userList.name;
    //           chatsController[index].imageProfile = userList.profileUrl;
    //         }
    //       });
    //     }
    //   });
    // }

    if (!mounted) return;

    setState(() {
      _originChat = chatsController;
      _chatsList = chatsController;
    });

    _firstLoad = false;
  }

  Future<void> _loadUserList() async {
    FilterListModelRequest filterListModelRequest = FilterListModelRequest(
      // page: 1,
      // limit: 10,
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

    _originUserListData = _userListData;
  }

  Future<void> _loadGroupList() async {
    log('load grouplist');
    FilterListModelRequest filterListModelRequest = FilterListModelRequest(
      // page: 1,
      // limit: 10,
      limit: 100,
      search: "",
      sort: "organization_name",
      order: "asc",
      offset: 0,
    );
    // {"page":1,"limit":10,"search":"","sort":"name","order":"asc","offset":0}
    await _groupListViewModel.getGroupList(
        _appsId ?? '', filterListModelRequest);

    _groupListData = _groupListViewModel.groupListData;
    _originGroupListData = _groupListData;
  }

  Future<String> _chatName(ChatsModel chatData) async {
    log('debug -> type ${chatData.type}');
    log('debug -> groupid ${chatData.groupId}');

    if (chatData.type == "group") {
      return await _getNameGroup(chatData.groupId?.toString());
    } else {
      String userData = '';
      final participant = chatData.participants;
      if (participant != null) {
        for (var user in participant) {
          if (user.toString() != _userId) {
            userData = user.toString();
          }
        }
      }
      return await _getNameUser(userData);
    }
  }

  String _chatImage(ChatsModel chatData) {
    if (chatData.type == "group") {
      return _getImageGroup(chatData.groupId?.toString()) ?? '';
    } else {
      String userData = '';
      final participant = chatData.participants;
      if (participant != null) {
        for (var user in participant) {
          if (user.toString() != _userId) {
            userData = user.toString();
          }
        }
      }
      return _getImageUser(userData) ?? '';
    }
  }

  Future<String> _getNameUser(String? senderId) async {
    UserListModel userList = _originUserListData.firstWhere(
        (user) => user.employeeId.toString() == senderId,
        orElse: () => UserListModel());
    String? userName;

    log('userdata $senderId');

    if (userList.employeeName == null || userList.employeeName!.isEmpty) {
      try {
        userName = await _chatViewModel.getUserName(senderId);
      } catch (e) {
        userName = 'Personal-$senderId';
      }
    } else {
      userName = userList.employeeName;
    }
    return userName ?? 'Personal-$senderId';
  }

  Future<String> _getNameGroup(String? id) async {
    // ProjectModel groupList = _originGroupListData.firstWhere(
    //     (group) => group.projectId.toString() == id,
    //     orElse: () => ProjectModel());
    // String? groupName;

    // if (groupList.projectName == null || groupList.projectName!.isEmpty) {
    //   try {
    //     groupName = await _chatViewModel.getGroupName(id);
    //   } catch (e) {
    //     groupName = 'Group $id';
    //   }
    // } else {
    //   groupName = groupList.projectName;
    // }

    OrganizationModel groupList = _originGroupListData.firstWhere(
        (group) => group.organizationId.toString() == id,
        orElse: () => OrganizationModel());
    String? groupName;

    if (groupList.organizationName == null ||
        groupList.organizationName!.isEmpty) {
      try {
        groupName = await _chatViewModel.getGroupName(id);
      } catch (e) {
        groupName = 'Group $id';
      }
    } else {
      groupName = groupList.organizationName;
    }
    return groupName ?? 'Group $id';
  }

  String? _getImageUser(String? id) {
    UserListModel userList = _originUserListData.firstWhere(
        (user) => user.employeeId.toString() == id,
        orElse: () => UserListModel());
    return userList.profileUrl;
  }

  // String? _getImageGroup(String? id) {
  //   ProjectModel groupList = _originGroupListData.firstWhere(
  //       (group) => group.projectId.toString() == id,
  //       orElse: () => ProjectModel());
  //   return groupList.thumbnailUrl;
  // }

  String? _getImageGroup(String? id) {
    OrganizationModel groupList = _originGroupListData.firstWhere(
        (group) => group.organizationId.toString() == id,
        orElse: () => OrganizationModel());
    return '';
  }

  bool _isMessageRead(Map<String, dynamic>? unreadCounts) {
    int value = unreadCounts?[_userId] ?? -1;
    if (value == 0) {
      return true;
    } else {
      return false;
    }
  }

  void _listenToFirestoreCollection() {
    _subscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _userId)
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      if (!mounted) return;

      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          log('Document Added: ${docChange.doc.data()}');
          if (!_firstLoad && !_isOnResume) _loadChats();
        } else if (docChange.type == DocumentChangeType.modified) {
          log('Document Modified: ${docChange.doc.data()}');
          if (!_firstLoad && !_isOnResume) _loadChats();
        } else if (docChange.type == DocumentChangeType.removed) {
          log('Document Removed: ${docChange.doc.data()}');
          if (!_firstLoad && !_isOnResume) _loadChats();
        }
      }
    });
  }

  void _filterChats() async {
    String query = _searchController.text.toLowerCase();
    List<ChatsModel> filteredChats = [];

    for (var chat in _originChat) {
      String name = await _chatName(chat);
      if (name.toLowerCase().contains(query)) {
        filteredChats.add(chat);
      }
    }

    if (!mounted) return;

    setState(() {
      _chatsList = filteredChats;
    });
  }

  void _updateUserStatus(String status) async {
    UserStatusModel userStatus = UserStatusModel(
      id: _userId,
      lastUpdate: Timestamp.now(),
      status: status,
    );

    _userStatusController.updateUserStatus(userStatus, _userId);
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      final result = await _chatsController.deleteChat(chatId);
      if (result == "success") {
        // Remove the chat from the local list
        setState(() {
          _chatsList.removeWhere((chat) => chat.id == chatId);
          _originChat.removeWhere((chat) => chat.id == chatId);
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete conversation: $result'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error deleting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _userListView(bool isGroup) {
    return StatefulBuilder(builder: (BuildContext context, setState) {
      log('load UserlistView');
      return Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: TextField(
            onChanged: (text) {
              String query = text.toLowerCase();
              setState(() {
                _userListData = _originUserListData.where((user) {
                  String name = user.employeeName ?? '';
                  log('name _filterContactList $name vs $query');
                  return name.toLowerCase().contains(query);
                }).toList();
              });
            },
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
          ),
        ),
        ListView.builder(
          itemCount: _userListData.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ContactListComponent(
              id: _userListData[index].employeeId,
              name: _userListData[index].employeeName,
              imageUrl: _userListData[index].profileUrl,
              userId: _userId,
              type: isGroup == true ? 'group' : 'private',
              isGroup: isGroup,
              isAdmin: _isAdmin,
            );
          },
        ),
      ]);
    });
  }

  Widget _groupListView(bool isGroup) {
    return StatefulBuilder(builder: (BuildContext context, setState) {
      log('load UserlistView');
      return Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: TextField(
            onChanged: (text) {
              String query = text.toLowerCase();
              setState(() {
                _groupListData = _originGroupListData.where((group) {
                  // String name = group.projectName ?? '';
                  String name = group.organizationName ?? '';
                  log('name _filterContactList $name vs $query');
                  return name.toLowerCase().contains(query);
                }).toList();
              });
            },
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
          ),
        ),
        ListView.builder(
          itemCount: _groupListData.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ContactListComponent(
              // id: _groupListData[index].projectId,
              // name: _groupListData[index].projectName,
              // imageUrl: _groupListData[index].thumbnailUrl,
              id: _groupListData[index].organizationId,
              name: _groupListData[index].organizationName,
              imageUrl: '',
              userId: _userId,
              type: isGroup == true ? 'group' : 'private',
              isGroup: isGroup,
              isAdmin: _isAdmin,
              organizations: [_groupListData[index]],
            );
          },
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      resizeToAvoidBottomInset: false,
      body: Consumer<RouteChangeNotifier>(
          builder: (context, routeChangeNotifier, child) {
        log('Debug -> chat_screen : routeChangeNotifier');
        if (routeChangeNotifier.hasRouteChanged) {
          log('Debug -> chat_screen : routeChangeNotifier loadChats');
          // Call your function when the route change happens
          context.read<RouteChangeNotifier>().stopNotifyRouteChange();
          if (!_firstLoad) _loadChats();
          _updateUserStatus('online');
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _userListData = _originUserListData;
                          });
                          BottomSheetWidget.showBottomSheetWidget(
                              context, _userListView(false));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue,
                          ),
                          child: const Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "New User Chat",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _groupListData = _originGroupListData;
                          });
                          BottomSheetWidget.showBottomSheetWidget(
                              context, _groupListView(true));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey,
                          ),
                          child: const Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "New Mission Chat",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.all(8),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade100)),
                  ),
                ),
              ),
              ListView.builder(
                itemCount: _chatsList.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return FutureBuilder<List<String>>(
                    future: Future.wait([
                      _chatName(_chatsList[index]),
                      _getNameUser(_chatsList[index]
                          .lastMessage
                          ?.senderId), // Future<String> untuk senderName
                    ]),
                    builder: (context, snapshot) {
                      final displayName = snapshot.data?[0] ?? 'Unknown';
                      final senderName = snapshot.data?[1] ?? 'Unknown';

                      return ConversationList(
                        id: _chatsList[index].id ?? '',
                        name: displayName,
                        messageText:
                            _chatsList[index].lastMessage?.content ?? '',
                        imageUrl: _chatImage(_chatsList[index]),
                        time: GlobalUtils.dateToString(
                            _chatsList[index].updatedAt),
                        isMessageRead:
                            _isMessageRead(_chatsList[index].unreadCounts),
                        userId: _userId ?? '',
                        type: _chatsList[index].type ?? '',
                        readCount:
                            _chatsList[index].unreadCounts?[_userId] ?? -1,
                        userName: displayName,
                        userImage: _chatImage(_chatsList[index]),
                        senderId: _chatsList[index].lastMessage?.senderId,
                        senderName: senderName,
                        chatsModel: _chatsList[index],
                        typeMessage: _chatsList[index].lastMessage?.type,
                        onDelete: _deleteChat,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
