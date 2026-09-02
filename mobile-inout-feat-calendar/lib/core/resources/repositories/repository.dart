import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_in_out/core/resources/network/rest_client.dart';
import 'package:mobile_in_out/core/resources/repositories/interface.dart';
import 'package:mobile_in_out/core/utils/base_response.dart';
import 'package:mobile_in_out/core/utils/errors/error_helper.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
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
import 'package:mobile_in_out/core/utils/response_helper.dart';
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

class Repository extends RepositoryInterface {
  final RestClient restClient;

  Repository({required this.restClient});

  @override
  Future<Either<Failure, BaseResponse<CheckInResponseModel>>> checkIn({
    required Map<String, dynamic> data,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.doIn(data),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(
        response: CheckInResponseModel.fromJson(
          (response as Map<String, dynamic>)['data'],
        ),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<CheckOutResponseModel>>> checkOut({
    required Map<String, dynamic> data,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.doOut(data),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(
        response: CheckOutResponseModel.fromJson(
          (response as Map<String, dynamic>)['data'],
        ),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<ProfileModel>>> getProfile({
    required String userId,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getProfile(),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final responseMap = response as Map<String, dynamic>;
      if (responseMap.isEmpty) {
        return const Left(ServerFailure('Data not found'));
      }
      return Right(
        BaseResponse(
          response: ProfileModel.fromJson(responseMap),
          errorMessage: null,
          status: true,
        ),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<RegisterModel>>> register(
    Map<String, dynamic> data,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.registerAccount(data),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final responseMap = response as Map<String, dynamic>;
      if (responseMap['data'] == null) {
        return const Left(ServerFailure('Data not found'));
      }

      return Right(
        BaseResponse(
          response: RegisterModel.fromJson(responseMap['data']),
          errorMessage: null,
          status: true,
        ),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<ProfileModel>>> updateProfile({
    // required String accountId,
    required Map<String, dynamic> data,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.updateProfile(data),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(
        response: ProfileModel.fromJson(
          (response as Map<String, dynamic>)['data'],
        ),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<LocationResponse>>> getWorkLocation({
    required ListDataRequest request,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getWorkLocation(request),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(
        response: LocationResponse.fromJson((response as Map<String, dynamic>)),
        errorMessage: null,
        status: true,
      ),
    );
  }

  // Comment because deprecated, when already stable please removed
  // @override
  // Future<Either<Failure, BaseResponse<List<AbsenceRecord>>>> getHistory({required String accountId}) async {
  //   Object response = await ResponseHelper.getResponse(() async => await restClient.getHistory(accountId));

  //   if (response is Failure) return Left(response);

  //   if (response is! String) {
  //     final dataList = (response as Map<String, dynamic>)['rows'] as List?;
  //     return Right(BaseResponse(
  //       response: dataList != null ? dataList.map((e) => AbsenceRecord.fromJson(e)).toList() : [],
  //       errorMessage: null,
  //       status: true,
  //     ));
  //   } else {
  //     return Left(ServerFailure(response.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, BaseResponse<List<AbsenceHistoryModel>>>> getHistory({
    required ListDataRequest request,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getHistory(request),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final dataList = (response as Map<String, dynamic>)['rows'] as List?;
      return Right(
        BaseResponse(
          response: dataList != null
              ? dataList.map((e) => AbsenceHistoryModel.fromJson(e)).toList()
              : [],
          errorMessage: null,
          status: true,
        ),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<bool>>> registerFaceId({
    required Map<String, dynamic> data,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.registerFaceId(data),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: true, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<ValidateAccountResponse>>>
  validateAccount({required String username}) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.validateAccount(username),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final responseMap = response as Map<String, dynamic>;
      if (responseMap['data'] == null) {
        return const Left(ServerFailure('Data not found'));
      }

      return Right(
        BaseResponse(
          response: ValidateAccountResponse.fromJson(responseMap['data']),
          errorMessage: null,
          status: true,
        ),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<bool>>> validateRegisterCode({
    required Map<String, dynamic> data,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.validateRegisterCode(data),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final responseMap = response as Map<String, dynamic>;
      if (responseMap['rmessage'] == 'Invalid Code') {
        return const Left(ServerFailure('OTP Invalid'));
      }

      return Right(
        BaseResponse(response: true, errorMessage: null, status: true),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  // Comment because deprecated, when already stable please removed
  // @override
  // Future<Either<Failure, BaseResponse<AbsenceRecordDetail>>> getDetailHistory({required String absenceId}) async {
  //   Object response = await ResponseHelper.getResponse(() async => await restClient.getDetailHistory(absenceId));

  //   if (response is Failure) return Left(response);

  //   return Right(BaseResponse(
  //     response: AbsenceRecordDetail.fromJson((response as Map<String, dynamic>)['data']),
  //     errorMessage: null,
  //     status: true,
  //   ));
  // }
  @override
  Future<Either<Failure, BaseResponse<AbsenceHistoryModel>>> getDetailHistory({
    required String attendanceId,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getDetailHistory(attendanceId),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final data = (response as Map<String, dynamic>)['data'];
      return Right(
        BaseResponse(
          response: data != null
              ? AbsenceHistoryModel.fromJson(data)
              : AbsenceHistoryModel(),
          errorMessage: null,
          status: true,
        ),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<bool>>> requestResetPassword({
    required String email,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.requestResetPassword(email),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: true, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<bool>>> resetPassword({
    required RequestResetPassword request,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.resetPassword(request),
    );

    if (response is Failure) return Left(response);

    if (response is Map<String, dynamic>) {
      if (response['rmessage'] ==
          'Failed reset password, invalid verification code or username') {
        return const Left(ServerFailure('OTP Invalid'));
      }
    }

    return Right(
      BaseResponse(response: true, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<bool>>> changePassword({
    required RequestChangePassword request,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.changePassword(request),
    );

    if (response is Failure) return Left(response);
    if (response is Map<String, dynamic>) {
      if (response['rmessage'] == 'Invalid old password') {
        return const Left(ServerFailure('Invalid old password!'));
      }
    }

    return Right(
      BaseResponse(response: true, errorMessage: null, status: true),
    );
  }

  // Comment because deprecated, when already stable please removed
  // @override
  // Future<Either<Failure, BaseResponse<ScheduleModel>>> getMySchedule(int day) async {
  //   Object response = await ResponseHelper.getResponse(() async => await restClient.getMySchedule(day));

  //   if (response is Failure) return Left(response);

  //   if (response is! String) {
  //     return Right(BaseResponse(
  //       response: ScheduleModel.fromJson((response as Map<String, dynamic>)['data']),
  //       errorMessage: null,
  //       status: true,
  //     ));
  //   } else {
  //     return Left(ServerFailure(response.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, BaseResponse<GroupShiftScheduleResponse>>>
  getMySchedule(ListDataRequest request) async {
    final response = await ResponseHelper.getResponse(
      () async => await restClient.getMySchedule(request),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;
    final rows = responseMap['rows'];

    if (rows == null || rows is! List || rows.isEmpty) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: GroupShiftScheduleResponse.fromJson(
          rows.first as Map<String, dynamic>,
        ),
        errorMessage: null,
        status: true,
      ),
    );
  }

  // Comment because deprecated, when already stable please removed
  // @override
  // Future<Either<Failure, BaseResponse<List<GroupShiftModel>>>> getMyGroupShift(int day) async {
  //   Object response = await ResponseHelper.getResponse(() async => await restClient.getMyGroupShift(day));

  //   if (response is Failure) return Left(response);

  //   if (response is! String) {
  //     final responseMap = response as Map<String, dynamic>;
  //     return Right(BaseResponse(
  //       response: (responseMap['rows'] as List).map((e) => GroupShiftModel.fromJson(e)).toList(),
  //       errorMessage: null,
  //       status: true,
  //     ));
  //   } else {
  //     return Left(ServerFailure(response.toString()));
  //   }

  //   // final responseMap = response as Map<String, dynamic>;

  //   // if (responseMap['rows'] == null) {
  //   //   return const Left(ServerFailure('Data not found'));
  //   // }

  //   // return Right(BaseResponse(
  //   //   response: (responseMap['rows'] as List).map((e) => GroupShiftModel.fromJson(e)).toList(),
  //   //   errorMessage: null,
  //   //   status: true,
  //   // ));
  // }

  @override
  Future<Either<Failure, BaseResponse<List<GroupShiftScheduleResponse>>>>
  getMyGroupShift(ListDataRequest request) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getMyGroupShift(request),
    );

    if (response is Failure) return Left(response);

    if (response is! String) {
      final responseMap = response as Map<String, dynamic>;

      final rows = responseMap['rows'];

      if (rows == null || rows is! List || rows.isEmpty) {
        return const Left(ServerFailure("Data not found"));
      }

      return Right(
        BaseResponse(
          response: rows
              .map((e) => GroupShiftScheduleResponse.fromJson(e))
              .toList(),
          errorMessage: null,
          status: true,
        ),
      );
    } else {
      return Left(ServerFailure(response.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<bool>>> locationTracking({
    required Map<String, dynamic> data,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.insertLocationTracking(data),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: true, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<ResponseProject>>>> getProjectList(
    ListDataRequest request,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getProjectList(request),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['rows'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['rows'] as List)
            .map((e) => ResponseProject.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<ResponseBoard>>>>
  getProjectBoardList(
    String projectId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getBoardList(
        projectId,
        page: page,
        limit: limit,
        sortby: sortby,
        orderby: orderby,
        search: search,
      ),
    );

    // for testing dummy data
    // final jsonString = await rootBundle.loadString('assets/dummy/dummy_boarding_data.json');
    // Object response = json.decode(jsonString);

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['rows'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['rows'] as List)
            .map((e) => ResponseBoard.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<ResponseTask>>>> getProjectTaskList(
    String projectId,
    String boardId,
    String page,
    String limit,
    String sortby,
    String orderby, {
    String? search,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getTaskList(
        projectId,
        boardId,
        page: page,
        limit: limit,
        sortby: sortby,
        orderby: orderby,
        search: search,
      ),
    );

    // for testing dummy data
    // final jsonString = await rootBundle.loadString('assets/dummy/dummy_child_boarding_data.json');
    // Object response = json.decode(jsonString);

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['rows'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['rows'] as List)
            .map((e) => ResponseTask.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
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
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getTaskItemList(
        projectId,
        boardId,
        taskId,
        page: page,
        limit: limit,
        sortby: sortby,
        orderby: orderby,
        search: search,
      ),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['rows'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['rows'] as List)
            .map((e) => ResponseTaskItem.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<ResponseAttachment>>>>
  getAttachmentList(String taskId) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getAttachmentTaskList(taskId),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['data'] as List)
            .map((e) => ResponseAttachment.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<ResponseComment>>>> getCommentList(
    String module,
    String moduleId,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getCommentList(module, moduleId),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['data'] as List)
            .map((e) => ResponseComment.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<ResponseComment>>>> getReplyList(
    String parentCommentId,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getReplyList(parentCommentId),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['data'] as List)
            .map((e) => ResponseComment.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse>> updateProjectTaskItemList(
    String projectId,
    String boardId,
    String taskId,
    String taskItemId,
    bool checked,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.updateTaskItemList(
        projectId,
        boardId,
        taskId,
        taskItemId,
        {'checked': checked},
      ),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: response, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse>> addComment(
    RequestComment request,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.addComment(request),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: response, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<ResponseUploadFile>>> uploadFile(
    File file,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.uploadFile(file),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: ResponseUploadFile.fromJson(responseMap['data']),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<ResponseUploadImage>>> uploadImage(
    File file,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.uploadImage(file),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: ResponseUploadImage.fromJson(responseMap['data']),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse>> addAttachment(
    RequestAddAttachment request,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.addAttachment(request),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: response, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse>> removeAttachment(
    String attachmentId,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.removeAttachment(attachmentId),
    );

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(response: response, errorMessage: null, status: true),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<AuthResponse>>> login({
    required String userName,
    required String password,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.doLogin({
        "username": userName,
        "password": password,
        // deprecated since update new end point
        // "domain": dotenv.get("DOMAIN", fallback: ""),
      }),
    );

    LogHelper.logDebug('response $response');

    if (response is Failure) return Left(response);

    return Right(
      BaseResponse(
        // response: response as AuthResponse,
        response: AuthResponse.fromJson((response as Map<String, dynamic>)),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<AuthResponse>>> refreshToken({
    required RefreshTokenModelRequest request,
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.refreshToken(request),
    );

    if (response is Failure) return Left(response);

    LogHelper.logDebug('response $response');

    return Right(
      BaseResponse(
        response: AuthResponse.fromJson((response as Map<String, dynamic>)),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
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
  }) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getMemberList(
        projectId,
        boardId,
        taskId,
        page: page,
        limit: limit,
        sortby: sortby,
        orderby: orderby,
        search: search,
      ),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['rows'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: (responseMap['rows'] as List)
            .map((e) => ProjectTaskMemberModel.fromJson(e))
            .toList(),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<ResponseTaskItem>>> getDetailTask(
    String projectId,
    String boardId,
    String parentTaskId,
    String taskId,
  ) async {
    Object response = await ResponseHelper.getResponse(
      () async => await restClient.getDetailTask(
        projectId,
        boardId,
        parentTaskId,
        taskId,
      ),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: ResponseTaskItem.fromJson(responseMap['data']),
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<List<OrganizationEmployee>>>>
  getOrganization(ListDataRequest request) async {
    final response = await ResponseHelper.getResponse(
      () async => await restClient.getOrganization(request),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    if (responseMap['rows'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    final List<OrganizationEmployee> data = (responseMap['rows'] as List)
        .map((e) => OrganizationEmployee.fromJson(e))
        .toList();

    return Right(
      BaseResponse<List<OrganizationEmployee>>(
        response: data,
        errorMessage: null,
        status: true,
      ),
    );
  }

  @override
  Future<Either<Failure, BaseResponse<EmployeeDetailModel>>>
  getEmployeeDetail() async {
    final response = await ResponseHelper.getResponse(
      () async => await restClient.getEmployeeDetail(),
    );

    if (response is Failure) return Left(response);

    final responseMap = response as Map<String, dynamic>;

    LogHelper.logDebug('employee responseMap $responseMap');

    if (responseMap['data'] == null) {
      return const Left(ServerFailure('Data not found'));
    }

    return Right(
      BaseResponse(
        response: EmployeeDetailModel.fromJson(responseMap['data']),
        errorMessage: null,
        status: true,
      ),
    );
  }
}
