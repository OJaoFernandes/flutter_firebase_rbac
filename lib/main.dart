import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data/datasources/firebase/firebase_auth_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user.dart';
import 'domain/usecases/sign_in_email_password.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up_email_password.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => _createAuthBloc()..add(const CheckAuthStatus()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Auth RBAC',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }

  AuthBloc _createAuthBloc() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Data sources
    final FirebaseAuthDataSource authDataSource = FirebaseAuthDataSourceImpl(
      firebaseAuth: firebaseAuth,
      firestore: firestore,
    );
    
    // Repositories
    final AuthRepository authRepository = AuthRepositoryImpl(authDataSource);
    
    // Use cases
    final GetCurrentUser getCurrentUser = GetCurrentUser(authRepository);
    final SignInWithEmailAndPassword signIn = SignInWithEmailAndPassword(authRepository);
    final SignUpWithEmailAndPassword signUp = SignUpWithEmailAndPassword(authRepository);
    final SignOut signOut = SignOut(authRepository);
    
    return AuthBloc(
      getCurrentUser: getCurrentUser,
      signIn: signIn,
      signUp: signUp,
      signOut: signOut,
      authRepository: authRepository,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomePage();
        }
        if (state is Unauthenticated) {
          return const LoginPage();
        }
        // Initial, loading, or error states
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}