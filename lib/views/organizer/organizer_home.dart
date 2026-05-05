import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'create_event_view.dart';

class OrganizerHome extends StatelessWidget {
  const OrganizerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Espace Organisateur")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEventView()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Créer un événement"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => AuthController().logout(),
              icon: const Icon(Icons.logout),
              label: const Text("Déconnexion"),
            ),
          ],
        ),
      ),
    );
  }
}
