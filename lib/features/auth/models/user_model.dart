class UserModel {
  final String accessToken;

  UserModel({required this.accessToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['accessToken'],
    );
  }
}