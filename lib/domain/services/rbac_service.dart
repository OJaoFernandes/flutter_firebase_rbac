import '../entities/user_entity.dart';

class RBACService {
  // Define role-permission mapping
  final Map<String, List<String>> _rolePermissions = {
    'admin': [
      'can_view_dashboard',
      'can_manage_users',
      'can_create_content',
      'can_edit_content',
      'can_delete_content',
    ],
    'editor': [
      'can_create_content',
      'can_edit_content',
    ],
    'viewer': [
      'can_view_content',
    ],
    'user': [
      'can_view_content',
    ],
  };

  // Check if user has permission
  bool hasPermission(UserEntity user, String permission) {
    // Direct permission check
    if (user.hasPermission(permission)) {
      return true;
    }

    // Check through roles
    for (final role in user.roles) {
      final permissions = _rolePermissions[role] ?? [];
      if (permissions.contains(permission)) {
        return true;
      }
    }

    return false;
  }

  // Get all permissions for a user based on their roles
  List<String> getAllPermissions(UserEntity user) {
    final Set<String> permissions = {};
    
    // Add direct permissions
    permissions.addAll(user.permissions.keys.where(
      (key) => user.permissions[key] == true
    ));
    
    // Add role-based permissions
    for (final role in user.roles) {
      final rolePermissions = _rolePermissions[role] ?? [];
      permissions.addAll(rolePermissions);
    }
    
    return permissions.toList();
  }
}