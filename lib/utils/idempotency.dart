import 'dart:math';

/// Clave única por intento de cobro/transferencia — nunca se reusa entre
/// envíos distintos del formulario (03-seguridad.md punto 13: nunca cobrar
/// dos veces por reintento de red). Se genera una sola vez por pantalla, no
/// en cada submit, así un reintento tras un error de red reenvía la misma.
String generarClaveIdempotencia() {
  final ts = DateTime.now().microsecondsSinceEpoch;
  final suffix = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return 'idem_${ts.toRadixString(36)}$suffix';
}
