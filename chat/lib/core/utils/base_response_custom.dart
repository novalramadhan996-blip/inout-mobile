class BaseResponseCustom<T> {
  num? statusCode;
  String? errorMessage;
  bool? status;
  T? response;

  BaseResponseCustom({
    this.statusCode,
    this.errorMessage,
    this.status,
    this.response,
  });
}
