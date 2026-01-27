class UserModel {
  final String name;
  final String level;
  final String avatar;
  final String? email;

  UserModel({
    required this.name,
    required this.level,
    required this.avatar,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      avatar: json['avatar'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'avatar': avatar,
      'email': email,
    };
  }
}
