class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final String? profileImage;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.profileImage,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      username: json['username'],
      profileImage: json['profileImage'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'profileImage': profileImage,
      'role': role,
    };
  }
}