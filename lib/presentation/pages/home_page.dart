import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${user.displayName ?? user.email}!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Email: ${user.email}'),
                  const SizedBox(height: 8),
                  Text('User ID: ${user.id}'),
                  const SizedBox(height: 16),
                  const Text('Roles:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...user.roles.map((role) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text('• $role'),
                      )),
                  const SizedBox(height: 16),
                  if (user.hasRole('admin'))
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to admin panel
                      },
                      child: const Text('Admin Panel'),
                    ),
                  if (user.hasPermission('can_create_content'))
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to content creation
                      },
                      child: const Text('Create Content'),
                    ),
                ],
              ),
            ),
          );
        }
        // Loading or other states
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}