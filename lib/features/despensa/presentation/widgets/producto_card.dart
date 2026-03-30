import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    // Extraemos la lógica de urgencia
    final bool esUrgente = producto.urgente;
    
    // Si es urgente, usamos el naranja (accent), si no, usamos el verde (green)
    final Color colorEstado = esUrgente ? AppColors.accent : AppColors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card, // Blanco puro
        borderRadius: BorderRadius.circular(20), // Un poco más curvo para verse moderno
        border: !esUrgente 
            ? Border.all(color: AppColors.border.withValues(alpha: 0.5)) 
            : null, // Quitamos el borde si es urgente para que brille la sombra
        boxShadow: [
          if (esUrgente)
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25), // Resplandor naranja
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // Sombra sutil casi invisible
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Emoji
          Text(producto.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),

          // Nombre y cantidad
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${producto.cantidad} · ${producto.categoria}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Badge de días (Cambiado a un estilo de "píldora" más limpio)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${producto.diasRestantes}d ${esUrgente ? "⚠️" : ""}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: colorEstado,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}