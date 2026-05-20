import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/section_title.dart';
import '../reservation/booking_view.dart';

class EventDetailView extends StatelessWidget {
  final EventModel event;

  const EventDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final canOpenBooking = event.canReserve && event.id != null;

    return AppScaffold(
      title: 'Detail evenement',
      child: ListView(
        children: [
          SectionTitle(
            title: event.title,
            subtitle: event.category,
            trailing: _StatusBadge(event: event),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: event.dateLabel,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.place_outlined,
                    label: event.locationLabel,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.confirmation_number_outlined,
                    label: event.priceLabel,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.event_seat_outlined,
                    label: event.seatsLabel,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description.trim().isEmpty
                        ? 'Aucune description disponible.'
                        : event.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: canOpenBooking
                ? 'Reserver'
                : event.id == null
                ? 'Reservation impossible'
                : event.status,
            icon: event.canReserve
                ? Icons.confirmation_number_outlined
                : Icons.block_outlined,
            onPressed: canOpenBooking
                ? () async {
                    final didBook = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingView(event: event),
                      ),
                    );

                    if (!context.mounted || didBook != true) return;
                    Navigator.pop(context);
                  }
                : null,
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Avis',
            subtitle:
                'Les commentaires et notes seront disponibles dans une prochaine tache.',
          ),
          const SizedBox(height: 12),
          const _EmptyReviewsCard(),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EventModel event;

  const _StatusBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event.canReserve ? AppTheme.primary : AppTheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        event.status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _EmptyReviewsCard extends StatelessWidget {
  const _EmptyReviewsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun avis pour le moment.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
