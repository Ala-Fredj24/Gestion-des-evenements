import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

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
      return getErrorMessage(e);
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouve avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return "L'email n'est pas valide.";
      case 'email-already-in-use':
        return 'Cet email est deja utilise.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'user-disabled':
        return 'Ce compte est desactive.';
      default:
        return 'Erreur : ${e.message}';
    }
  }
}
