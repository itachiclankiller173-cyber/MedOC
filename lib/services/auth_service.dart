import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print("✅ Registration Successful");
      return null;
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Code: ${e.code}");
      print("❌ Firebase Message: ${e.message}");
      return "${e.code}: ${e.message}";
    } catch (e) {
      print("❌ Unknown Error: $e");
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      print("❌ Login Code: ${e.code}");
      print("❌ Login Message: ${e.message}");
      return "${e.code}: ${e.message}";
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return "${e.code}: ${e.message}";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
