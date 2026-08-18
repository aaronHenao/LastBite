import 'package:flutter/material.dart';
import 'responsive.dart';

//envuelve el contenido y lo centra con ancho máximo en tablet/web
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContainer({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentWidth(context),
        ),
        child: child,
      ),
    );
  }
}