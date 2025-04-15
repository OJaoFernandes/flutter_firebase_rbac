import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Get the currently authenticated user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
      String email, String password);

  /// Register with email and password
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword(
      String email, String password);

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}