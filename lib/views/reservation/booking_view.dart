import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/reservation_controller.dart';
import '../../models/event_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/section_title.dart';

class BookingView extends StatefulWidget {
  final EventModel event;

  const BookingView({super.key, required this.event});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final ReservationController _reservationController = ReservationController();

  int quantity = 1;
  bool isLoading = false;

  double get totalPrice => (widget.event.price ?? 0) * quantity;

  String get totalPriceLabel =>
      widget.event.isFree ? 'Gratuit' : '${totalPrice.toStringAsFixed(2)} DT';

  void decrementQuantity() {
    if (quantity <= 1) return;
    setState(() => quantity--);
  }

  void incrementQuantity() {
    if (quantity >= widget.event.seatsAvailable) return;
    setState(() => quantity++);
  }

  Future<void> confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour reserver.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _reservationController.createReservation(
        event: widget.event,
        userId: user.uid,
        quantity: quantity,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reservation confirmee')));
      Navigator.pop(context, true);
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
    final event = widget.event;
    final canIncrement = quantity < event.seatsAvailable;
    final canSubmit = event.canReserve && event.id != null;

    return AppScaffold(
      title: 'Reservation',
      child: ListView(
        children: [
          SectionTitle(
            title: event.title,
            subtitle: 'Confirmez le nombre de places souhaite.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _SummaryRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: event.dateLabel,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    icon: Icons.place_outlined,
                    label: 'Lieu',
                    value: event.locationLabel,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    icon: Icons.event_seat_outlined,
                    label: 'Disponibles',
                    value: event.seatsLabel,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    icon: Icons.payments_outlined,
                    label: 'Prix unitaire',
                    value: event.priceLabel,
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
                    'Nombre de places',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: quantity > 1 ? decrementQuantity : null,
                      ),
                      Expanded(
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: canIncrement ? incrementQuantity : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Maximum disponible : ${event.seatsAvailable}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    totalPriceLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: canSubmit ? 'Confirmer la reservation' : event.status,
            icon: Icons.check_circle_outline,
            onPressed: canSubmit ? confirmBooking : null,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon),
      ),
    );
  }
}
