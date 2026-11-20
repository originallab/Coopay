const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

const _mesesCorto = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String formatoFechaHora(DateTime d) {
  final hora = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '${d.day} de ${_meses[d.month - 1]}, $hora:$min';
}

String formatoHora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String formatoFecha(DateTime d) => '${d.day} ${_mesesCorto[d.month - 1]} ${d.year}';

bool esHoy(DateTime d) {
  final ahora = DateTime.now();
  return d.year == ahora.year && d.month == ahora.month && d.day == ahora.day;
}
