class ProfileModel {
  final String? username;
  final String? email;
  final String? phone;
  final String? fcm;
  final String? status;
  final String? scope;
  final DateTime? lastLogin;
  final int? loginAttempts;
  final String? loginAccess;
  final List<String>? roles;
  final List<String>? apps;
  final String? appsId;
  final bool? enabled;
  final List<String>? authorities;
  final bool? accountNonExpired;
  final bool? accountNonLocked;
  final bool? credentialsNonExpired;
  final String? userId;
  final String? name;
  final String? profileUrl;
  final bool? administrator;
  final String? modelData;

  ProfileModel({
    this.username,
    this.email,
    this.phone,
    this.fcm,
    this.status,
    this.scope,
    this.lastLogin,
    this.loginAttempts,
    this.loginAccess,
    this.roles,
    this.apps,
    this.appsId,
    this.enabled,
    this.authorities,
    this.accountNonExpired,
    this.accountNonLocked,
    this.credentialsNonExpired,
    this.userId,
    this.name,
    this.profileUrl,
    this.administrator,
    this.modelData,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fcm: json['fcm'],
      status: json['status'],
      scope: json['scope'],
      lastLogin: json['lastlogin'] != null
          ? DateTime.tryParse(json['lastlogin'])
          : null,
      loginAttempts: json['loginattempts'] ?? 0,
      loginAccess: json['loginaccess'],
      roles: List<String>.from(json['roles'] ?? []),
      apps: List<String>.from(json['apps'] ?? []),
      appsId: json['appsId'] ?? '',
      enabled: json['enabled'] ?? false,
      authorities: List<String>.from(json['authorities'] ?? []),
      accountNonExpired: json['accountNonExpired'] ?? true,
      accountNonLocked: json['accountNonLocked'] ?? true,
      credentialsNonExpired: json['credentialsNonExpired'] ?? true,
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      profileUrl: json['profile_url'],
      administrator: json['administrator'],
      modelData: json['model_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'fcm': fcm,
      'status': status,
      'scope': scope,
      'lastlogin': lastLogin?.toIso8601String(),
      'loginattempts': loginAttempts,
      'loginaccess': loginAccess,
      'roles': roles,
      'apps': apps,
      'appsId': appsId,
      'enabled': enabled,
      'authorities': authorities,
      'accountNonExpired': accountNonExpired,
      'accountNonLocked': accountNonLocked,
      'credentialsNonExpired': credentialsNonExpired,
      'user_id': userId,
      'name': name,
      'profile_url': profileUrl,
      'administrator': administrator,
      'model_data': modelData,
    };
  }
}
