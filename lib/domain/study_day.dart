class StudyDay {
  const StudyDay({
    required this.date,
  });

  /// Calendar date that identifies this study day.
  ///
  /// Only year, month and day are semantically meaningful.
  final DateTime date;
}

class StudyDayContext {
  const StudyDayContext({
    required this.now,
    required this.lastManualAdvanceAt,
  });

  /// Current local date and time for the student.
  final DateTime now;

  /// Most recent time the student explicitly selected
  /// "Yeni güne geç".
  ///
  /// Null when the student has not manually advanced.
  final DateTime? lastManualAdvanceAt;
}

StudyDay resolveStudyDay(
  StudyDayContext context,
) {
  final today = _dateOnly(context.now);

  // 08:00 or later always belongs to today's study day.
  if (context.now.hour >= 8) {
    return StudyDay(
      date: today,
    );
  }

  final manualAdvanceAt = context.lastManualAdvanceAt;

  // Before 08:00, a manual "Yeni güne geç" action made
  // during the current calendar day starts today's study day early.
  if (manualAdvanceAt != null &&
      _isSameCalendarDate(
        manualAdvanceAt,
        context.now,
      )) {
    return StudyDay(
      date: today,
    );
  }

  // Before 08:00 and without a manual advance,
  // the previous calendar day's study day continues.
  return StudyDay(
    date: today.subtract(
      const Duration(days: 1),
    ),
  );
}

DateTime _dateOnly(
  DateTime value,
) {
  return DateTime(
    value.year,
    value.month,
    value.day,
  );
}

bool _isSameCalendarDate(
  DateTime a,
  DateTime b,
) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}