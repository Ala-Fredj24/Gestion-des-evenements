import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/section_title.dart';

class RoleDebugHome extends StatelessWidget {
  final String role;
  const RoleDebugHome({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accueil',
      centerContent: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 56,
              ),
              const SizedBox(height: 16),
              SectionTitle(title: 'Connecte', subtitle: 'Role actuel : $role'),
              const SizedBox(height: 20),
              CustomButton(
                label: 'Deconnexion',
                icon: Icons.logout,
                outlined: true,
                onPressed: () => AuthController().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
