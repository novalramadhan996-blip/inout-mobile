class ProfileModel {
  String? username;
  String? email;
  String? phone;
  String? fcm;
  String? status;
  List<String>? roles;
  List<String>? apps;
  bool? enabled;
  List<Authority>? authorities;
  bool? accountNonExpired;
  bool? accountNonLocked;
  bool? credentialsNonExpired;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;
  int? userId;
  String? name;
  String? profileUrl;
  bool? administrator;

  ProfileModel({
    this.username,
    this.email,
    this.phone,
    this.fcm,
    this.status,
    this.roles,
    this.apps,
    this.enabled,
    this.authorities,
    this.accountNonExpired,
    this.accountNonLocked,
    this.credentialsNonExpired,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
    this.userId,
    this.name,
    this.profileUrl,
    this.administrator,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) { 
    return ProfileModel(
        username: json['username'],
        email: json['email'],
        phone: json['phone'],
        fcm: json['fcm'],
        status: json['status'],
        roles: List<String>.from(json['roles']),
        apps: List<String>.from(json['apps']),
        enabled: json['enabled'],
        // authorities: List<Authority>.from(json['authorities']),
        authorities: (json['authorities'] as List)
          .map((item) => Authority.fromJson(item as Map<String, dynamic>))
          .toList(),
        accountNonExpired: json['accountNonExpired'],
        accountNonLocked: json['accountNonLocked'],
        credentialsNonExpired: json['credentialsNonExpired'],
        created: json['created'],
        createdby: json['createdby'],
        updated: json['updated'],
        updatedby: json['updatedby'],
        userId: json['user_id'],
        name: json['name'],
        profileUrl: json['profile_url'],
        administrator: json['administrator']
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'fcm': fcm,
      'status': status,
      'roles': roles,
      'apps': apps,
      'enabled': enabled,
      // 'authorities': authorities,
      'authorities': authorities?.map((item) => item.toJson()).toList(),
      'accountNonExpired': accountNonExpired,
      'accountNonLocked': accountNonLocked,
      'credentialsNonExpired': credentialsNonExpired,
      'created': created,
      'createdby': createdby,
      'updated': updated,
      'updatedby': updatedby,
      'user_id': userId,
      'name': name,
      'profile_url': profileUrl,
      'administrator': administrator,
    };
  }
}

class Authority {
  String? authority;

  Authority({this.authority});

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorities': authority,
    };
  }
}