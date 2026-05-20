import 'package:flutter/material.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import 'login_view.dart';

class SignupSuccessView extends StatelessWidget {
  const SignupSuccessView({super.key});

  void _continueToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Compte cree',
      centerContent: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 78,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  'Votre compte a ete cree avec succes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous pouvez maintenant vous connecter avec vos identifiants.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Continuer',
                  icon: Icons.arrow_forward,
                  onPressed: () => _continueToLogin(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
