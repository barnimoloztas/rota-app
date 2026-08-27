class TytSocialReinforcementLifecycle {
  const TytSocialReinforcementLifecycle({
    required this.startedAt,
    required this.lastReinforcementCompletedAt,
  });

  /// Completion time of the first real Practice among TYT Social subjects.
  final DateTime startedAt;

  /// Completion time of the most recent common TYT Social reinforcement.
  final DateTime? lastReinforcementCompletedAt;
}
