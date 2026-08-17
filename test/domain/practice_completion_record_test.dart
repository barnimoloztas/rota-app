import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/practice_completion_record.dart';

void main() {
  group('PracticeCompletionRecord', () {
    test('can record completion without question details', () {
      final completedAt = DateTime.utc(2026, 8, 17);

      final record = PracticeCompletionRecord(
        topicId: 'fonksiyonlar',
        completedAt: completedAt,
      );

      expect(record.topicId, 'fonksiyonlar');
      expect(record.completedAt, completedAt);
      expect(record.actualQuestionCount, isNull);
      expect(record.correctCount, isNull);
      expect(record.wrongCount, isNull);
      expect(record.blankCount, isNull);
    });

    test('can record actual question count without performance details', () {
      final record = PracticeCompletionRecord(
        topicId: 'fonksiyonlar',
        completedAt: DateTime.utc(2026, 8, 17),
        actualQuestionCount: 32,
      );

      expect(record.actualQuestionCount, 32);
      expect(record.correctCount, isNull);
      expect(record.wrongCount, isNull);
      expect(record.blankCount, isNull);
    });

    test('can record complete question performance details', () {
      final record = PracticeCompletionRecord(
        topicId: 'fonksiyonlar',
        completedAt: DateTime.utc(2026, 8, 17),
        actualQuestionCount: 32,
        correctCount: 24,
        wrongCount: 6,
        blankCount: 2,
      );

      expect(record.actualQuestionCount, 32);
      expect(record.correctCount, 24);
      expect(record.wrongCount, 6);
      expect(record.blankCount, 2);
    });

    test('rejects negative question counts', () {
      expect(
        () => PracticeCompletionRecord(
          topicId: 'fonksiyonlar',
          completedAt: DateTime.utc(2026, 8, 17),
          actualQuestionCount: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects partial performance details', () {
      expect(
        () => PracticeCompletionRecord(
          topicId: 'fonksiyonlar',
          completedAt: DateTime.utc(2026, 8, 17),
          actualQuestionCount: 32,
          correctCount: 24,
          wrongCount: 6,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects performance details without actual question count', () {
      expect(
        () => PracticeCompletionRecord(
          topicId: 'fonksiyonlar',
          completedAt: DateTime.utc(2026, 8, 17),
          correctCount: 24,
          wrongCount: 6,
          blankCount: 2,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects performance total different from actual question count', () {
      expect(
        () => PracticeCompletionRecord(
          topicId: 'fonksiyonlar',
          completedAt: DateTime.utc(2026, 8, 17),
          actualQuestionCount: 32,
          correctCount: 24,
          wrongCount: 5,
          blankCount: 2,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}