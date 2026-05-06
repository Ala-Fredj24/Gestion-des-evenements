import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/section_title.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String role = 'user';
  bool isLoading = false;

  @override
  void dispose() {
    displayNameController.dispose();
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
      displayName: displayNameController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inscription',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SectionTitle(
                      title: 'Creer un compte',
                      subtitle:
                          'Choisissez votre role pour acceder au bon espace.',
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'user',
                          child: Text('Utilisateur'),
                        ),
                        DropdownMenuItem(
                          value: 'organizer',
                          child: Text('Organisateur'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => role = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: displayNameController,
                      keyboardType: TextInputType.name,
                      label: 'Nom complet',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Entrez votre nom';
                        }
                        if (v.trim().length < 2) return 'Nom trop court';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Entrez votre email';
                        }
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: passwordController,
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Entrez un mot de passe';
                        }
                        if (v.length < 7) return 'Minimum 7 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: confirmController,
                      label: 'Confirmer le mot de passe',
                      icon: Icons.verified_user_outlined,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirmez votre mot de passe';
                        }
                        if (v != passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Creer le compte',
                      icon: Icons.person_add_alt_1,
                      onPressed: doSignup,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
