import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
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
          return const AppScaffold(
            title: 'DEVMOB',
            centerContent: true,
            child: CircularProgressIndicator(),
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
              return const AppScaffold(
                title: 'DEVMOB',
                centerContent: true,
                child: CircularProgressIndicator(),
              );
            }

            if (!userSnap.hasData ||
                userSnap.data == null ||
                !userSnap.data!.exists) {
              return AppScaffold(
                title: 'Profil introuvable',
                centerContent: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profil utilisateur introuvable.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deconnectez-vous puis reconnectez-vous, ou creez un nouveau compte.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Deconnexion',
                      icon: Icons.logout,
                      onPressed: () => authController.logout(),
                    ),
                  ],
                ),
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
