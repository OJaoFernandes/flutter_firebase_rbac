import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/services/rbac_service.dart';
import '../blocs/auth/auth_bloc.dart';

class PermissionGate extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget fallback;
  final RBACService rbacService;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    required this.rbacService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final UserEntity user = state.user;
          if (rbacService.hasPermission(user, permission)) {
            return child;
          }
        }
        return fallback;
      },
    );
  }
}
