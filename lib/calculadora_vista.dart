import 'package:flutter/material.dart';
import 'calculo.dart';

/// Clase encargada de la vista de la calculadora (Interfaz de Usuario)
class CalculadoraVista extends StatefulWidget {
  const CalculadoraVista({super.key});

  @override
  State<CalculadoraVista> createState() => _CalculadoraVistaState();
}

class _CalculadoraVistaState extends State<CalculadoraVista> {
  // Instancia de la clase de cálculos
  final Calculo _calculo = Calculo();

  String _pantalla = '0';
  double? _primerNumero;
  String? _operacion; // '+' o '-'
  bool _nuevaEntrada = false;

  void _presionarNumero(String numero) {
    setState(() {
      if (_pantalla == '0' || _nuevaEntrada) {
        _pantalla = numero;
        _nuevaEntrada = false;
      } else {
        _pantalla += numero;
      }
    });
  }

  void _presionarOperacion(String op) {
    setState(() {
      _primerNumero = double.tryParse(_pantalla);
      _operacion = op;
      _nuevaEntrada = true;
    });
  }

  void _calcularResultado() {
    if (_primerNumero == null || _operacion == null) return;

    double segundoNumero = double.tryParse(_pantalla) ?? 0;
    double resultado = 0;

    // Acceso a los métodos de la clase Calculo
    if (_operacion == '+') {
      resultado = _calculo.sumar(_primerNumero!, segundoNumero);
    } else if (_operacion == '-') {
      resultado = _calculo.restar(_primerNumero!, segundoNumero);
    }

    setState(() {
      // Formatear el resultado para ocultar el .0 si es un número entero
      _pantalla = resultado % 1 == 0
          ? resultado.toInt().toString()
          : resultado.toString();
      _primerNumero = null;
      _operacion = null;
      _nuevaEntrada = true;
    });
  }

  void _limpiar() {
    setState(() {
      _pantalla = '0';
      _primerNumero = null;
      _operacion = null;
      _nuevaEntrada = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Calculadora', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D2D44),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pantalla de la calculadora
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Text(
                  _pantalla,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 10),
            // Teclado con los números y los botones de operación (+ / -) al lado
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Teclado de números
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _botonNumero('7'),
                                _botonNumero('8'),
                                _botonNumero('9'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                _botonNumero('4'),
                                _botonNumero('5'),
                                _botonNumero('6'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                _botonNumero('1'),
                                _botonNumero('2'),
                                _botonNumero('3'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                _botonAccion('C', Colors.redAccent, _limpiar),
                                _botonNumero('0'),
                                _botonAccion('=', Colors.greenAccent.shade700, _calcularResultado),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Botones de Operación (+ y -) ubicados al lado de los números
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            child: _botonOperacion('+'),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _botonOperacion('-'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonNumero(String texto) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D2D44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () => _presionarNumero(texto),
          child: Text(
            texto,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _botonOperacion(String op) {
    final bool estaSeleccionado = _operacion == op;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: estaSeleccionado ? Colors.amber.shade700 : Colors.amber.shade800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _presionarOperacion(op),
          child: Text(
            op,
            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _botonAccion(String texto, Color color, VoidCallback accion) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: accion,
          child: Text(
            texto,
            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
