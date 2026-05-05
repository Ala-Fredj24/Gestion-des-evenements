import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil Utilisateur")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Connecté ✅ (Utilisateur)"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AuthController().logout(),
              child: const Text("Déconnexion"),
            ),
          ],
        ),
      ),
    );
  }
}
