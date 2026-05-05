import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class RoleDebugHome extends StatelessWidget {
  final String role;
  const RoleDebugHome({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Connecté ✅\nRôle: $role", textAlign: TextAlign.center),
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
