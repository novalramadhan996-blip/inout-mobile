class ValidateAccountResponse {
  final String accountId;
  final String username;
  final String displayName;
  final String email;
  final int status;

  ValidateAccountResponse({
    required this.accountId,
    required this.username,
    required this.displayName,
    required this.email,
    required this.status,
  });

  factory ValidateAccountResponse.fromJson(Map<String, dynamic> json) {
    return ValidateAccountResponse(
      accountId: json['account_id'],
      username: json['username'],
      displayName: json['display_name'],
      email: json['email'],
      status: json['status'],
    );
  }
}