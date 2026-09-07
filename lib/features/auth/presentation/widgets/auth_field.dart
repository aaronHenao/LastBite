import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: textTheme.titleMedium?.copyWith(
        color: context.paleta.marca,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon != null 
            ? IconTheme(
                data: IconThemeData(color: context.paleta.marca),
                child: suffixIcon!,
              )
            : null,
        filled: true,
        fillColor: context.paleta.superficie, 
        
        labelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.paleta.marca.withValues(alpha: 0.7), 
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: context.paleta.marca.withValues(alpha: 0.5),
        ),
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.paleta.marca),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.paleta.marca),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.paleta.marca, width: 2.0),
        ),
      ),
    );
  }
}