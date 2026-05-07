import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/event_card.dart';
import '../../widgets/section_title.dart';
import '../home/event_detail_view.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
    final eventController = EventController();
    final firebaseUser = authController.user;

    return FutureBuilder<UserModel?>(
      future: authController.getCurrentUserProfile(),
      builder: (context, profileSnapshot) {
        final profileName = profileSnapshot.data?.displayName.trim();
        final firebaseName = firebaseUser?.displayName?.trim();
        final displayName = profileName != null && profileName.isNotEmpty
            ? profileName
            : firebaseName;

        return AppScaffold(
          title: displayName != null && displayName.isNotEmpty
              ? 'Bienvenue $displayName'
              : 'Bienvenue',
          actions: [
            IconButton(
              tooltip: 'Deconnexion',
              icon: const Icon(Icons.logout),
              onPressed: authController.logout,
            ),
          ],
          child: ListView(
            children: [
              const SectionTitle(
                title: 'Evenements disponibles',
                subtitle:
                    'Consultez les prochains evenements culturels et sportifs.',
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<EventModel>>(
                stream: eventController.getUpcomingEvents(),
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
                    return const _UserEventState(
                      icon: Icons.error_outline,
                      title: 'Chargement impossible',
                      message:
                          'Impossible de charger les evenements. Verifiez votre connexion et les permissions Firestore.',
                    );
                  }

                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const _UserEventState(
                      icon: Icons.event_available_outlined,
                      title: 'Aucun evenement disponible',
                      message:
                          'Les prochains evenements apparaitront ici des qu un organisateur en publie un.',
                    );
                  }

                  return Column(
                    children: [
                      for (final event in events) ...[
                        EventCard(
                          event: event,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailView(event: event),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserEventState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _UserEventState({
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
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 52),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
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
