import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: outlined ? Theme.of(context).colorScheme.primary : Colors.white,
      ),
    );

    final content = isLoading
        ? spinner
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
  }
}
