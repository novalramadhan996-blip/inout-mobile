import 'dart:io';

import 'package:chat/models/filter_list_model_request.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  //My Profile
  @GET('/auth-rest/me')
  Future myProfile();

  //User List
  @POST('/inout-rest/employees/list')
  @Headers({'appsId': ''})
  Future getUserList(@Body() FilterListModelRequest request);
  @GET('/tracker-rest/users/{id}')
  Future getUserData(@Path('id') String id);

  //group list
  // @POST('/inout-rest/projects/list')
  // @Headers({'appsId': ''})
  // Future getGroupList(@Body() FilterListModelRequest request);
  @POST('/inout-rest/organizations/list')
  Future getGroupList(
      @Header('appsId') String appsId, @Body() FilterListModelRequest request);
  @POST('/inout-rest/organization_employee/list')
  Future getGroupMember(@Body() FilterListModelRequest request);
  @GET('/tracker-rest/organizations/{id}')
  Future getGroupData(@Path('id') String id);

  //Upload File
  @POST('/inout-rest/upload/file')
  Future uploadFile(@Part(name: "file") File file);

  //Map
  @GET('/maps/api/directions/json')
  Future getRouteMap({
    @Query('origin') required String origin,
    @Query('destination') required String destination,
    @Query('mode') String? mode = 'driving',
    @Query('key') required String apiKey,
  });
}
