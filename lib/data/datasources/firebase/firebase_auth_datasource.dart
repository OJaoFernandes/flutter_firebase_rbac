import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../../core/errors/exceptions.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('User not found');
      }
      return await _getUserData(user.uid);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthException('Failed to sign in');
      }
      return await _getUserData(user.uid);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthException('Failed to register');
      }
      
      // Create initial user data with default role
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'roles': ['user'], // Default role
        'permissions': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return await _getUserData(user.uid);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserData(user.uid);
    });
  }

  Future<UserModel> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        // User record doesn't exist in Firestore yet
        final authUser = _firebaseAuth.currentUser;
        if (authUser != null) {
          // Create basic user data
          return UserModel(
            id: uid,
            email: authUser.email ?? '',
            displayName: authUser.displayName,
            roles: ['user'],
            permissions: {},
          );
        }
        throw AuthException('User data not found');
      }
      return UserModel.fromFirebase(doc.data() ?? {}, uid);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}