import 'dart:convert';

class RegisterModel {
  final String? domain;
  final String? username;
  final String? email;
  final String? name;
  final String? password;

  RegisterModel({
    this.domain,
    this.username,
    this.email,
    this.name,
    this.password,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      domain: json['domain'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'username': username,
      'email': email,
      'name': name,
      'password': password,
    };
  }
}
