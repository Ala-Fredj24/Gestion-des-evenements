import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/section_title.dart';
import 'create_event_view.dart';

class OrganizerHome extends StatelessWidget {
  const OrganizerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Espace organisateur',
      child: ListView(
        children: [
          const SectionTitle(
            title: 'Bonjour organisateur',
            subtitle:
                'Creez vos evenements et suivez bientot vos reservations depuis cet espace.',
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: 'Creer un evenement',
            icon: Icons.add_circle_outline,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventView()),
              );
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Deconnexion',
            icon: Icons.logout,
            outlined: true,
            onPressed: () => AuthController().logout(),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mes evenements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La liste de vos evenements sera ajoutee apres la creation des cartes evenement.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
