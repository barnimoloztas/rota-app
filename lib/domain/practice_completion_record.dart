import 'topic.dart';

class PracticeCompletionRecord {
  PracticeCompletionRecord({
    required this.topicId,
    required this.completedAt,
    this.actualQuestionCount,
    this.correctCount,
    this.wrongCount,
    this.blankCount,
  })  : assert(
          actualQuestionCount == null || actualQuestionCount >= 0,
        ),
        assert(
          correctCount == null || correctCount >= 0,
        ),
        assert(
          wrongCount == null || wrongCount >= 0,
        ),
        assert(
          blankCount == null || blankCount >= 0,
        ),
        assert(
          (correctCount == null &&
                  wrongCount == null &&
                  blankCount == null) ||
              (correctCount != null &&
                  wrongCount != null &&
                  blankCount != null),
        ),
        assert(
          correctCount == null || actualQuestionCount != null,
        ),
        assert(
          correctCount == null ||
              correctCount + wrongCount! + blankCount! ==
                  actualQuestionCount,
        );

  final TopicId topicId;

  final DateTime completedAt;

  /// Actual number of questions the student reports solving.
  ///
  /// Null means the Practice was completed without reporting
  /// a question count.
  final int? actualQuestionCount;

  /// Correct / wrong / blank details are optional as a group.
  ///
  /// If one is present, all three must be present.
  final int? correctCount;

  final int? wrongCount;

  final int? blankCount;
}