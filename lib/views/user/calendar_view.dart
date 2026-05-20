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
  late DateTime visibleMonth = DateTime(selectedDate.year, selectedDate.month);

  String get selectedDateLabel {
    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    return '$day/$month/${selectedDate.year}';
  }

  String get visibleMonthLabel {
    final month = visibleMonth.month.toString().padLeft(2, '0');
    return '$month/${visibleMonth.year}';
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: visibleMonth,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 3, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null || !mounted) return;
    setState(() {
      visibleMonth = DateTime(picked.year, picked.month);
      selectedDate = DateTime(picked.year, picked.month, 1);
    });
  }

  void previousMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
      selectedDate = DateTime(visibleMonth.year, visibleMonth.month, 1);
    });
  }

  void nextMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
      selectedDate = DateTime(visibleMonth.year, visibleMonth.month, 1);
    });
  }

  List<DateTime?> buildMonthDays() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final leadingEmptyDays = firstDay.weekday - 1;

    return [
      for (var i = 0; i < leadingEmptyDays; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(visibleMonth.year, visibleMonth.month, day),
    ];
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Calendrier',
      child: ListView(
        children: [
          SectionTitle(
            title: 'Evenements par date',
            subtitle:
                'Selectionnez un mois puis une date pour consulter les evenements.',
            trailing: IconButton(
              tooltip: 'Choisir un mois',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: pickMonth,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<EventModel>>(
            stream: _eventController.getEventsForMonth(visibleMonth),
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

              final monthEvents = snapshot.data ?? [];
              final selectedEvents = monthEvents
                  .where((event) => isSameDay(event.dateTime, selectedDate))
                  .toList();

              return Column(
                children: [
                  _MonthCalendarCard(
                    visibleMonthLabel: visibleMonthLabel,
                    selectedDate: selectedDate,
                    days: buildMonthDays(),
                    events: monthEvents,
                    onPrevious: previousMonth,
                    onNext: nextMonth,
                    onPickMonth: pickMonth,
                    onSelectDate: (date) => setState(() => selectedDate = date),
                  ),
                  const SizedBox(height: 16),
                  SectionTitle(
                    title: 'Evenements du $selectedDateLabel',
                    subtitle: selectedEvents.isEmpty
                        ? 'Aucun evenement planifie pour cette date.'
                        : '${selectedEvents.length} evenement(s) trouve(s).',
                  ),
                  const SizedBox(height: 12),
                  if (selectedEvents.isEmpty)
                    const _CalendarState(
                      icon: Icons.event_busy_outlined,
                      title: 'Aucun evenement',
                      message: 'Selectionnez une autre date du calendrier.',
                    )
                  else
                    for (final event in selectedEvents) ...[
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

class _MonthCalendarCard extends StatelessWidget {
  final String visibleMonthLabel;
  final DateTime selectedDate;
  final List<DateTime?> days;
  final List<EventModel> events;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickMonth;
  final ValueChanged<DateTime> onSelectDate;

  const _MonthCalendarCard({
    required this.visibleMonthLabel,
    required this.selectedDate,
    required this.days,
    required this.events,
    required this.onPrevious,
    required this.onNext,
    required this.onPickMonth,
    required this.onSelectDate,
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
                IconButton(
                  tooltip: 'Mois precedent',
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onPickMonth,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      visibleMonthLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mois suivant',
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _WeekdayLabel(label: 'L'),
                _WeekdayLabel(label: 'M'),
                _WeekdayLabel(label: 'M'),
                _WeekdayLabel(label: 'J'),
                _WeekdayLabel(label: 'V'),
                _WeekdayLabel(label: 'S'),
                _WeekdayLabel(label: 'D'),
              ],
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final date = days[index];
                if (date == null) {
                  return const SizedBox.shrink();
                }

                final dayEvents = events
                    .where(
                      (event) =>
                          event.dateTime.year == date.year &&
                          event.dateTime.month == date.month &&
                          event.dateTime.day == date.day,
                    )
                    .toList();
                final isSelected =
                    selectedDate.year == date.year &&
                    selectedDate.month == date.month &&
                    selectedDate.day == date.day;

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onSelectDate(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
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
