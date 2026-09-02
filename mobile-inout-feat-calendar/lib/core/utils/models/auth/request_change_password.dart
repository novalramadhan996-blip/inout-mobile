class RequestChangePassword {
  String? oldPassword;
  String? newPassword;

  RequestChangePassword({
    this.oldPassword,
    this.newPassword,
  });

  factory RequestChangePassword.fromJson(Map<String, dynamic> json) {
    return RequestChangePassword(
      oldPassword: json['oldPassword'],
      newPassword: json['newPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}