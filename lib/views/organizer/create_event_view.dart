import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../models/place_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/location_map_card.dart';
import '../../widgets/section_title.dart';
import '../map/place_picker_view.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final seatsController = TextEditingController();
  final priceController = TextEditingController();
  final dateTimeController = TextEditingController();

  final categories = const ['Culture', 'Sport', 'Autre'];
  String category = 'Culture';

  DateTime? selectedDateTime;
  PlaceModel? selectedPlace;

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    seatsController.dispose();
    priceController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  Future<void> pickDateAndTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (!mounted || pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay.fromDateTime(selectedDateTime!)
          : TimeOfDay.now(),
    );

    if (!mounted || pickedTime == null) return;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      selectedDateTime = dt;
      dateTimeController.text =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> pickMapLocation() async {
    final place = await Navigator.push<PlaceModel>(
      context,
      MaterialPageRoute(builder: (_) => const PlacePickerView()),
    );

    if (!mounted || place == null) return;
    setState(() {
      selectedPlace = place;
      addressController.text = place.name;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Choisissez la date et l'heure de l'evenement."),
        ),
      );
      return;
    }
    if (selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectionnez un lieu sur la carte.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'Utilisateur non connecte.';
      }

      final seatsTotal = int.parse(seatsController.text.trim());
      final priceText = priceController.text.trim();
      final double? price = priceText.isEmpty ? null : double.parse(priceText);
      final place = selectedPlace!;

      final event = EventModel(
        organizerId: user.uid,
        title: titleController.text.trim(),
        category: category,
        description: descriptionController.text.trim(),
        dateTime: selectedDateTime!,
        address: place.name,
        latitude: place.latitude,
        longitude: place.longitude,
        seatsTotal: seatsTotal,
        seatsAvailable: seatsTotal,
        price: price,
      );

      await EventController().createEvent(event);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evenement cree avec succes')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Creer un evenement',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SectionTitle(
              title: 'Nouvel evenement',
              subtitle:
                  'Remplissez les informations principales avant publication.',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: titleController,
              label: 'Titre',
              icon: Icons.event_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Titre obligatoire';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Categorie',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => category = v);
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description obligatoire';
                }
                if (v.trim().length < 10) return 'Description trop courte';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: dateTimeController,
              label: 'Date et heure',
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: pickDateAndTime,
              suffixIcon: const Icon(Icons.expand_more),
              validator: (_) {
                if (selectedDateTime == null) {
                  return 'Date et heure obligatoires';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: addressController,
              label: 'Lieu officiel',
              icon: Icons.place_outlined,
              readOnly: true,
              onTap: pickMapLocation,
              suffixIcon: const Icon(Icons.map_outlined),
              validator: (v) {
                if (selectedPlace == null) {
                  return 'Selectionnez un lieu sur la carte';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Choisir sur la carte',
              icon: Icons.map_outlined,
              outlined: true,
              onPressed: pickMapLocation,
            ),
            if (selectedPlace != null) ...[
              const SizedBox(height: 8),
              LocationMapCard(
                placeName: selectedPlace!.name,
                latitude: selectedPlace!.latitude,
                longitude: selectedPlace!.longitude,
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Lieu obligatoire : recherchez ou touchez un lieu existant sur la carte.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            CustomTextField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              label: 'Nombre de places',
              icon: Icons.event_seat_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nombre de places obligatoire';
                }
                final n = int.tryParse(v.trim());
                if (n == null) return 'Entrez un nombre valide';
                if (n <= 0) return 'Doit etre superieur a 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              label: 'Prix d entree (optionnel)',
              hintText: 'Laissez vide si gratuit',
              icon: Icons.payments_outlined,
              validator: (v) {
                if (v == null) return null;
                final t = v.trim();
                if (t.isEmpty) return null;
                final p = double.tryParse(t);
                if (p == null) return 'Prix invalide';
                if (p < 0) return 'Prix doit etre positif';
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Creer',
              icon: Icons.add,
              onPressed: submit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
