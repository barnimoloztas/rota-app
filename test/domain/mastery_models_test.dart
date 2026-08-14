import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_topic_state.dart';

void main() {
  group('Mastery', () {
    test('stores score and confidence independently', () {
      const mastery = Mastery(
        score: 82.0,
        confidence: 0.35,
      );

      expect(mastery.score, 82.0);
      expect(mastery.confidence, 0.35);
    });
  });

  group('MasteryBand', () {
    test('contains the five semantic mastery bands', () {
      expect(
        MasteryBand.values,
        [
          MasteryBand.notStarted,
          MasteryBand.learning,
          MasteryBand.developing,
          MasteryBand.proficient,
          MasteryBand.consolidated,
        ],
      );
    });
  });

  group('StudentTopicState', () {
    test('can represent an untouched topic', () {
      final calculatedAt = DateTime.utc(2026, 8, 14);

      final state = StudentTopicState(
        topicId: 'fonksiyonlar',
        hasEvidence: false,
        mastery: const Mastery(
          score: 0.0,
          confidence: 0.0,
        ),
        lastMeaningfulEvidenceAt: null,
        calculatedAt: calculatedAt,
      );

      expect(state.topicId, 'fonksiyonlar');
      expect(state.hasEvidence, isFalse);
      expect(state.lastMeaningfulEvidenceAt, isNull);
      expect(state.mastery.score, 0.0);
      expect(state.mastery.confidence, 0.0);
    });

    test('can represent touched but uncertain state', () {
      final evidenceAt = DateTime.utc(2026, 8, 13);
      final calculatedAt = DateTime.utc(2026, 8, 14);

      final state = StudentTopicState(
        topicId: 'limit_ve_sureklilik',
        hasEvidence: true,
        mastery: const Mastery(
          score: 28.0,
          confidence: 0.18,
        ),
        lastMeaningfulEvidenceAt: evidenceAt,
        calculatedAt: calculatedAt,
      );

      expect(state.hasEvidence, isTrue);
      expect(state.mastery.score, 28.0);
      expect(state.mastery.confidence, 0.18);
      expect(state.lastMeaningfulEvidenceAt, evidenceAt);
    });

    test('can represent high score with low confidence', () {
      final evidenceAt = DateTime.utc(2026, 6, 1);
      final calculatedAt = DateTime.utc(2026, 8, 14);

      final state = StudentTopicState(
        topicId: 'turev',
        hasEvidence: true,
        mastery: const Mastery(
          score: 88.0,
          confidence: 0.22,
        ),
        lastMeaningfulEvidenceAt: evidenceAt,
        calculatedAt: calculatedAt,
      );

      expect(state.mastery.score, greaterThan(80.0));
      expect(state.mastery.confidence, lessThan(0.3));
    });
  });
}