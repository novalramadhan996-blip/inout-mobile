class AuthModel {
  String? token;
  String? refreshToken;
  int? expiresIn;

  AuthModel({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) { 
    return AuthModel(
        token: json['token'],
        refreshToken: json['refreshToken'],
        expiresIn: json['expiresIn'],
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}
