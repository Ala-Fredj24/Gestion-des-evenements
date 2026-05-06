import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/section_title.dart';
import 'signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final res = await AuthController().login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'DEVMOB',
      centerContent: true,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionTitle(
                      title: 'Connexion',
                      subtitle: 'Accedez aux evenements culturels et sportifs.',
                    ),
                    const SizedBox(height: 24),
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
                          return 'Entrez votre mot de passe';
                        }
                        if (v.length < 7) return 'Minimum 7 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Se connecter',
                      icon: Icons.login,
                      onPressed: doLogin,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupView()),
                        );
                      },
                      child: const Text('Creer un compte'),
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
