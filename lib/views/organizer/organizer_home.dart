import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/event_card.dart';
import '../../widgets/section_title.dart';
import '../home/event_detail_view.dart';
import 'create_event_view.dart';

class OrganizerHome extends StatefulWidget {
  final UserModel profile;

  const OrganizerHome({super.key, required this.profile});

  @override
  State<OrganizerHome> createState() => _OrganizerHomeState();
}

class _OrganizerHomeState extends State<OrganizerHome> {
  final AuthController authController = AuthController();
  final EventController eventController = EventController();

  Future<void> deleteEvent(EventModel event) async {
    final firebaseUser = authController.user;
    final eventId = event.id;
    if (firebaseUser == null || eventId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer evenement'),
        content: Text('Supprimer "${event.title}" definitivement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await eventController.deleteEvent(
        eventId: eventId,
        currentOrganizerId: firebaseUser.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Evenement supprime')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = authController.user;
    final profileName = widget.profile.displayName.trim();
    final firebaseName = firebaseUser?.displayName?.trim();
    final displayName = profileName.isNotEmpty ? profileName : firebaseName;

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
                      _OrganizerEventItem(
                        event: event,
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailView(event: event),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateEventView(event: event),
                            ),
                          );
                        },
                        onDelete: () => deleteEvent(event),
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
  }
}

class _OrganizerEventItem extends StatelessWidget {
  final EventModel event;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrganizerEventItem({
    required this.event,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EventCard(event: event, onTap: onOpen),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifier'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer'),
              ),
            ),
          ],
        ),
      ],
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
