import 'dart:io';

import 'package:mobile_in_out/core/utils/base_response.dart';
import 'package:mobile_in_out/core/utils/errors/error_helper.dart';
import 'package:mobile_in_out/core/utils/models/auth/auth_response.dart';
import 'package:mobile_in_out/core/utils/models/auth/refresh_token_model_request.dart';
import 'package:mobile_in_out/core/utils/models/auth/request_change_password.dart';
import 'package:mobile_in_out/core/utils/models/auth/request_reset_password.dart';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/core/utils/models/group_shift_model.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/history/detail_history_model.dart';
import 'package:mobile_in_out/core/utils/models/history/history_model.dart';
import 'package:mobile_in_out/core/utils/models/member_list_model.dart';
import 'package:mobile_in_out/core/utils/models/organization/organization_employee_model.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:mobile_in_out/core/utils/models/register_model.dart';
import 'package:mobile_in_out/core/utils/models/validate_account_response.dart';
import 'package:mobile_in_out/core/utils/models/work_location/work_location_model.dart';
import 'package:dartz/dartz.dart';
import 'package:mobile_in_out/feature/board/model/response_project.dart';
import 'package:mobile_in_out/feature/board/model/response_task.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/task/model/request_add_attachment.dart';
import 'package:mobile_in_out/feature/task/model/request_comment.dart';
import 'package:mobile_in_out/feature/task/model/response_attachment.dart';
import 'package:mobile_in_out/feature/task/model/response_comment.dart';
import 'package:mobile_in_out/feature/task/model/response_task_item.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_file.dart';
import 'package:mobile_in_out/feature/task/model/response_upload_image.dart';
import 'package:mobile_in_out/feature/todo/model/response_project.dart';

abstract class RepositoryInterface {
  // Auth
  Future<Either<Failure, BaseResponse<AuthResponse>>> login({
    required String userName,
    required String password,
  });
  Future<Either<Failure, BaseResponse<RegisterModel>>> register(
    Map<String, dynamic> data,
  );

  // Verify Account
  Future<Either<Failure, BaseResponse<ValidateAccountResponse>>>
  validateAccount({required String username});
  Future<Either<Failure, BaseResponse<bool>>> validateRegisterCode({
    required Map<String, dynamic> data,
  });
  Future<Either<Failure, BaseResponse<bool>>> registerFaceId({
    required Map<String, dynamic> data,
  });

  // Check In & Out
  Future<Either<Failure, BaseResponse<CheckInResponseModel>>> checkIn({
    required Map<String, dynamic> data,
  });
  Future<Either<Failure, BaseResponse<CheckOutResponseModel>>> checkOut({
    required Map<String, dynamic> data,
  });

  // Profile
  Future<Either<Failure, BaseResponse<ProfileModel>>> getProfile({
    required String userId,
  });
  Future<Either<Failure, BaseResponse<ProfileModel>>> updateProfile({
    required Map<String, dynamic> data,
  });

  // Work Location
  Future<Either<Failure, BaseResponse<LocationResponse>>> getWorkLocation({
    required ListDataRequest request,
  });

  // History
  // Comment because deprecated, when already stable please removed
  // Future<Either<Failure, BaseResponse<List<AbsenceRecord>>>> getHistory({required String accountId});
  Future<Either<Failure, BaseResponse<List<AbsenceHistoryModel>>>> getHistory({
    required ListDataRequest request,
  });
  // Comment because deprecated, when already stable please removed
  // Future<Either<Failure, BaseResponse<AbsenceRecordDetail>>> getDetailHistory({required String absenceId});
  Future<Either<Failure, BaseResponse<AbsenceHistoryModel>>> getDetailHistory({
    required String attendanceId,
  });

  // Request Reset Password
  Future<Either<Failure, BaseResponse<bool>>> requestResetPassword({
    required String email,
  });
  Future<Either<Failure, BaseResponse<bool>>> resetPassword({
    required RequestResetPassword request,
  });

  // Change Password
  Future<Either<Failure, BaseResponse<bool>>> changePassword({
    required RequestChangePassword request,
  });

  // getMGroupShift
  // Comment because deprecated, when already stable please removed
  // Future<Either<Failure, BaseResponse<List<GroupShiftModel>>>> getMyGroupShift(int day);
  // Future<Either<Failure, BaseResponse<ScheduleModel>>> getMySchedule(int day);
  Future<Either<Failure, BaseResponse<List<GroupShiftScheduleResponse>>>>
  getMyGroupShift(ListDataRequest request);
  Future<Either<Failure, BaseResponse<GroupShiftScheduleResponse>>>
  getMySchedule(ListDataRequest request);

  // Location Tracking
  Future<Either<Failure, BaseResponse<bool>>> locationTracking({
    required Map<String, dynamic> data,
  });

  // Projects
  Future<Either<Failure, BaseResponse<List<ResponseProject>>>> getProjectList(
    ListDataRequest request,
  );

  // Boards
  Future<Either<Failure, BaseResponse<List<ResponseBoard>>>>
  getProjectBoardList(
    String projectId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  });

  // Tasks
  Future<Either<Failure, BaseResponse<List<ResponseTask>>>> getProjectTaskList(
    String projectId,
    String boardId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  });

  // Tasks Items
  Future<Either<Failure, BaseResponse<List<ResponseTaskItem>>>>
  getProjectTaskItemList(
    String projectId,
    String boardId,
    String taskId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  });
  Future<Either<Failure, BaseResponse>> updateProjectTaskItemList(
    String projectId,
    String boardId,
    String taskId,
    String taskItemId,
    bool checked,
  );
  Future<Either<Failure, BaseResponse<ResponseTaskItem>>> getDetailTask(
    String projectId,
    String boardId,
    String parentTaskId,
    String taskId,
  );

  // List of attachments
  Future<Either<Failure, BaseResponse<List<ResponseAttachment>>>>
  getAttachmentList(String taskId);
  Future<Either<Failure, BaseResponse<ResponseUploadFile>>> uploadFile(
    File file,
  );
  Future<Either<Failure, BaseResponse<ResponseUploadImage>>> uploadImage(
    File file,
  );
  Future<Either<Failure, BaseResponse>> addAttachment(
    RequestAddAttachment request,
  );
  Future<Either<Failure, BaseResponse>> removeAttachment(String attachmentId);

  // Get Comment List
  Future<Either<Failure, BaseResponse<List<ResponseComment>>>> getCommentList(
    String module,
    String moduleId,
  );
  Future<Either<Failure, BaseResponse>> addComment(RequestComment request);
  Future<Either<Failure, BaseResponse<List<ResponseComment>>>> getReplyList(
    String parentCommentId,
  );

  Future<Either<Failure, BaseResponse<AuthResponse>>> refreshToken({
    required RefreshTokenModelRequest request,
  });

  // Member
  Future<Either<Failure, BaseResponse<List<ProjectTaskMemberModel>>>>
  getMemberList(
    String projectId,
    String boardId,
    String taskId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  });

  // Organization
  Future<Either<Failure, BaseResponse<List<OrganizationEmployee>>>>
  getOrganization(ListDataRequest request);

  // Employee
  Future<Either<Failure, BaseResponse<EmployeeDetailModel>>>
  getEmployeeDetail();
}
