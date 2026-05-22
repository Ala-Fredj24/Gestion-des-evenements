import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthController {
  static const String userRole = 'user';
  static const String organizerRole = 'organizer';
  static const Duration _authTimeout = Duration(seconds: 20);
  static const Duration _firestoreTimeout = Duration(seconds: 15);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String normalizeRole(String role) {
    final cleanedRole = role.trim().toLowerCase();
    if (cleanedRole == organizerRole) {
      return organizerRole;
    }
    return userRole;
  }

  bool isValidRole(String role) {
    final cleanedRole = role.trim().toLowerCase();
    return cleanedRole == userRole || cleanedRole == organizerRole;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _signIn(email: email, password: password);
      return null;
    } on TimeoutException {
      return 'Connexion impossible. Verifiez Firebase, Internet ou relancez l application.';
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e);
    } on FirebaseException catch (e) {
      return getFirebaseErrorMessage(e);
    } catch (_) {
      return 'Connexion impossible. Reessayez plus tard.';
    }
  }

  Future<String?> restoreProfileForExistingAuthUser({
    required String email,
    required String password,
    required String role,
    required String displayName,
  }) async {
    try {
      final cred = await _signIn(email: email, password: password);

      final cleanedDisplayName = displayName.trim();
      if (cleanedDisplayName.isNotEmpty) {
        await cred.user!.updateDisplayName(cleanedDisplayName);
      }
      await cred.user!.reload();

      final userProfile = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: cleanedDisplayName,
        role: normalizeRole(role),
      );

      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .set({
            ...userProfile.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
            'restoredAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(_firestoreTimeout);

      return null;
    } on TimeoutException {
      return 'Operation impossible. Verifiez Firebase, Internet ou relancez l application.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Cet email existe deja dans Firebase Authentication. Connectez-vous avec son mot de passe ou supprimez aussi le compte dans Authentication.';
      }
      return getErrorMessage(e);
    } on FirebaseException catch (e) {
      return getFirebaseErrorMessage(e);
    } catch (_) {
      return 'Impossible de restaurer ce profil. Reessayez plus tard.';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String role,
    String displayName = '',
  }) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(_authTimeout);
      final cleanedDisplayName = displayName.trim();
      if (cleanedDisplayName.isNotEmpty) {
        await cred.user!.updateDisplayName(cleanedDisplayName);
      }
      await cred.user!.reload();

      final userProfile = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: cleanedDisplayName,
        role: normalizeRole(role),
      );

      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .set({
            ...userProfile.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(_firestoreTimeout);

      return null;
    } on TimeoutException {
      return 'Operation impossible. Verifiez Firebase, Internet ou relancez l application.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return restoreProfileForExistingAuthUser(
          email: email,
          password: password,
          role: role,
          displayName: displayName,
        );
      }
      return getErrorMessage(e);
    } on FirebaseException catch (e) {
      return getFirebaseErrorMessage(e);
    } catch (_) {
      return 'Inscription impossible. Reessayez plus tard.';
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final currentUser = user;
    if (currentUser == null) {
      return null;
    }

    return getUserProfile(currentUser.uid);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(_firestoreTimeout);

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserCredential> _signIn({
    required String email,
    required String password,
  }) {
    return _auth
        .signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        )
        .timeout(_authTimeout);
  }

  Future<bool> currentUserHasRole(String role) async {
    final profile = await getCurrentUserProfile();
    if (profile == null) {
      return false;
    }

    return profile.role == normalizeRole(role);
  }

  Future<bool> isCurrentUserOrganizer() => currentUserHasRole(organizerRole);

  Future<bool> isCurrentUser() => currentUserHasRole(userRole);

  Future<void> logout() async {
    await _auth.signOut();
  }

  String getFirebaseErrorMessage(FirebaseException e) {
    if (e.code == 'unavailable') {
      return 'Service indisponible. Verifiez votre connexion Internet.';
    }
    if (e.code == 'permission-denied') {
      return 'Acces refuse. Verifiez les permissions Firebase.';
    }
    return 'Erreur Firebase : ${e.message ?? e.code}';
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouve avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'invalid-email':
        return "L'email n'est pas valide.";
      case 'email-already-in-use':
        return 'Cet email est deja utilise.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'user-disabled':
        return 'Ce compte est desactive.';
      case 'network-request-failed':
        return 'Connexion reseau impossible. Verifiez Internet puis reessayez.';
      default:
        return 'Erreur : ${e.message}';
    }
  }
}
