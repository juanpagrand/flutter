import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/calculadora_vista.dart';
import 'package:flutter_application_1/calculo.dart';

/// Lee el texto que se está mostrando en la pantalla de la calculadora.
String pantalla(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('pantalla'))).data!;

/// Toca una tecla por su rótulo.
Future<void> tocar(WidgetTester tester, String rotulo) async {
  await tester.tap(find.widgetWithText(ElevatedButton, rotulo));
  await tester.pump();
}

/// Teclea una secuencia completa, tecla por tecla.
Future<void> teclear(WidgetTester tester, List<String> teclas) async {
  for (final t in teclas) {
    await tocar(tester, t);
  }
}

void main() {
  // ---------------------------------------------------------------- el motor
  group('Calculo', () {
    final c = Calculo();

    test('las cuatro operaciones básicas', () {
      expect(c.sumar(7, 3), 10.0);
      expect(c.restar(7, 3), 4.0);
      expect(c.multiplicar(7, 3), 21.0);
      expect(c.dividir(7, 2), 3.5);
    });

    test('potencia devuelve double, no el int desbordado de pow', () {
      expect(c.potencia(2, 10), 1024.0);
      expect(c.potencia(1000, 10), 1e30);
      expect(c.potencia(9, 0.5), 3.0);
    });

    test('raíz y logaritmos', () {
      expect(c.raizCuadrada(16), 4.0);
      expect(c.ln(1), 0.0);
      expect(c.log10(100), 2.0);
      // el ruido del binario es real: log10(1000) no da 3 exacto
      expect(c.log10(1000), closeTo(3.0, 1e-9));
      expect(c.log10(1000) == 3.0, isFalse);
    });

    test('los resultados imposibles no lanzan: se preguntan', () {
      expect(c.dividir(5, 0), double.infinity);
      expect(c.raizCuadrada(-9).isNaN, isTrue);
      expect(c.ln(0), double.negativeInfinity);

      expect(c.esValido(c.dividir(5, 0)), isFalse);
      expect(c.esValido(c.raizCuadrada(-9)), isFalse);
      expect(c.esValido(c.ln(0)), isFalse);
      expect(c.esValido(c.sumar(7, 3)), isTrue);
    });
  });

  // ------------------------------------------------------------- el formateo
  group('mostrar', () {
    final c = Calculo();

    test('quita el .0 de los enteros', () {
      expect(mostrar(c, 10.0), '10');
      expect(mostrar(c, -4.0), '-4');
    });

    test('doma el ruido del binario', () {
      expect(mostrar(c, 2.9999999999999996), '3');
      expect(mostrar(c, 0.1 + 0.2), '0.3');
    });

    test('respeta los decimales de verdad', () {
      expect(mostrar(c, 3.5), '3.5');
      expect(mostrar(c, 1.4142135623730951), '1.4142135624');
    });

    test('lo que no cabe en un int se queda en notación científica', () {
      expect(mostrar(c, 1e30), '1e+30');
    });

    test('lo imposible se llama Error', () {
      expect(mostrar(c, double.infinity), 'Error');
      expect(mostrar(c, double.nan), 'Error');
    });
  });

  // -------------------------------------------------------------- la pantalla
  group('CalculadoraVista', () {
    Future<void> montar(WidgetTester tester) =>
        tester.pumpWidget(const MaterialApp(home: CalculadoraVista()));

    testWidgets('arranca en cero', (tester) async {
      await montar(tester);
      expect(pantalla(tester), '0');
    });

    testWidgets('los dígitos se concatenan y el 0 se reemplaza', (tester) async {
      await montar(tester);
      await teclear(tester, ['7', '8']);
      expect(pantalla(tester), '78');
    });

    testWidgets('el punto decimal entra una sola vez', (tester) async {
      await montar(tester);
      await teclear(tester, ['1', '.', '5', '.', '2']);
      expect(pantalla(tester), '1.52');
    });

    testWidgets('7 + 3 = 10', (tester) async {
      await montar(tester);
      await teclear(tester, ['7', '+', '3', '=']);
      expect(pantalla(tester), '10');
    });

    testWidgets('operaciones encadenadas: 7 + 3 + 2 = 12', (tester) async {
      await montar(tester);
      await teclear(tester, ['7', '+', '3', '+', '2', '=']);
      expect(pantalla(tester), '12');
    });

    testWidgets('el segundo operando empieza limpio', (tester) async {
      await montar(tester);
      await teclear(tester, ['2', '+', '1']);
      expect(pantalla(tester), '1'); // no «21»
    });

    testWidgets('2 elevado a 10 da 1024', (tester) async {
      await montar(tester);
      await teclear(tester, ['2', 'xʸ', '1', '0', '=']);
      expect(pantalla(tester), '1024');
    });

    testWidgets('la raíz es unaria: no espera al =', (tester) async {
      await montar(tester);
      await teclear(tester, ['1', '6', '√']);
      expect(pantalla(tester), '4');
    });

    testWidgets('log de 1000 da 3, no 2,999…', (tester) async {
      await montar(tester);
      await teclear(tester, ['1', '0', '0', '0', 'log']);
      expect(pantalla(tester), '3');
    });

    testWidgets('ln de 1 da 0', (tester) async {
      await montar(tester);
      await teclear(tester, ['1', 'ln']);
      expect(pantalla(tester), '0');
    });

    testWidgets('dividir por cero muestra Error y no tumba la app',
        (tester) async {
      await montar(tester);
      await teclear(tester, ['5', '÷', '0', '=']);
      expect(pantalla(tester), 'Error');
    });

    testWidgets('la raíz de un negativo también es Error', (tester) async {
      await montar(tester);
      await teclear(tester, ['9', '−', '1', '0', '=', '√']);
      expect(pantalla(tester), 'Error');
    });

    testWidgets('un dígito después del Error empieza de nuevo', (tester) async {
      await montar(tester);
      await teclear(tester, ['5', '÷', '0', '=', '7']);
      expect(pantalla(tester), '7'); // no «Error7»
    });

    testWidgets('C borra también la operación pendiente', (tester) async {
      await montar(tester);
      await teclear(tester, ['7', '+', 'C', '=']);
      expect(pantalla(tester), '0');
    });
  });
}
