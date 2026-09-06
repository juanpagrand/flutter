import 'package:flutter/material.dart';

import 'calculadora_vista.dart';

/// Punto de entrada. `runApp` recibe **un** widget y lo cuelga de la raíz del
/// árbol; de ahí para abajo todo son hijos suyos. `build()` no se llama a
/// mano: lo llama Flutter, y lo vuelve a llamar cada vez que un `setState`
/// dice que algo cambió.
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Calculadora',
      // quita la cinta roja de «DEBUG» de la esquina
      debugShowCheckedModeBanner: false,
      home: CalculadoraVista(),
    );
  }
}
