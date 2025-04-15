import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final List<String> roles;
  final Map<String, dynamic> permissions;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.roles = const [],
    this.permissions = const {},
  });

  bool hasPermission(String permission) {
    return permissions[permission] == true;
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  @override
  List<Object?> get props => [id, email, displayName, roles, permissions];
}