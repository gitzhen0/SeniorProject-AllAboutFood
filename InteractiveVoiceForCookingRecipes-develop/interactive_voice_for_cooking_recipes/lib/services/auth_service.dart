import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  User? get firebaseUser => _firebaseAuth.currentUser;

  final Logger _logger = GetIt.I<Logger>();

  /// Checks if a user is authenticated, if they are, their identity ID and policies
  /// are validate, which could throw and exception
  Future<List<User?>> checkAuth() async {
    // Make sure FirebaseAuth is initialized
    await _firebaseAuth.authStateChanges().first;
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      //final bool verified = await checkEmailVerified();
      // if (!verified) {
      //   return null;
      // }
      return [];
    }

    return <User?>[user];
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      result.user?.updateDisplayName(name);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }

    return _firebaseAuth.currentUser;
  }

  Future<User?> signInGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider
          .addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return _firebaseAuth.currentUser;
  }

  void signOut() {
    _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendVerificationEmail() async {
    await firebaseUser?.sendEmailVerification();
  }

  Future<String?> trySendVerificationEmail() async {
    try {
      await sendVerificationEmail();
      return null;
    } on FirebaseAuthException catch (e, st) {
      _logger.e('Error sending verification', e, st);
      return e.message;
    } catch (e, st) {
      _logger.e('Unexpected error sending verification email', e, st);
      return 'Failed to send verification email from an unexpected error';
    }
  }

  Future<bool> checkEmailVerified() async {
    await firebaseUser?.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified == true;
  }

  Future<void> updateAuthDisplayName(String? name) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    return _firebaseAuth.currentUser?.updateDisplayName(name);
  }

  Future<void> deleteUser() async {
    await firebaseUser?.delete();
  }

  Future<String> getAuthToken() async {
    String token;
    try {
      token = await _firebaseAuth.currentUser?.getIdToken() ?? 'nologon';
    } catch (e) {
      token = 'nologon';
    }
    return token;
  }
}
