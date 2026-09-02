class AuthModelRequest {
  String? username;
  String? password;

  AuthModelRequest({
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}