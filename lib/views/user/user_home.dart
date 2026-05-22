import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/event_card.dart';
import '../../widgets/section_title.dart';
import '../home/event_detail_view.dart';
import 'calendar_view.dart';
import 'my_reservations_view.dart';

class UserHome extends StatefulWidget {
  final UserModel profile;

  const UserHome({super.key, required this.profile});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  static const String allCategories = 'Toutes';
  static const String allPrices = 'Tous';
  static const String freeOnly = 'Gratuits';
  static const String paidOnly = 'Payants';

  final EventController eventController = EventController();

  String selectedCategory = allCategories;
  String selectedPrice = allPrices;

  String? get categoryFilter =>
      selectedCategory == allCategories ? null : selectedCategory;

  bool? get priceFilter {
    if (selectedPrice == freeOnly) {
      return true;
    }
    if (selectedPrice == paidOnly) {
      return false;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
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
          tooltip: 'Calendrier',
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarView()),
            );
          },
        ),
        IconButton(
          tooltip: 'Mes reservations',
          icon: const Icon(Icons.confirmation_number_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyReservationsView()),
            );
          },
        ),
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
          _EventFilters(
            selectedCategory: selectedCategory,
            selectedPrice: selectedPrice,
            onCategoryChanged: (value) {
              if (value == null) return;
              setState(() => selectedCategory = value);
            },
            onPriceChanged: (value) {
              if (value == null) return;
              setState(() => selectedPrice = value);
            },
            onReset: () {
              setState(() {
                selectedCategory = allCategories;
                selectedPrice = allPrices;
              });
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<EventModel>>(
            stream: eventController.getUpcomingEvents(
              category: categoryFilter,
              isFree: priceFilter,
            ),
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
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Aucun evenement trouve',
                  message: 'Aucun evenement ne correspond aux filtres choisis.',
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
  }
}

class _EventFilters extends StatelessWidget {
  final String selectedCategory;
  final String selectedPrice;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onPriceChanged;
  final VoidCallback onReset;

  const _EventFilters({
    required this.selectedCategory,
    required this.selectedPrice,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filtres',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onReset,
                  child: const Text('Reinitialiser'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categorie',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Toutes', child: Text('Toutes')),
                DropdownMenuItem(value: 'Culture', child: Text('Culture')),
                DropdownMenuItem(value: 'Sport', child: Text('Sport')),
                DropdownMenuItem(value: 'Autre', child: Text('Autre')),
              ],
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedPrice,
              decoration: const InputDecoration(
                labelText: 'Prix',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                DropdownMenuItem(value: 'Gratuits', child: Text('Gratuits')),
                DropdownMenuItem(value: 'Payants', child: Text('Payants')),
              ],
              onChanged: onPriceChanged,
            ),
          ],
        ),
      ),
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
