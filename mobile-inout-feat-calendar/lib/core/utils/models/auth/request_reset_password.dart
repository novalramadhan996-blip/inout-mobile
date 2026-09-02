class RequestResetPassword {
  String? email;
  String? code;

  RequestResetPassword({
    this.email,
    this.code,
  });

  factory RequestResetPassword.fromJson(Map<String, dynamic> json) {
    return RequestResetPassword(
      email: json['email'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}