import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import 'login_view.dart';
import '../organizer/organizer_home.dart';
import '../user/user_home.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    return StreamBuilder<User?>(
      stream: authController.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginView();
        }

        final user = snapshot.data!;
        final usersRef = FirebaseFirestore.instance.collection('users');

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: usersRef.doc(user.uid).get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnap.hasData ||
                userSnap.data == null ||
                !userSnap.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("Profil utilisateur introuvable.")),
              );
            }

            final data = userSnap.data!.data() ?? {};
            final role = data['role'] ?? 'user';

            if (role == 'organizer') {
              return const OrganizerHome();
            }
            return const UserHome();
          },
        );
      },
    );
  }
}
