import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/selected_mode.dart';
import 'package:rota_app/engine/practice/practice_question_target_policy.dart';

void main() {
  group('practiceQuestionTargetForMode', () {
    test('relaxed mode targets 30 questions', () {
      expect(
        practiceQuestionTargetForMode(SelectedMode.relaxed),
        30,
      );
    });

    test('balanced mode targets 40 questions', () {
      expect(
        practiceQuestionTargetForMode(SelectedMode.balanced),
        40,
      );
    });

    test('strict mode targets 60 questions', () {
      expect(
        practiceQuestionTargetForMode(SelectedMode.strict),
        60,
      );
    });
  });
}