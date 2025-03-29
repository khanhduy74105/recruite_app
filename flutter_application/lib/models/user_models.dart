enum UserRole { admin, user, recruiter }

UserRole userRoleFromString(String role) {
  switch (role) {
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    case 'recruiter':
      return UserRole.recruiter;
    default:
      throw Exception('Unknown user role: $role');
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.user:
      return 'user';
    case UserRole.recruiter:
      return 'recruiter';
  }
}
class UserModel {
  final String id;
  final String? resume;
  final String email;
  final DateTime? createdAt;
  final String? phone;
  final String? bio;
  final UserRole? role;
  final String? headline;
  final String? location;
  final String? avatarUrl;
  final String fullName;

  UserModel({
    required this.id,
    this.resume,
    required this.email,
    this.createdAt,
    this.phone,
    this.bio,
    this.role,
    this.headline,
    this.location,
    this.avatarUrl,
    required this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      resume: json['resume'],
      email: json['email'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      phone: json['phone'],
      bio: json['bio'],
      role: json['role'] != null ? userRoleFromString(json['role']) : null,
      headline: json['headline'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resume': resume,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'phone': phone,
      'bio': bio,
      'role': role != null ? userRoleToString(role!) : null,
      'headline': headline,
      'location': location,
      'avatar_url': avatarUrl,
      'full_name': fullName,
    };
  }
}
