import '../../domain/tyt_social_reinforcement_lifecycle.dart';

const _tytSocialReinforcementInterval = Duration(days: 45);

bool isTytSocialReinforcementDue({
  required TytSocialReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  final anchor = lifecycle.lastReinforcementCompletedAt ?? lifecycle.startedAt;
  final dueAt = anchor.add(_tytSocialReinforcementInterval);

  return !evaluatedAt.isBefore(dueAt);
}
