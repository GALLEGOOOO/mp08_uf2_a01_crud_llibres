import 'package:flutter/material.dart';
import 'views/notes/llista_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Llibres',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LlistaLlibres(), // Canviem per apuntar a la nova classe.
    );
  }
}
