class RefreshTokenModelRequest {
  String? refreshToken;

  RefreshTokenModelRequest({
    this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}