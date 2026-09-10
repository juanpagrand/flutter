import 'dart:math' as math;

/// El motor de la calculadora: **solo matemáticas, ni un solo widget**.
///
/// Está aparte de la vista a propósito. Una clase sin Flutter adentro se puede
/// probar sin montar interfaz ni abrir un emulador, que es mucho más rápido y
/// mucho más barato que probar una pantalla.
///
/// Todos los métodos trabajan con `double`. No es capricho: `math.pow` con
/// enteros devuelve un `int` de 64 bits que se desborda en silencio
/// (`math.pow(1000, 10)` da 5076944270305263616, que no es 10³⁰). Con `double`
/// entra y sale `double`, y el resultado es correcto.
class Calculo {
  double sumar(double a, double b) => a + b;

  double restar(double a, double b) => a - b;

  double multiplicar(double a, double b) => a * b;

  /// Ojo: entre `double`, dividir por cero **no lanza excepción**.
  /// `5.0 / 0.0` vale `Infinity`. Por eso existe [esValido].
  double dividir(double a, double b) => a / b;

  /// `math.pow` devuelve `num` (el padre de `int` y `double`), así que hay que
  /// convertirlo o el tipo de retorno no cuadra.
  double potencia(double base, double exponente) =>
      math.pow(base, exponente).toDouble();

  /// `math.sqrt(-4)` devuelve `NaN`, tampoco lanza. Se pregunta con [esValido].
  double raizCuadrada(double a) => math.sqrt(a);

  /// Logaritmo natural (base *e*). Es el único que trae `dart:math`.
  double ln(double a) => math.log(a);

  /// Logaritmo decimal, por cambio de base: `log_b(x) = ln(x) / ln(b)`.
  ///
  /// El resultado arrastra el ruido del binario: `log10(1000)` da
  /// `2.9999999999999996`, no 3. Eso **no se arregla aquí**: el motor devuelve
  /// el número que salió de la operación. Redondear es trabajo de la pantalla.
  double log10(double a) => math.log(a) / math.log(10);

  /// Qué cuenta como resultado válido. Es una regla matemática, por eso vive
  /// en el motor y no en la vista.
  ///
  /// `isFinite` es `false` para `NaN` **y** para los dos infinitos: una sola
  /// pregunta cubre los tres casos. Con `isNaN` a secas se colaría la división
  /// por cero.
  bool esValido(double r) => r.isFinite;

  /// Determina si un número es par.
  ///
  /// Devuelve `true` si es entero y par, `false` si es entero e impar,
  /// o `null` si no es finito, tiene parte decimal o excede el rango de
  /// representación entera de 64 bits.
  bool? esPar(double r) {
    if (!esValido(r)) return null;
    final limpio = double.parse(r.toStringAsFixed(10));
    if (limpio % 1 == 0 && limpio.abs() < 1e15) {
      return limpio.toInt().abs() % 2 == 0;
    }
    return null;
  }

  /// Devuelve `'Par'`, `'Impar'`, o `null` si el número no tiene paridad
  /// aplicable (números con decimales, errores o desbordados).
  String? paridad(double r) {
    final par = esPar(r);
    if (par == null) return null;
    return par ? 'Par' : 'Impar';
  }
}
