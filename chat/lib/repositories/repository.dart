import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/core/resources/injector/di.dart';
import 'package:chat/core/resources/network/rest_client.dart';
import 'package:chat/core/resources/storage/shared_preference_service.dart';
import 'package:chat/core/utils/base_response_custom.dart';
import 'package:chat/core/utils/failure.dart';
import 'package:chat/core/utils/response_helper.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/organization_employee_model.dart';
import 'package:chat/models/organization_model.dart';
import 'package:chat/models/profile_model.dart';
// import 'package:chat/models/project_model.dart';
import 'package:chat/models/response_upload_model.dart';
import 'package:chat/models/user_list_model.dart';
import 'package:chat/repositories/repository_interface.dart';
import 'package:dartz/dartz.dart';

class Repository extends RepositoryInterface {
  final RestClient restClient;
  final SharedPreferenceService _prefService = sl<SharedPreferenceService>();

  Repository({required this.restClient});

  @override
  Future<Either<Failure, BaseResponseCustom<ProfileModel>>> myProfile() async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.myProfile());

    log('response $response');

    if (response is Failure) return Left(response);

    return Right(BaseResponseCustom(
      response: ProfileModel.fromJson((response as Map<String, dynamic>)),
      errorMessage: null,
      status: true,
    ));
  }

  @override
  Future<ProfileModel?> getProfileLocal() async {
    String? myProfile = await _prefService.getString(PrefServiceKey.myProfile);
    if (myProfile != null && myProfile != '' && myProfile != '{}') {
      return ProfileModel.fromJson(json.decode(myProfile));
    }
    return null;
  }

  @override
  Future<Either<Failure, BaseResponseCustom<List<UserListModel>>>> getUserList(
      {required FilterListModelRequest request}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.getUserList(request));

    log('response $response');

    if (response is Failure) return Left(response);

    try {
      final parsedResponse = response is String
          ? json.decode(response) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      final List<Map<String, dynamic>> rows = (parsedResponse['rows'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final List<UserListModel> users =
          rows.map((e) => UserListModel.fromJson(e)).toList();

      return Right(BaseResponseCustom(
        response: users,
        errorMessage: null,
        status: true,
      ));
    } catch (e) {
      log('Parsing error: $e');
      return const Left(CommonFailure("Failed to parse response"));
    }
  }

  @override
  Future<Either<Failure, BaseResponseCustom<UserListModel>>> getUserData(
      {required String request}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.getUserData(request));

    log('response $response');

    if (response is Failure) return Left(response);

    try {
      final parsedResponse = response is String
          ? json.decode(response) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      final Map<String, dynamic> rows = (parsedResponse['data']);

      final UserListModel users = UserListModel.fromJson(rows);

      return Right(BaseResponseCustom(
        response: users,
        errorMessage: null,
        status: true,
      ));
    } catch (e) {
      log('Parsing error: $e');
      return const Left(CommonFailure("Failed to parse response"));
    }
  }

  @override
  Future<Either<Failure, BaseResponseCustom<ResponseUploadModel>>> uploadFile(
      {required File file}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.uploadFile(file));

    log('response $response');

    if (response is Failure) return Left(response);

    try {
      final parsedResponse = response is String
          ? json.decode(response) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      final Map<String, dynamic> responseData =
          parsedResponse['data'] as Map<String, dynamic>;

      log('response data $responseData');

      return Right(BaseResponseCustom(
        response: ResponseUploadModel.fromJson(responseData),
        errorMessage: null,
        status: true,
      ));
    } catch (e) {
      log('Parsing error: $e');
      return const Left(CommonFailure("Failed to parse response"));
    }
  }

  @override
  Future<Either<Failure, BaseResponseCustom<OrganizationModel>>> getGroupData(
      {required String request}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.getGroupData(request));

    if (response is Failure) return Left(response);

    try {
      final parsedResponse = response is String
          ? json.decode(response) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      final Map<String, dynamic> rows = (parsedResponse['data']);

      final OrganizationModel groups = OrganizationModel.fromJson(rows);

      return Right(BaseResponseCustom(
        response: groups,
        errorMessage: null,
        status: true,
      ));
    } catch (e) {
      log('Parsing error: $e');
      return const Left(CommonFailure("Failed to parse response"));
    }
  }

  @override
  Future<Either<Failure, BaseResponseCustom<List<OrganizationModel>>>>
      getGroupList(
          {required String appsId,
          required FilterListModelRequest request}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.getGroupList(appsId, request));

    if (response is Failure) return Left(response);

    try {
      final parsedResponse = response is String
          ? json.decode(response) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      final List<Map<String, dynamic>> rows = (parsedResponse['rows'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final List<OrganizationModel> groups =
          rows.map((e) => OrganizationModel.fromJson(e)).toList();

      return Right(BaseResponseCustom(
        response: groups,
        errorMessage: null,
        status: true,
      ));
    } catch (e) {
      log('Parsing error: $e');
      return const Left(CommonFailure("Failed to parse response"));
    }
  }

  @override
  Future<Either<Failure, BaseResponseCustom<List<OrganizationEmployeeModel>>>>
      getGroupMermber({required FilterListModelRequest request}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.getGroupMember(request));

    log('response $response');

    if (response is Failure) return Left(response);

    try {
      final parsedResponse = response is String
          ? json.decode(response) as Map<String, dynamic>
          : response as Map<String, dynamic>;

      final List<Map<String, dynamic>> rows = (parsedResponse['rows'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final List<OrganizationEmployeeModel> groups =
          rows.map((e) => OrganizationEmployeeModel.fromJson(e)).toList();

      return Right(BaseResponseCustom(
        response: groups,
        errorMessage: null,
        status: true,
      ));
    } catch (e) {
      log('Parsing error: $e');
      return const Left(CommonFailure("Failed to parse response"));
    }
  }

  // @override
  // Future<Either<Failure, BaseResponseCustom<List<ProjectModel>>>> getGroupList(
  //     {required FilterListModelRequest request}) async {
  //   Object response = await ResponseHelper.getResponse(
  //       () async => await restClient.getGroupList(request));

  //   log('response $response');

  //   if (response is Failure) return Left(response);

  //   try {
  //     final parsedResponse = response is String
  //         ? json.decode(response) as Map<String, dynamic>
  //         : response as Map<String, dynamic>;

  //     final List<Map<String, dynamic>> rows = (parsedResponse['rows'] as List)
  //         .map((e) => e as Map<String, dynamic>)
  //         .toList();

  //     final List<ProjectModel> groups =
  //         rows.map((e) => ProjectModel.fromJson(e)).toList();

  //     return Right(BaseResponseCustom(
  //       response: groups,
  //       errorMessage: null,
  //       status: true,
  //     ));
  //   } catch (e) {
  //     log('Parsing error: $e');
  //     return Left("Failed to parse response" as Failure);
  //   }
  // }

  // @override
  // Future<Either<Failure, BaseResponseCustom<ProjectModel>>> getGroupData(
  //     {required String request}) async {
  //   Object response = await ResponseHelper.getResponse(
  //       () async => await restClient.getGroupData(request));

  //   log('response $response');

  //   if (response is Failure) return Left(response);

  //   try {
  //     final parsedResponse = response is String
  //         ? json.decode(response) as Map<String, dynamic>
  //         : response as Map<String, dynamic>;

  //     final Map<String, dynamic> rows = (parsedResponse['data']);

  //     final ProjectModel groups = ProjectModel.fromJson(rows);

  //     return Right(BaseResponseCustom(
  //       response: groups,
  //       errorMessage: null,
  //       status: true,
  //     ));
  //   } catch (e) {
  //     log('Parsing error: $e');
  //     return Left("Failed to parse response" as Failure);
  //   }
  // }
}
