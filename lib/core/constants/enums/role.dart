enum Roles {
  admin,
  user,
  guest,
  superAdmin,
  moderator,
  editor,
  viewer,
  contributor,
  manager,
  developer,
  designer,
  analyst,
  tester,
  architect,
  lead,
  intern,
}

enum Permissions {
  canViewDashboard,
  canManageUsers,
  canCreateContent,
  canEditContent,
  canDeleteContent,
  canViewContent,
  canComment,
  canLike,
  canShare,
  canReport,
}

class Role {
  final String name;
  final List<Permissions> permissions;

  Role(this.name, this.permissions);

  @override
  String toString() {
    return 'Role{name: $name, permissions: $permissions}';
  }
}