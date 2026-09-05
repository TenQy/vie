import 'package:intl/intl.dart';

abstract final class DateHelpers {
  /// Returns the current day of the week as 1 (Monday) to 7 (Sunday).
  static int get currentDayOfWeek => DateTime.now().weekday;

  /// Returns Spanish name for day of week (1..7).
  static String getDayName(int day) {
    return switch (day) {
      DateTime.monday => 'Lunes',
      DateTime.tuesday => 'Martes',
      DateTime.wednesday => 'Miércoles',
      DateTime.thursday => 'Jueves',
      DateTime.friday => 'Viernes',
      DateTime.saturday => 'Sábado',
      DateTime.sunday => 'Domingo',
      _ => 'Día Libre',
    };
  }

  /// Formats seconds into mm:ss or hh:mm:ss.
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hStr = hours.toString().padLeft(2, '0');
      return '$hStr:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }

  /// Formats a DateTime into a friendly date string (e.g., "5 de Septiembre, 2026").
  static String formatFriendlyDate(DateTime date) {
    return DateFormat('d \'de\' MMMM, yyyy', 'es').format(date);
  }
}
