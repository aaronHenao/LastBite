import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    
    final bool esUrgente = producto.urgente;
    
    
    final Color colorEstado = esUrgente ? AppColors.accent : AppColors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card, 
        borderRadius: BorderRadius.circular(20),
        border: !esUrgente 
            ? Border.all(color: AppColors.border.withValues(alpha: 0.5)) 
            : null, 
        boxShadow: [
          if (esUrgente)
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25), 
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), 
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          
          Text(producto.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),

          
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