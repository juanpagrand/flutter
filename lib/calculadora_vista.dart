import 'package:flutter/material.dart';

import 'calculo.dart';

/// Convierte el `double` que devolvió el motor en el texto que se lee en
/// pantalla. Vive del lado de la **vista** a propósito: cuántos decimales se
/// muestran es una decisión de presentación, no de matemáticas.
///
/// Tres reglas, en este orden:
///   1. si no es un número válido → `Error`;
///   2. se redondea a 10 decimales para comer el ruido del binario, que es lo
///      que convierte `2.9999999999999996` en `3`;
///   3. si ya no tiene parte decimal se muestra como entero, para que diga
///      `10` y no `10.0`.
///
/// El tope de `1e15` de la regla 3 no es adorno: el `int` de Dart son 64 bits
/// y `1e30` no cabe. Por encima de ese tamaño se deja como `double` y Dart lo
/// escribe en notación científica (`1e+30`).
String mostrar(Calculo calculo, double resultado) {
  if (!calculo.esValido(resultado)) return 'Error';
  final limpio = double.parse(resultado.toStringAsFixed(10));
  if (limpio % 1 == 0 && limpio.abs() < 1e15) {
    return limpio.toInt().toString();
  }
  return limpio.toString();
}

/// Una tecla del teclado. No sabe qué operación representa ni qué hace: se
/// pinta y avisa. Quien decide es el padre — eso es *elevar el estado*, y es
/// la razón por la que este mismo widget sirve para un dígito, para `=` y
/// para `C`.
class BotonTecla extends StatelessWidget {
  const BotonTecla({
    super.key,
    required this.rotulo,
    required this.onTap,
    this.color,
    this.colorTexto,
  });

  final String rotulo;
  final VoidCallback onTap;
  final Color? color;
  final Color? colorTexto;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF2D2D44),
            foregroundColor: colorTexto ?? Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
          child: FittedBox(
            child: Text(
              rotulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

/// La pantalla de la calculadora. Guarda lo que se está tecleando y decide qué
/// hacer con cada tecla; las cuentas se las pide a [Calculo].
class CalculadoraVista extends StatefulWidget {
  const CalculadoraVista({super.key});

  @override
  State<CalculadoraVista> createState() => _CalculadoraVistaState();
}

class _CalculadoraVistaState extends State<CalculadoraVista> {
  final Calculo _calculo = Calculo();

  /// Lo que se lee en pantalla. Siempre texto: se va armando tecla a tecla.
  String _texto = '0';

  /// El operando que quedó guardado al tocar una operación binaria.
  double? _primerNumero;

  /// La operación pendiente: `+`, `-`, `×`, `÷` o `^`.
  String? _operacion;

  /// «El próximo dígito **empieza** un número, no continúa el anterior.»
  /// Sin esto, tocar `2`, `^`, `1` dejaría `21` en pantalla en vez de `1`.
  bool _nuevaEntrada = false;

  void _digito(String d) {
    setState(() {
      if (_texto == '0' || _nuevaEntrada) {
        _texto = d;
        _nuevaEntrada = false;
      } else {
        _texto = _texto + d;
      }
    });
  }

  /// El punto no usa la regla del cero (`0` + `.` es `0.`, no `.`), y no se
  /// puede repetir: `1..5` no es un número y reventaría al parsearlo.
  void _punto() {
    if (_texto == 'Error' || _nuevaEntrada) {
      setState(() {
        _texto = '0.';
        _nuevaEntrada = false;
      });
      return;
    }
    if (_texto.contains('.')) return;
    setState(() => _texto = '$_texto.');
  }

  /// Aplica la operación pendiente sobre [segundo] y devuelve el resultado.
  double _aplicar(double primero, String operacion, double segundo) {
    switch (operacion) {
      case '+':
        return _calculo.sumar(primero, segundo);
      case '−':
        return _calculo.restar(primero, segundo);
      case '×':
        return _calculo.multiplicar(primero, segundo);
      case '÷':
        return _calculo.dividir(primero, segundo);
      case '^':
        return _calculo.potencia(primero, segundo);
      default:
        return segundo;
    }
  }

  void _operar(String operacion) {
    final actual = double.tryParse(_texto);
    setState(() {
      // Encadenar: si ya había una operación a medias, se resuelve antes de
      // empezar la siguiente. Así `7 + 3 + 2 =` da 12 y no 5.
      if (_primerNumero != null && _operacion != null && !_nuevaEntrada &&
          actual != null) {
        final parcial = _aplicar(_primerNumero!, _operacion!, actual);
        _primerNumero = parcial;
        _texto = mostrar(_calculo, parcial);
      } else {
        _primerNumero = actual;
      }
      _operacion = operacion;
      _nuevaEntrada = true;
    });
  }

  void _igual() {
    if (_primerNumero == null || _operacion == null) return;
    final segundo = double.tryParse(_texto) ?? 0;
    final resultado = _aplicar(_primerNumero!, _operacion!, segundo);
    setState(() {
      _texto = mostrar(_calculo, resultado);
      _primerNumero = null;
      _operacion = null;
      _nuevaEntrada = true;
    });
  }

  /// Raíz, logaritmo decimal y logaritmo natural son **unarias**: actúan al
  /// instante sobre lo que hay en pantalla y no esperan al `=`.
  void _unaria(String operacion) {
    final n = double.tryParse(_texto);
    if (n == null) return; // la pantalla dice «Error»: no hay número que operar
    final double resultado;
    if (operacion == '√') {
      resultado = _calculo.raizCuadrada(n);
    } else if (operacion == 'log') {
      resultado = _calculo.log10(n);
    } else if (operacion == 'ln') {
      resultado = _calculo.ln(n);
    } else {
      return;
    }
    setState(() {
      _texto = mostrar(_calculo, resultado);
      _nuevaEntrada = true;
    });
  }

  void _limpiar() {
    setState(() {
      _texto = '0';
      _primerNumero = null;
      _operacion = null;
      _nuevaEntrada = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const fondo = Color(0xFF1E1E2C);
    const barra = Color(0xFF2D2D44);
    final cientifica = Colors.indigo.shade400;
    final operador = Colors.amber.shade800;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Calculadora'),
        backgroundColor: barra,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---- la pantalla ------------------------------------------------
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                // Un resultado largo (`10.295630141`) no cabe a 52 px en un
                // teléfono. `scaleDown` lo encoge hasta que quepa entero, en
                // vez de recortarlo: es preferible leerlo pequeño a no ver los
                // primeros dígitos.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _texto,
                    key: const Key('pantalla'),
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // ---- el teclado -------------------------------------------------
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // fila científica
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BotonTecla(
                            rotulo: '√',
                            color: cientifica,
                            onTap: () => _unaria('√'),
                          ),
                          BotonTecla(
                            rotulo: 'xʸ',
                            color: cientifica,
                            onTap: () => _operar('^'),
                          ),
                          BotonTecla(
                            rotulo: 'log',
                            color: cientifica,
                            onTap: () => _unaria('log'),
                          ),
                          BotonTecla(
                            rotulo: 'ln',
                            color: cientifica,
                            onTap: () => _unaria('ln'),
                          ),
                        ],
                      ),
                    ),
                    // números a la izquierda, operadores en la columna derecha
                    Expanded(
                      flex: 4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                    BotonTecla(rotulo: '7', onTap: () => _digito('7')),
                                    BotonTecla(rotulo: '8', onTap: () => _digito('8')),
                                    BotonTecla(rotulo: '9', onTap: () => _digito('9')),
                                  ]),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                    BotonTecla(rotulo: '4', onTap: () => _digito('4')),
                                    BotonTecla(rotulo: '5', onTap: () => _digito('5')),
                                    BotonTecla(rotulo: '6', onTap: () => _digito('6')),
                                  ]),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                    BotonTecla(rotulo: '1', onTap: () => _digito('1')),
                                    BotonTecla(rotulo: '2', onTap: () => _digito('2')),
                                    BotonTecla(rotulo: '3', onTap: () => _digito('3')),
                                  ]),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                    BotonTecla(
                                      rotulo: 'C',
                                      color: Colors.redAccent.shade700,
                                      onTap: _limpiar,
                                    ),
                                    BotonTecla(rotulo: '0', onTap: () => _digito('0')),
                                    BotonTecla(rotulo: '.', onTap: _punto),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                BotonTecla(
                                  rotulo: '÷',
                                  color: operador,
                                  onTap: () => _operar('÷'),
                                ),
                                BotonTecla(
                                  rotulo: '×',
                                  color: operador,
                                  onTap: () => _operar('×'),
                                ),
                                BotonTecla(
                                  rotulo: '−',
                                  color: operador,
                                  onTap: () => _operar('−'),
                                ),
                                BotonTecla(
                                  rotulo: '+',
                                  color: operador,
                                  onTap: () => _operar('+'),
                                ),
                                BotonTecla(
                                  rotulo: '=',
                                  color: Colors.green.shade700,
                                  onTap: _igual,
                                ),
                              ],
                            ),
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
}
