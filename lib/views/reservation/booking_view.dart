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
  final _paymentFormKey = GlobalKey<FormState>();
  final cardholderController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expirationController = TextEditingController();
  final cvvController = TextEditingController();

  int quantity = 1;
  bool isLoading = false;

  double get totalPrice => (widget.event.price ?? 0) * quantity;

  String get totalPriceLabel =>
      widget.event.isFree ? 'Gratuit' : '${totalPrice.toStringAsFixed(2)} DT';

  bool get requiresPayment => !widget.event.isFree;

  @override
  void dispose() {
    cardholderController.dispose();
    cardNumberController.dispose();
    expirationController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  void decrementQuantity() {
    if (quantity <= 1) return;
    setState(() => quantity--);
  }

  void incrementQuantity() {
    if (quantity >= widget.event.seatsAvailable) return;
    setState(() => quantity++);
  }

  Future<void> confirmBooking() async {
    if (!widget.event.canReserve || widget.event.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_unavailableMessage(widget.event))),
      );
      return;
    }
    if (quantity <= 0 || quantity > widget.event.seatsAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quantite invalide.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour reserver.')),
      );
      return;
    }
    if (requiresPayment &&
        !(_paymentFormKey.currentState?.validate() ?? false)) {
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
      await _showConfirmationDialog(user.email ?? 'votre email');
      if (!mounted) return;
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

  Future<void> _showConfirmationDialog(String email) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          requiresPayment ? 'Paiement reussi' : 'Reservation confirmee',
        ),
        content: Text(
          'Email simule envoye a $email\n\n'
          'Evenement : ${widget.event.title}\n'
          'Date : ${widget.event.dateLabel}\n'
          'Lieu : ${widget.event.locationLabel}\n'
          'Places : $quantity\n'
          'Total : $totalPriceLabel',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
          if (requiresPayment) ...[
            const SizedBox(height: 16),
            _PaymentSimulationForm(
              formKey: _paymentFormKey,
              cardholderController: cardholderController,
              cardNumberController: cardNumberController,
              expirationController: expirationController,
              cvvController: cvvController,
            ),
          ],
          if (!canSubmit) ...[
            const SizedBox(height: 16),
            _UnavailableReservationCard(message: _unavailableMessage(event)),
          ],
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

  String _unavailableMessage(EventModel event) {
    if (event.id == null) {
      return 'Reservation impossible pour cet evenement.';
    }
    if (!event.isActive) {
      return 'Cet evenement n est plus disponible.';
    }
    if (!event.isUpcoming) {
      return 'Cet evenement est deja passe.';
    }
    if (event.isFull) {
      return 'Cet evenement est complet.';
    }
    return 'Reservation indisponible pour le moment.';
  }
}

class _PaymentSimulationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cardholderController;
  final TextEditingController cardNumberController;
  final TextEditingController expirationController;
  final TextEditingController cvvController;

  const _PaymentSimulationForm({
    required this.formKey,
    required this.cardholderController,
    required this.cardNumberController,
    required this.expirationController,
    required this.cvvController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paiement simule',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cardholderController,
                decoration: const InputDecoration(
                  labelText: 'Nom du titulaire',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Nom du titulaire obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numero de carte',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.length != 15) {
                    return 'introduisez un numero de carte 15 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expirationController,
                      decoration: const InputDecoration(
                        labelText: 'Expiration',
                        hintText: 'MM/AA',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(text)) {
                          return 'Format MM/AA';
                        }
                        final month = int.tryParse(text.substring(0, 2));
                        if (month == null || month < 1 || month > 12) {
                          return 'Mois invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        final digits = (value ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        if (digits.length != 3) {
                          return 'CVV doit etre 3 chiffres';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Simulation uniquement : aucun paiement reel ne sera effectue.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableReservationCard extends StatelessWidget {
  final String message;

  const _UnavailableReservationCard({required this.message});

  @override
  Widget build(BuildContext context) {
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
