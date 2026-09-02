import 'package:chat/core/resources/constants/app_constants.dart';
import 'package:chat/core/resources/network/rest_client.dart';
import 'package:chat/core/utils/base_response_custom.dart';
import 'package:chat/core/utils/failure.dart';
import 'package:chat/core/utils/response_helper.dart';
import 'package:chat/repositories/repository_interface_google_map.dart';
import 'package:dartz/dartz.dart';

class RepositoryGoogleMap extends RepositoryInterfaceGoogleMap {
  final RestClient restClient;

  RepositoryGoogleMap({required this.restClient});

  @override
  Future<Either<Failure, BaseResponseCustom<Map<String, dynamic>>>> getRouteMap(
      String origin, String destination,
      {String? mode}) async {
    Object response = await ResponseHelper.getResponse(
        () async => await restClient.getRouteMap(
              origin: origin,
              destination: destination,
              mode: mode,
              apiKey: AppConstants.googleAPiKey,
            ));

    if (response is Failure) return Left(response);

    // log('response $response');

    return Right(BaseResponseCustom(
      response: response as Map<String, dynamic>,
      errorMessage: null,
      status: true,
    ));
  }
}
