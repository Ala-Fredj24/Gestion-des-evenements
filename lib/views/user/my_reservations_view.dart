import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/event_controller.dart';
import '../../controllers/reservation_controller.dart';
import '../../models/event_model.dart';
import '../../models/reservation_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/section_title.dart';
import '../home/event_detail_view.dart';

class MyReservationsView extends StatelessWidget {
  const MyReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final reservationController = ReservationController();

    return AppScaffold(
      title: 'Mes reservations',
      child: user == null
          ? const _ReservationState(
              icon: Icons.lock_outline,
              title: 'Session introuvable',
              message: 'Reconnectez-vous pour consulter vos reservations.',
            )
          : ListView(
              children: [
                const SectionTitle(
                  title: 'Mes reservations',
                  subtitle:
                      'Retrouvez les places reservees pour vos evenements.',
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<ReservationModel>>(
                  stream: reservationController.getUserReservations(user.uid),
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
                      return const _ReservationState(
                        icon: Icons.error_outline,
                        title: 'Chargement impossible',
                        message:
                            'Impossible de charger vos reservations. Verifiez votre connexion et les permissions Firestore.',
                      );
                    }

                    final reservations = snapshot.data ?? [];
                    if (reservations.isEmpty) {
                      return const _ReservationState(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Aucune reservation',
                        message:
                            'Vos prochaines reservations apparaitront ici apres confirmation.',
                      );
                    }

                    return Column(
                      children: [
                        for (final reservation in reservations) ...[
                          _ReservationCard(reservation: reservation),
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

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventModel?>(
      future: EventController().getEventById(reservation.eventId),
      builder: (context, snapshot) {
        final event = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasEvent = event != null;

        return Card(
          child: InkWell(
            onTap: hasEvent
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailView(event: event),
                      ),
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          isLoading
                              ? 'Chargement evenement...'
                              : event?.title ?? 'Evenement indisponible',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (hasEvent) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ReservationBadge(
                        label: reservation.statusLabel,
                        color: reservation.isConfirmed
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      _ReservationBadge(
                        label: reservation.quantityLabel,
                        color: AppTheme.secondary,
                      ),
                      if (hasEvent)
                        _ReservationBadge(
                          label: event.priceLabel,
                          color: AppTheme.accent,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasEvent) ...[
                    _ReservationInfo(
                      icon: Icons.calendar_today,
                      label: event.dateLabel,
                    ),
                    const SizedBox(height: 6),
                    _ReservationInfo(
                      icon: Icons.place_outlined,
                      label: event.locationLabel,
                    ),
                  ] else
                    const _ReservationInfo(
                      icon: Icons.info_outline,
                      label:
                          'Les informations de cet evenement ne sont pas disponibles.',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReservationBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ReservationBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReservationInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReservationInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ReservationState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ReservationState({
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
