class DailyStudyBudget {
  const DailyStudyBudget({
    required this.availableMinutes,
  }) : assert(availableMinutes >= 0);

  /// Total study time the student wants to allocate
  /// to the current study day.
  final int availableMinutes;

  bool get hasNoAvailableTime => availableMinutes == 0;
}