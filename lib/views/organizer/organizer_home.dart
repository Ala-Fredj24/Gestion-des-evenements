import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/event_card.dart';
import '../../widgets/section_title.dart';
import 'create_event_view.dart';

class OrganizerHome extends StatelessWidget {
  const OrganizerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
    final eventController = EventController();
    final firebaseUser = authController.user;
    final displayName = firebaseUser?.displayName?.trim();

    return AppScaffold(
      title: displayName != null && displayName.isNotEmpty
          ? 'Bienvenue $displayName'
          : 'Bienvenue',
      child: ListView(
        children: [
          SectionTitle(
            title: 'Espace organisateur',
            subtitle:
                'Creez vos evenements et suivez vos publications depuis cet espace.',
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
            onPressed: authController.logout,
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Mes evenements'),
          const SizedBox(height: 12),
          if (firebaseUser == null)
            const _OrganizerEmptyState(
              icon: Icons.lock_outline,
              title: 'Session introuvable',
              message: 'Reconnectez-vous pour consulter vos evenements.',
            )
          else
            StreamBuilder<List<EventModel>>(
              stream: eventController.getOrganizerEvents(firebaseUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _OrganizerEmptyState(
                    icon: Icons.error_outline,
                    title: 'Chargement impossible',
                    message:
                        'Impossible de charger vos evenements. Verifiez votre connexion et les permissions Firestore.',
                  );
                }

                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return const _OrganizerEmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'Aucun evenement',
                    message:
                        'Creez votre premier evenement pour le voir apparaitre ici.',
                  );
                }

                return Column(
                  children: [
                    for (final event in events) ...[
                      EventCard(event: event),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _OrganizerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _OrganizerEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
