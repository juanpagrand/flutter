# Calculadora científica

App en Flutter con las cuatro operaciones básicas más potenciación, raíz
cuadrada, logaritmo decimal y logaritmo natural.

## Cómo está organizada

| Archivo | Responsabilidad |
|---|---|
| `lib/main.dart` | `runApp` y la `MaterialApp` |
| `lib/calculo.dart` | **el motor**: solo matemáticas, ni un widget |
| `lib/calculadora_vista.dart` | **la pantalla**: estado, teclado y formateo |
| `test/calculadora_test.dart` | 23 pruebas: motor, formateo e interfaz |

La separación entre `Calculo` y la vista no es decoración: una clase sin
Flutter adentro se prueba sin montar interfaz ni abrir un emulador. Por eso
nueve de las 23 pruebas corren en milisegundos.

## Operaciones

- `+` `−` `×` `÷`, encadenadas (`7 + 3 + 2 =` da 12)
- `xʸ` — potenciación, binaria
- `√` `log` `ln` — unarias: actúan al instante sobre lo que hay en pantalla
- `.` — punto decimal, que no se puede repetir
- `C` — limpia también la operación pendiente

## Detalles que el código resuelve a propósito

En Dart, un resultado imposible **no lanza excepción**: `5 / 0` vale
`Infinity` y `√(-4)` vale `NaN`. Hay que preguntarlo, y de eso se encarga
`Calculo.esValido` con `isFinite`; la pantalla muestra `Error` y el siguiente
dígito empieza un número nuevo.

`math.pow` devuelve `num`, no `double`, y con enteros se desborda en silencio:
`pow(1000, 10)` da `5076944270305263616` en vez de 10³⁰. Por eso el motor
trabaja siempre con `double`.

`log(1000) / log(10)` da `2.9999999999999996`, no 3. El motor devuelve ese
número tal cual — redondear es trabajo de la pantalla, y lo hace `mostrar`.

## Correr y probar

```
flutter pub get
flutter run
flutter test
```

Requiere el SDK que declara `pubspec.yaml` (`environment: sdk: ^3.13.2`, es
decir Flutter 3.35 o superior).
