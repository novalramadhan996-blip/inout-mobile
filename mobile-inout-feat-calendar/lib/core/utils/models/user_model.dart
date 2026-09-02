import 'dart:convert';

class UserModel {
  String user;
  String password;
  List modelData;

  UserModel({
    required this.user,
    required this.password,
    required this.modelData,
  });

  static UserModel fromJson(Map<String, dynamic> user) {
    return UserModel(
      user: user['user'],
      password: user['password'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toJson() {
    return {
      'user': user,
      'password': password,
      'model_data': jsonEncode(modelData),
    };
  }
}