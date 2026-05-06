import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.onTap,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? null : minLines,
      onTap: onTap,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
