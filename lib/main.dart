import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const EcoSpaceApp());
}

class EcoSpaceApp extends StatelessWidget {
  const EcoSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECO SPACE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D5016),
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}
