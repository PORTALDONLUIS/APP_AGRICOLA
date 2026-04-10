/// Zona operativa de campo: Perú (UTC−5, sin horario de verano).
///
/// [fechaEjecucion] se guarda como epoch UTC en ms; el **día civil** del trabajo
/// debe alinearse con este offset, no con la medianoche UTC (evita “mañana”
/// entre ~19:00 y 24:00 hora Perú).
const Duration kOperationalUtcOffsetPeru = Duration(hours: 5);

/// Calendario (año/mes/día) del día operativo en Perú (UTC−5) para un instante UTC.
DateTime operationalYearMonthDayUtc5(DateTime utcInstant) {
  final shifted = utcInstant.subtract(kOperationalUtcOffsetPeru);
  return DateTime.utc(shifted.year, shifted.month, shifted.day);
}

/// `true` si [utcInstant] cae el mismo día civil operativo (PE) que [calendarDay].
///
/// [calendarDay] suele ser la fecha elegida en el reporte (`DateTime(y,m,d)` en el dispositivo).
bool isSameOperationalCalendarDayUtc5(DateTime utcInstant, DateTime calendarDay) {
  final op = operationalYearMonthDayUtc5(utcInstant);
  final d = DateTime.utc(calendarDay.year, calendarDay.month, calendarDay.day);
  return op.year == d.year && op.month == d.month && op.day == d.day;
}
