class AuthResponse {
  final String? token;
  final String? refreshToken;
  final int? expiresIn;
  final String? appsId;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    this.appsId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
      appsId: json['appsId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'appsId': appsId,
  };
}
