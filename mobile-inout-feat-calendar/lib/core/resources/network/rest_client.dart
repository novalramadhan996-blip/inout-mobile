import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile_in_out/core/utils/models/auth/auth_response.dart';
import 'package:mobile_in_out/core/utils/models/auth/refresh_token_model_request.dart';
import 'package:mobile_in_out/core/utils/models/auth/request_change_password.dart';
import 'package:mobile_in_out/core/utils/models/auth/request_reset_password.dart';
import 'package:mobile_in_out/core/utils/models/history/absence_history_model.dart';
import 'package:mobile_in_out/core/utils/models/list_data_request.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/home/data/model/employee_detail_model.dart';
import 'package:mobile_in_out/feature/task/model/request_add_attachment.dart';
import 'package:mobile_in_out/feature/task/model/request_comment.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // Auth
  @POST('/inout-rest/auth/login')
  Future doLogin(@Body() Map<String, dynamic> data);

  @POST('/inout-rest/auth/refreshtoken')
  Future refreshToken(@Body() RefreshTokenModelRequest request);

  @POST('/inout-rest/auth/register')
  Future registerAccount(@Body() Map<String, dynamic> data);

  // Verify Account
  @POST('/inout-rest/validate_account')
  Future validateAccount(@Query('username') String username);

  @POST('/inout-rest/auth/registerverification')
  Future validateRegisterCode(@Body() Map<String, dynamic> data);

  // Register Face ID
  // Comment because deprecated, when already stable please removed
  // @POST('/inout-rest/register_faceid')
  // Future registerFaceId(@Body() Map<String, dynamic> data);
  @POST('/inout-rest/auth/register_faceid')
  Future registerFaceId(@Body() Map<String, dynamic> data);

  // Check In & Out
  // Comment because deprecated, when already stable please removed
  // @POST('/inout-rest/absensi/in')
  // Future doIn(@Body() Map<String, dynamic> data);
  // @POST('/inout-rest/absensi/out')
  // Future doOut(@Body() Map<String, dynamic> data);
  @POST('/inout-rest/attendances/in')
  Future doIn(@Body() Map<String, dynamic> data);
  @POST('/inout-rest/attendances/out')
  Future doOut(@Body() Map<String, dynamic> data);

  // Profile
  @GET('/inout-rest/auth/myprofile')
  Future getProfile();

  @PUT('/inout-rest/profile')
  Future updateProfile(@Body() Map<String, dynamic> data);

  // Work Location
  // Comment because deprecated, when already stable please removed
  // @GET('/inout-rest/location')
  // Future getWorkLocation();
  @GET('/inout-rest/locations')
  Future getWorkLocation(@Queries() ListDataRequest request);

  // History
  // Comment because deprecated, when already stable please removed
  // @GET('/inout-rest/absensi/{accountId}/history')
  // Future getHistory(@Path('accountId') String accountId);
  @POST('/inout-rest/attendances/list')
  Future getHistory(@Body() ListDataRequest request);

  // Comment because deprecated, when already stable please removed
  // @GET('/inout-rest/absensi/{absenceId}')
  // Future getDetailHistory(@Path('absenceId') String absenceId);
  @GET('/inout-rest/attendances/{attendanceId}')
  Future getDetailHistory(@Path('attendanceId') String attendanceId);

  // Request Reset Password
  @GET('/inout-rest/auth/requestresetpassword')
  Future requestResetPassword(@Query('email') String email);

  // Change Password
  @POST('/inout-rest/auth/changemypassword')
  Future changePassword(@Body() RequestChangePassword request);

  @POST('/inout-rest/auth/resetpasswordverification')
  Future resetPassword(@Body() RequestResetPassword request);

  // Get Work Schedule
  // Comment because deprecated, when already stable please removed
  // @GET('/inout-rest/account_group_shift/my')
  // Future getMySchedule(@Query('day') int day);
  @POST('/inout-rest/group_shift_schedule/list')
  Future getMySchedule(@Body() ListDataRequest request);

  // Comment because deprecated, when already stable please removed
  // @GET('/inout-rest/account_group_shift/my/group_shift')
  // Future getMyGroupShift(@Query('day') int day);
  @POST('/inout-rest/group_shift_schedule/list')
  Future getMyGroupShift(@Body() ListDataRequest request);

  // Comment because deprecated, when already stable please removed
  // Location Tracking
  // @POST('/inout-rest/location_tracking/insert')
  // Future insertLocationTracking(@Body() Map<String, dynamic> data);
  @POST('/inout-rest/locations')
  Future insertLocationTracking(@Body() Map<String, dynamic> data);

  // Projects List
  // @GET('/inout-rest/projects')
  // Future getProjectList({
  //   @Query('page') required String page,
  //   @Query('limit') required String limit,
  //   @Query('sortby') required String sortby,
  //   @Query('orderby') required String orderby,
  //   @Query('search') String? search = "",
  // });
  @POST('/inout-rest/projects/list')
  Future getProjectList(@Body() ListDataRequest request);

  //Board List
  @GET('/inout-rest/projects/{projectId}/boards')
  Future getBoardList(
    @Path('projectId') String projectId, {
    @Query('page') required String page,
    @Query('limit') required String limit,
    @Query('sortby') required String sortby,
    @Query('orderby') required String orderby,
    @Query('search') String? search = "",
  });

  //Task List
  @GET('/inout-rest/projects/{projectId}/boards/{boardId}/tasks')
  Future getTaskList(
    @Path('projectId') String projectId,
    @Path('boardId') String boardId, {
    @Query('page') required String page,
    @Query('limit') required String limit,
    @Query('sortby') required String sortby,
    @Query('orderby') required String orderby,
    @Query('search') String? search = "",
  });

  @GET(
    '/inout-rest/projects/{projectId}/boards/{boardId}/tasks/{parentTaskId}/items',
  )
  Future getTaskItemList(
    @Path('projectId') String projectId,
    @Path('boardId') String boardId,
    @Path('parentTaskId') String parentTaskId, {
    @Query('page') required String page,
    @Query('limit') required String limit,
    @Query('sortby') required String sortby,
    @Query('orderby') required String orderby,
    @Query('search') String? search = "",
  });

  @PUT(
    '/inout-rest/projects/{projectId}/boards/{boardId}/tasks/{parentTaskId}/items/{taskItemId}',
  )
  Future updateTaskItemList(
    @Path('projectId') String projectId,
    @Path('boardId') String boardId,
    @Path('parentTaskId') String parentTaskId,
    @Path('taskItemId') String taskItemId,
    @Body() Map<String, dynamic> body,
  );

  @GET(
    '/inout-rest/projects/{projectId}/boards/{boardId}/tasks/{parentTaskId}/items/{taskId}',
  )
  Future getDetailTask(
    @Path('projectId') String projectId,
    @Path('boardId') String boardId,
    @Path('parentTaskId') String parentTaskId,
    @Path('taskId') String taskId,
  );

  // attachment
  @GET('/inout-rest/attachment/task/{taskId}')
  Future getAttachmentTaskList(@Path('taskId') String taskId);

  @POST('/inout-rest/upload/file')
  Future uploadFile(@Part() File file);

  @POST('/inout-rest/upload/image')
  Future uploadImage(@Part() File file);

  @POST('/inout-rest/attachment')
  Future addAttachment(@Body() RequestAddAttachment request);

  @DELETE('/inout-rest/attachment/{attachmentId}')
  Future removeAttachment(@Path("attachmentId") String attachmentId);

  // comment
  @GET('/inout-rest/comment/module/{module}/{moduleId}')
  Future getCommentList(
    @Path('module') String module,
    @Path('moduleId') String moduleId,
  );

  @GET('/inout-rest/comment/replies/{parentCommentId}')
  Future getReplyList(@Path('parentCommentId') String parentCommentId);

  @POST('/inout-rest/comment')
  Future addComment(@Body() RequestComment request);

  // Member
  @GET(
    '/inout-rest/projects/{projectId}/boards/{projectBoardId}/tasks/{projectTaskId}/members',
  )
  Future getMemberList(
    @Path('projectId') String projectId,
    @Path('projectBoardId') String projectBoardId,
    @Path('projectTaskId') String projectTaskId, {
    @Query('page') required String page,
    @Query('limit') required String limit,
    @Query('sortby') required String sortby,
    @Query('orderby') required String orderby,
    @Query('search') String? search = "",
  });

  // Organization
  @POST('/inout-rest/organization_employee/list')
  Future getOrganization(@Body() ListDataRequest request);

  // Employee
  @GET('/inout-rest/employees/me')
  Future getEmployeeDetail();
}
