import 'topic.dart';

class TopicExamProfile {
  const TopicExamProfile({
    required this.topicId,
    required this.examImportance,
  }) : assert(
          examImportance >= 0.0 &&
              examImportance <= 1.0,
        );

  /// Topic this exam profile belongs to.
  final TopicId topicId;

  /// Normalized importance of this topic for exam-oriented ranking.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is an input to ranking, not a final ranking score.
  final double examImportance;
}