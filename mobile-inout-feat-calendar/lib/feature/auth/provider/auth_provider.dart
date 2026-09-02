import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mobile_in_out/core/resources/constants/app_const.dart';
import 'package:mobile_in_out/core/resources/injector/di.dart';
import 'package:mobile_in_out/core/resources/local/local_service.dart';
import 'package:mobile_in_out/core/resources/local/pref_service.dart';
import 'package:mobile_in_out/core/resources/repositories/repository.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/helper/auth_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/auth/auth_response.dart';
import 'package:mobile_in_out/core/utils/models/auth/refresh_token_model_request.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final Repository _repository;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final ShardPrefService _prefService = sl<ShardPrefService>();

  AuthProvider(this._repository);

  RequestState _stateLogin = RequestState.Empty;
  RequestState get stateLogin => _stateLogin;
  RequestState _stateAuth = RequestState.Empty;
  RequestState get stateAuth => _stateAuth;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? AppConst.dummyAccount : null,
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? AppConst.dummyPassword : null,
  );

  bool showPassword = false;
  void setSHowPassword(bool val) {
    showPassword = val;
    notifyListeners();
  }

  ProfileModel _profileModel = ProfileModel();
  ProfileModel get profileModel => _profileModel;

  Future<void> login() async {
    _stateLogin = RequestState.Loading;
    notifyListeners();

    final response = await _repository.login(
      userName: emailController.text,
      password: passwordController.text,
    );

    response.fold(
      (error) {
        LogHelper.logDebug(
          "FOLD DONE ERROR: ${error.message.toString()}"
          'name: login',
        );
        _errorMessage = error.message.toString();
        _stateLogin = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateLogin = RequestState.Loaded;

        AuthResponse authToken = data.response as AuthResponse;

        await _prefService.setString(
          PrefServiceKey.email,
          emailController.text,
        );
        await _prefService.setString(
          PrefServiceKey.authToken,
          authToken.token ?? '',
        );
        await _prefService.setString(
          PrefServiceKey.refrehToken,
          authToken.refreshToken ?? '',
        );
        await _prefService.setString(
          PrefServiceKey.appsId,
          authToken.appsId ?? "",
        );

        await _prefService.setBool(PrefServiceKey.isLogin, true);

        notifyListeners();

        final service = FlutterBackgroundService();
        bool isRunning = await service.isRunning();
        if (!isRunning) {
          await service.startService();
        }
        LogHelper.logDebug(
          "================= BACKGROUND SERVICE IS ${isRunning ? '' : 'NOT'} 'RUNNING' From Auth Token:${authToken.token} =================",
        );

        service.invoke("taskUpdateToken", {"token": authToken.token});
        service.invoke("startTaskTrackingLocation", {"token": authToken.token});

        await fetchProfileFromApi(authToken.token ?? '');
        await fetchProfileFromLocal();
      },
    );
  }

  Future<void> fetchProfileFromApi(String token) async {
    // check if controller is empty fetch profile from local
    if (emailController.text.isEmpty) {
      await _prefService.getString(PrefServiceKey.email).then((value) {
        emailController.text = value ?? '';
      });
      return;
    }

    final response = await _repository.getProfile(userId: emailController.text);
    response.fold(
      (error) {
        LogHelper.logDebug(
          "FOLD DONE ERROR: ${error.message.toString()}"
          'name: fetch profile',
        );
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) async {
        LogHelper.logDebug(
          "FOLD DONE DATA: ${data.response?.toJson()}"
          'name: fetchProfileFromApi',
        );

        if (await checkUserAlreadyExist(
          profileModel: data.response ?? ProfileModel(),
        )) {
          await saveProfileToLocalStorage(data.response ?? ProfileModel());
        }

        fetchProfileFromLocal(profileModel: data.response ?? ProfileModel());
      },
    );
  }

  Future<void> fetchProfileNoSaveToLocal() async {
    // check if controller is empty fetch profile from local
    if (emailController.text.isEmpty) {
      await _prefService.getString(PrefServiceKey.email).then((value) {
        emailController.text = value ?? '';
      });
      return;
    }

    final response = await _repository.getProfile(userId: emailController.text);
    response.fold(
      (error) {
        _errorMessage = error.message.toString();
        notifyListeners();
      },
      (data) async {
        _profileModel = data.response ?? ProfileModel();
        notifyListeners();
      },
    );
  }

  Future<void> fetchProfileFromLocal({ProfileModel? profileModel}) async {
    List<ProfileModel> users = await _databaseHelper.queryAllUsers();
    if (users.isNotEmpty) {
      if (profileModel != null && (users.first.name != profileModel.name)) {
        await _databaseHelper.deleteProfile();
        await saveProfileToLocalStorage(profileModel);
        users = await _databaseHelper.queryAllUsers();
      }

      _profileModel = users.first;
      notifyListeners();
    }
  }

  Future<bool> checkUserAlreadyExist({
    required ProfileModel profileModel,
  }) async {
    final users = await _databaseHelper.queryAllUsers();
    return users.isEmpty;
  }

  Future<void> saveProfileToLocalStorage(ProfileModel model) async {
    await _databaseHelper.insert(model);
  }

  Future<void> removeAuthToken() async {
    await _prefService.remove(PrefServiceKey.authToken);
  }

  Future<void> refreshToken() async {
    LogHelper.logDebug('debug -> refreshtoken call refreshtoken');
    _stateAuth = RequestState.Empty;
    bool isLogin = await _prefService.getBool(PrefServiceKey.isLogin) ?? false;
    LogHelper.logDebug('debug -> isLogin $isLogin');
    if (!isLogin) {
      return;
    }
    LogHelper.logDebug(
      'debug -> refreshtoken call refreshtoken next isLogin true',
    );
    _stateAuth = RequestState.Loading;
    notifyListeners();

    String? refreshToken = await _prefService.getString(
      PrefServiceKey.refreshToken,
    );

    RefreshTokenModelRequest refreshTokenModelRequest =
        RefreshTokenModelRequest(refreshToken: refreshToken);
    final response = await _repository.refreshToken(
      request: refreshTokenModelRequest,
    );

    response.fold(
      (error) async {
        LogHelper.logDebug(
          'debug -> refreshtoken errorCode api refreshtoken ${error.message.toString()}',
        );
        await AuthHelper.logout();
        _errorMessage = error.message.toString();
        _stateAuth = RequestState.Error;
        notifyListeners();
      },
      (data) async {
        _stateAuth = RequestState.Loaded;

        AuthResponse? responseData = data.response;
        LogHelper.logDebug(
          'debug -> refreshtoken success api refreshtoken ${responseData?.token.toString()}',
        );
        String token = responseData?.token ?? '';
        String refreshToken = responseData?.refreshToken ?? '';

        await _prefService.setString(PrefServiceKey.authToken, token);
        await _prefService.setString(PrefServiceKey.refreshToken, refreshToken);

        notifyListeners();
      },
    );
  }

  Future<void> clearAllLocalStorage() async {
    await _prefService.clear();
  }
}
