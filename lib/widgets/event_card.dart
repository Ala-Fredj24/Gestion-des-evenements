import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date =
        '${event.dateTime.day.toString().padLeft(2, '0')}/${event.dateTime.month.toString().padLeft(2, '0')}/${event.dateTime.year}';
    final price = event.isFree
        ? 'Gratuit'
        : '${event.price!.toStringAsFixed(2)} DT';
    final isFull = event.seatsAvailable <= 0;

    return Card(
      child: InkWell(
        onTap: onTap,
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
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _Badge(
                    label: isFull ? 'Complet' : 'Disponible',
                    color: isFull ? AppTheme.error : AppTheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.calendar_today, label: date),
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.place, label: event.address),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.event_seat,
                label: '${event.seatsAvailable}/${event.seatsTotal} places',
              ),
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.confirmation_number, label: price),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

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
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

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
