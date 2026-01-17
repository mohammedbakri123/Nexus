class UserModel {
  final int? userId;
  final String username;
  final String email;
  final String password;
  final int level;

  UserModel({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'password': password,
      'level': level,
    };
  }
}
