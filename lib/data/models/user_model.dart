import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.roles = const [],
    super.permissions = const {},
  });

  factory UserModel.fromFirebase(Map<String, dynamic> userData, String uid) {
    return UserModel(
      id: uid,
      email: userData['email'] ?? '',
      displayName: userData['displayName'],
      roles: List<String>.from(userData['roles'] ?? []),
      permissions: userData['permissions'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'roles': roles,
      'permissions': permissions,
    };
  }
}