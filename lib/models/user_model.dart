class UserModel {
  const UserModel({
    required this.name,
    required this.username,
    required this.role,
    this.className,
  });

  final String name;
  final String username;
  final String role;
  final String? className;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'] as String,
    username: json['username'] as String,
    role: json['role'] as String,
    className: json['className'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'role': role,
    'className': className,
  };
}
