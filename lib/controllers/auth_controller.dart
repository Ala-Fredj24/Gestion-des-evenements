import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

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
    String displayName = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final userProfile = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: role,
      );

      await _firestore.collection('users').doc(userProfile.uid).set({
        ...userProfile.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e);
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!, doc.id);
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
