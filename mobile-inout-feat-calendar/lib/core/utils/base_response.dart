class BaseResponse<T> {
  num? statusCode;
  String? errorMessage;
  bool? status;
  T? response;

  BaseResponse({
    this.statusCode,
    this.errorMessage,
    this.status,
    this.response,
  });
}
