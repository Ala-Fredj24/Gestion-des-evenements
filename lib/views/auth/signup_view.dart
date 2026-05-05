import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String role = 'user'; // default: Utilisateur
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> doSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final res = await AuthController().signUp(
      email: emailController.text,
      password: passwordController.text,
      role: role,
    );

    setState(() => isLoading = false);

    if (res != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
      return;
    }

    // Success: go back to login (optional). AuthWrapper may already redirect because user is logged in.
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: "Rôle"),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text("Utilisateur")),
                  DropdownMenuItem(
                    value: 'organizer',
                    child: Text("Organisateur"),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => role = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Entrez votre email";
                  }
                  if (!v.contains('@')) return "Email invalide";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Entrez un mot de passe";
                  if (v.length < 7) return "Minimum 7 caractères";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirmer le mot de passe",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Confirmez votre mot de passe";
                  }
                  if (v != passwordController.text) {
                    return "Les mots de passe ne correspondent pas";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : doSignup,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Créer le compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
