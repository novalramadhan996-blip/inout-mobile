import 'dart:io';

import 'package:chat/core/utils/base_response_custom.dart';
import 'package:chat/core/utils/failure.dart';
import 'package:chat/models/filter_list_model_request.dart';
import 'package:chat/models/organization_employee_model.dart';
import 'package:chat/models/organization_model.dart';
// import 'package:chat/models/project_model.dart';
import 'package:chat/models/profile_model.dart';
import 'package:chat/models/response_upload_model.dart';
import 'package:chat/models/user_list_model.dart';
import 'package:dartz/dartz.dart';

abstract class RepositoryInterface {
  //MyProfile
  Future<Either<Failure, BaseResponseCustom<ProfileModel>>> myProfile();
  Future<ProfileModel?> getProfileLocal();

  //User list
  Future<Either<Failure, BaseResponseCustom<List<UserListModel>>>> getUserList(
      {required FilterListModelRequest request});
  Future<Either<Failure, BaseResponseCustom<UserListModel>>> getUserData(
      {required String request});

  //group list
  // Future<Either<Failure, BaseResponseCustom<List<ProjectModel>>>> getGroupList(
  //     {required FilterListModelRequest request});
  // Future<Either<Failure, BaseResponseCustom<ProjectModel>>> getGroupData(
  //     {required String request});
  Future<Either<Failure, BaseResponseCustom<List<OrganizationModel>>>>
      getGroupList(
          {required String appsId, required FilterListModelRequest request});
  Future<Either<Failure, BaseResponseCustom<OrganizationModel>>> getGroupData(
      {required String request});
  Future<Either<Failure, BaseResponseCustom<List<OrganizationEmployeeModel>>>>
      getGroupMermber({required FilterListModelRequest request});

  //Upload File
  Future<Either<Failure, BaseResponseCustom<ResponseUploadModel>>> uploadFile(
      {required File file});
}
