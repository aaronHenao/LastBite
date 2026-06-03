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
      // Color del texto que escribe el usuario (Verde principal)
      style: textTheme.titleMedium?.copyWith(
        color: AppColors.green,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        // Forzamos a que el icono del ojo (o cualquier otro) herede el color verde
        suffixIcon: suffixIcon != null 
            ? IconTheme(
                data: const IconThemeData(color: AppColors.green),
                child: suffixIcon!,
              )
            : null,
        filled: true,
        // Fondo blanco puro como el botón secundario del diseño
        fillColor: AppColors.card, 
        
        // Color de las etiquetas y hints alineados al verde de la marca
        labelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.green.withValues(alpha: 0.7), // Un tono verde suave para el label
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.green.withValues(alpha: 0.5),
        ),
        
        // Bordes redondeados con la línea en el verde principal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green),
        ),
        // Cuando el usuario hace clic, el borde se vuelve un poco más grueso
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 2.0),
        ),
      ),
    );
  }
}