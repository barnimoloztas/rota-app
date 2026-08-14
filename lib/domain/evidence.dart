import 'topic.dart';

enum EvidenceChannel {
  studyTime,
  practiceVolume,
  practicePerformance,
  examPerformance,
}

class Evidence {
  const Evidence({
    required this.topicId,
    required this.channel,
    required this.observedAt,
    required this.value,
  });

  /// Topic this evidence belongs to.
  final TopicId topicId;

  /// The academic evidence channel.
  final EvidenceChannel channel;

  /// When the observation actually happened.
  final DateTime observedAt;

  /// Normalized evidence value.
  ///
  /// Interpretation depends on [channel].
  /// This is raw evidence, not mastery score.
  final double value;
}