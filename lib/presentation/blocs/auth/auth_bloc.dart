import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/get_current_user.dart';
import '../../../../domain/usecases/sign_in_email_password.dart';
import '../../../../domain/usecases/sign_out.dart';
import '../../../../domain/usecases/sign_up_email_password.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../domain/entities/user_entity.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignInWithEmailAndPassword signIn;
  final SignUpWithEmailAndPassword signUp;
  final SignOut signOut;
  final AuthRepository authRepository;
  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required this.getCurrentUser,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    // Listen to auth state changes from Firebase
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(const CheckAuthStatus());
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signIn(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signOut(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}