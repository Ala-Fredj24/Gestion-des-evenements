import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
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
    this.maxLines = 1,
    this.onTap,
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
      maxLines: obscureText ? 1 : maxLines,
      onTap: onTap,
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
