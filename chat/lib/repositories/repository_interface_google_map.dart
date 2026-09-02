import 'package:chat/core/utils/base_response_custom.dart';
import 'package:chat/core/utils/failure.dart';
import 'package:dartz/dartz.dart';

abstract class RepositoryInterfaceGoogleMap {
  Future<Either<Failure, BaseResponseCustom<Map<String, dynamic>>>> getRouteMap(
      String origin, String destination,
      {String? mode});
}
