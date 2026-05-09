import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
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
            title: 'Gestion des evenements',
            centerContent: true,
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return const LoginView();
        }

        final user = snapshot.data!;

        return FutureBuilder<UserModel?>(
          future: authController.getUserProfile(user.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _AuthStateView.loading();
            }

            if (userSnap.hasError) {
              return _AuthStateView(
                title: 'Erreur de chargement',
                icon: Icons.cloud_off_outlined,
                message:
                    'Impossible de charger votre profil. Verifiez votre connexion puis reessayez.',
                actionLabel: 'Deconnexion',
                actionIcon: Icons.logout,
                onActionPressed: authController.logout,
              );
            }

            final profile = userSnap.data;
            if (profile == null) {
              return _AuthStateView(
                title: 'Profil introuvable',
                icon: Icons.person_off_outlined,
                message:
                    'Profil utilisateur introuvable. Deconnectez-vous puis reconnectez-vous, ou creez un nouveau compte.',
                actionLabel: 'Deconnexion',
                actionIcon: Icons.logout,
                onActionPressed: authController.logout,
              );
            }

            if (!authController.isValidRole(profile.role)) {
              return _AuthStateView(
                title: 'Role invalide',
                icon: Icons.admin_panel_settings_outlined,
                message:
                    'Votre profil contient un role non reconnu. Contactez un administrateur ou reconnectez-vous avec un autre compte.',
                actionLabel: 'Deconnexion',
                actionIcon: Icons.logout,
                onActionPressed: authController.logout,
              );
            }

            if (profile.role == AuthController.organizerRole) {
              return const OrganizerHome();
            }

            return const UserHome();
          },
        );
      },
    );
  }
}

class _AuthStateView extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final bool isLoading;

  const _AuthStateView({
    required this.title,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onActionPressed,
  }) : isLoading = false;

  const _AuthStateView.loading()
    : title = 'DEVMOB',
      icon = Icons.hourglass_empty,
      message = '',
      actionLabel = null,
      actionIcon = null,
      onActionPressed = null,
      isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppScaffold(
        title: 'DEVMOB',
        centerContent: true,
        child: CircularProgressIndicator(),
      );
    }

    return AppScaffold(
      title: title,
      centerContent: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (onActionPressed != null && actionLabel != null) ...[
                  const SizedBox(height: 20),
                  CustomButton(
                    label: actionLabel!,
                    icon: actionIcon,
                    onPressed: onActionPressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
