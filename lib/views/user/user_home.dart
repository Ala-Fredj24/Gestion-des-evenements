import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/section_title.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accueil utilisateur',
      child: ListView(
        children: [
          const SectionTitle(
            title: 'Evenements disponibles',
            subtitle:
                'Consultez bientot les evenements culturels et sportifs disponibles.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 52,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun evenement affiche pour le moment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "La liste des evenements sera ajoutee apres l'harmonisation du design.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: 'Deconnexion',
            icon: Icons.logout,
            outlined: true,
            onPressed: () => AuthController().logout(),
          ),
        ],
      ),
    );
  }
}
