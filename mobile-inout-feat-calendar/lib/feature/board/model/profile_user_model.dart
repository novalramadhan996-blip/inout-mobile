class ProfileUserModel {
  String? imgUrl;
  String? userName;

  ProfileUserModel({
    this.imgUrl,
    this.userName,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) { 
    return ProfileUserModel(
        imgUrl: json['image_profile'],
        userName: json['name_user'],
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_profile': imgUrl,
      'name_user': userName,
    };
  }
}