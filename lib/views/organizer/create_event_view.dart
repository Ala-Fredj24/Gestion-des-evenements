import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';

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

  final dateTimeController = TextEditingController(); // affichage seulement

  final categories = const ['Culture', 'Sport', 'Autre'];
  String category = 'Culture';

  DateTime? selectedDateTime;

  double? latitude;
  double? longitude;

  bool isLoading = false;
  bool isGettingLocation = false;

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

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay.fromDateTime(selectedDateTime!)
          : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

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
          "${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    });
  }

  Future<void> getCurrentLocation() async {
    setState(() => isGettingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw "La localisation est désactivée. Active-la dans le téléphone/émulateur.";
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw "Permission localisation refusée.";
      }

      if (permission == LocationPermission.deniedForever) {
        throw "Permission refusée définitivement. Va dans les paramètres pour l’activer.";
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Position récupérée ✅")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (!mounted) return;
      setState(() => isGettingLocation = false);
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Choisis la date et l’heure de l’événement."),
        ),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Récupère la géolocalisation (GPS) du lieu."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw "Utilisateur non connecté.";
      }

      final seatsTotal = int.parse(seatsController.text.trim());

      final priceText = priceController.text.trim();
      final double? price = priceText.isEmpty ? null : double.parse(priceText);

      final event = EventModel(
        organizerId: user.uid,
        title: titleController.text.trim(),
        category: category,
        description: descriptionController.text.trim(),
        dateTime: selectedDateTime!,
        address: addressController.text.trim(),
        latitude: latitude!,
        longitude: longitude!,
        seatsTotal: seatsTotal,
        seatsAvailable: seatsTotal,
        price: price,
      );

      await EventController().createEvent(event);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Événement créé ✅")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un événement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Titre obligatoire";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: "Catégorie"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => category = v);
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Description obligatoire";
                  }
                  if (v.trim().length < 10) return "Description trop courte";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: dateTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date et heure",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: pickDateAndTime,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Lieu (adresse)"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Adresse obligatoire";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: isGettingLocation ? null : getCurrentLocation,
                icon: isGettingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text("Récupérer ma position (GPS)"),
              ),

              const SizedBox(height: 8),
              if (latitude != null && longitude != null)
                Text("GPS: $latitude, $longitude"),

              const SizedBox(height: 12),

              TextFormField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nombre de places",
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Nombre de places obligatoire";
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null) return "Entrez un nombre valide";
                  if (n <= 0) return "Doit être > 0";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Prix d’entrée (optionnel)",
                  hintText: "Laisse vide si gratuit",
                ),
                validator: (v) {
                  if (v == null) return null;
                  final t = v.trim();
                  if (t.isEmpty) return null;
                  final p = double.tryParse(t);
                  if (p == null) return "Prix invalide";
                  if (p < 0) return "Prix doit être positif";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Créer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
