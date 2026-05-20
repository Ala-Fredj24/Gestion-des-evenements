import 'package:flutter/material.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/event_card.dart';
import '../../widgets/section_title.dart';
import '../home/event_detail_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final EventController _eventController = EventController();

  DateTime selectedDate = DateTime.now();

  String get selectedDateLabel {
    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    return '$day/$month/${selectedDate.year}';
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );

    if (picked == null || !mounted) return;
    setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Calendrier',
      child: ListView(
        children: [
          SectionTitle(
            title: 'Evenements par date',
            subtitle: 'Selectionnez une date pour consulter les evenements.',
            trailing: IconButton(
              tooltip: 'Choisir une date',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: pickDate,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.event_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                selectedDateLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              trailing: TextButton(
                onPressed: pickDate,
                child: const Text('Changer'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<EventModel>>(
            stream: _eventController.getEventsForDate(selectedDate),
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
                return const _CalendarState(
                  icon: Icons.error_outline,
                  title: 'Chargement impossible',
                  message:
                      'Impossible de charger les evenements de cette date.',
                );
              }

              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return const _CalendarState(
                  icon: Icons.event_busy_outlined,
                  title: 'Aucun evenement',
                  message: 'Aucun evenement trouve pour cette date.',
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

class _CalendarState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _CalendarState({
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
