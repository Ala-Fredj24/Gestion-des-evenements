import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/review_controller.dart';
import '../../models/event_model.dart';
import '../../models/review_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/location_map_card.dart';
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
          LocationMapCard(
            placeName: event.locationLabel,
            latitude: event.latitude,
            longitude: event.longitude,
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
          if (!canOpenBooking) ...[
            _ReservationNotice(event: event),
            const SizedBox(height: 16),
          ],
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
          _ReviewsSection(eventId: event.id),
        ],
      ),
    );
  }
}

class _ReservationNotice extends StatelessWidget {
  final EventModel event;

  const _ReservationNotice({required this.event});

  @override
  Widget build(BuildContext context) {
    String message;
    if (event.id == null) {
      message = 'Reservation impossible pour cet evenement.';
    } else if (!event.isActive) {
      message = 'Cet evenement n est plus disponible.';
    } else if (!event.isUpcoming) {
      message = 'Cet evenement est deja passe.';
    } else if (event.isFull) {
      message = 'Cet evenement est complet.';
    } else {
      message = 'Reservation indisponible pour le moment.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
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

class _ReviewsSection extends StatefulWidget {
  final String? eventId;

  const _ReviewsSection({required this.eventId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  final ReviewController _reviewController = ReviewController();
  final TextEditingController _commentController = TextEditingController();

  int rating = 5;
  bool isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    final eventId = widget.eventId;
    final user = FirebaseAuth.instance.currentUser;

    if (eventId == null || eventId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Evenement introuvable.')));
      return;
    }
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour ajouter un avis.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _reviewController.addReview(
        userId: user.uid,
        eventId: eventId,
        rating: rating,
        comment: _commentController.text,
      );

      if (!mounted) return;
      _commentController.clear();
      setState(() => rating = 5);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Avis ajoute')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventId = widget.eventId;

    if (eventId == null || eventId.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Avis',
            subtitle: 'Avis indisponibles pour cet evenement.',
          ),
          SizedBox(height: 12),
          _ReviewStateCard(
            icon: Icons.rate_review_outlined,
            message: 'Evenement introuvable.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Avis',
          subtitle: 'Consultez les retours et laissez votre note.',
        ),
        const SizedBox(height: 12),
        _ReviewFormCard(
          rating: rating,
          commentController: _commentController,
          isLoading: isLoading,
          onRatingChanged: (value) => setState(() => rating = value),
          onSubmit: submitReview,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ReviewModel>>(
          stream: _reviewController.getEventReviews(eventId),
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
              return const _ReviewStateCard(
                icon: Icons.error_outline,
                message:
                    'Impossible de charger les avis. Verifiez les permissions Firestore.',
              );
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const _ReviewStateCard(
                icon: Icons.rate_review_outlined,
                message: 'Aucun avis pour le moment.',
              );
            }

            final average =
                reviews.fold<int>(0, (sum, review) => sum + review.rating) /
                reviews.length;

            return Column(
              children: [
                _AverageRatingCard(
                  average: average,
                  reviewCount: reviews.length,
                ),
                const SizedBox(height: 12),
                for (final review in reviews) ...[
                  _ReviewCard(review: review),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReviewFormCard extends StatelessWidget {
  final int rating;
  final TextEditingController commentController;
  final bool isLoading;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _ReviewFormCard({
    required this.rating,
    required this.commentController,
    required this.isLoading,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter un avis',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              children: [
                for (var value = 1; value <= 5; value++)
                  IconButton(
                    tooltip: '$value/5',
                    onPressed: isLoading ? null : () => onRatingChanged(value),
                    icon: Icon(
                      value <= rating ? Icons.star : Icons.star_border,
                      color: AppTheme.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: commentController,
              label: 'Commentaire',
              icon: Icons.rate_review_outlined,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Publier avis',
              icon: Icons.send_outlined,
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _AverageRatingCard extends StatelessWidget {
  final double average;
  final int reviewCount;

  const _AverageRatingCard({required this.average, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: AppTheme.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Moyenne ${average.toStringAsFixed(1)}/5',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '$reviewCount avis',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      for (var value = 1; value <= 5; value++)
                        Icon(
                          value <= review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppTheme.accent,
                          size: 18,
                        ),
                    ],
                  ),
                ),
                Text(
                  review.ratingLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.hasComment ? review.comment : 'Aucun commentaire.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStateCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _ReviewStateCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
