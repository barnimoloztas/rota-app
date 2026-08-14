import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';

void main() {
  group('StudentLearningSnapshot', () {
    test('stores graph version, calculation time, and topic states', () {
      final calculatedAt = DateTime.utc(2026, 8, 14, 9, 30);

      final functionsState = StudentTopicState(
        topicId: 'fonksiyonlar',
        hasEvidence: true,
        mastery: const Mastery(
          score: 72.0,
          confidence: 0.65,
        ),
        masteryBand: MasteryBand.developing,
        lastMeaningfulEvidenceAt: DateTime.utc(2026, 8, 13),
        calculatedAt: calculatedAt,
      );

      final snapshot = StudentLearningSnapshot(
        graphVersion: '1.0.0',
        calculatedAt: calculatedAt,
        topicStates: {
          'fonksiyonlar': functionsState,
        },
      );

      expect(snapshot.graphVersion, '1.0.0');
      expect(snapshot.calculatedAt, calculatedAt);
      expect(snapshot.topicStates, hasLength(1));
      expect(
        snapshot.topicStates['fonksiyonlar'],
        same(functionsState),
      );
    });

    test('can contain multiple topic states', () {
      final calculatedAt = DateTime.utc(2026, 8, 14, 9, 30);

      final snapshot = StudentLearningSnapshot(
        graphVersion: '1.0.0',
        calculatedAt: calculatedAt,
        topicStates: {
          'fonksiyonlar': StudentTopicState(
            topicId: 'fonksiyonlar',
            hasEvidence: true,
            mastery: const Mastery(
              score: 70.0,
              confidence: 0.7,
            ),
            masteryBand: MasteryBand.developing,
            lastMeaningfulEvidenceAt: DateTime.utc(2026, 8, 13),
            calculatedAt: calculatedAt,
          ),
          'limit_ve_sureklilik': StudentTopicState(
            topicId: 'limit_ve_sureklilik',
            hasEvidence: false,
            mastery: const Mastery(
              score: 0.0,
              confidence: 0.0,
            ),
            masteryBand: MasteryBand.notStarted,
            lastMeaningfulEvidenceAt: null,
            calculatedAt: calculatedAt,
          ),
        },
      );

      expect(snapshot.topicStates, hasLength(2));
      expect(
        snapshot.topicStates.containsKey('fonksiyonlar'),
        isTrue,
      );
      expect(
        snapshot.topicStates.containsKey('limit_ve_sureklilik'),
        isTrue,
      );
    });
  });
}