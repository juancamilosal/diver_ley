/// Utilidades de fechas para la racha y la liga.
library;

/// Día del calendario en formato `aaaa-mm-dd`, sin hora.
String diaDe(DateTime fecha) {
  final m = fecha.month.toString().padLeft(2, '0');
  final d = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year}-$m-$d';
}

DateTime _soloDia(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

/// Días de calendario entre dos fechas (sin contar horas).
int diasEntre(DateTime desde, DateTime hasta) =>
    _soloDia(hasta).difference(_soloDia(desde)).inHours ~/ 24;

/// Días que faltan para que cierre la liga (domingo a medianoche).
int diasParaCierreDeLiga(DateTime ahora) {
  final faltan = DateTime.sunday - ahora.weekday;
  return faltan == 0 ? 1 : faltan + 1;
}

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Fecha corta en español: `13 nov 2026`.
String fechaCorta(DateTime fecha) =>
    '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';

/// Fecha y hora: `13 nov 2026, 10:42 a. m.`.
String fechaHora(DateTime fecha) {
  final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final min = fecha.minute.toString().padLeft(2, '0');
  final ampm = fecha.hour < 12 ? 'a. m.' : 'p. m.';
  return '${fechaCorta(fecha)}, $h:$min $ampm';
}
