import 'package:flutter/material.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LastBite',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const DespensaScreen(),

    );
  }
}