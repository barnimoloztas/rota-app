import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/practice_signal.dart';

void main() {
  group('PracticeSignalReason', () {
    test('represents distinct reasons for practice need', () {
      expect(
        PracticeSignalReason.values,
        containsAllInOrder([
          PracticeSignalReason.initialPractice,
          PracticeSignalReason.practiceDevelopment,
          PracticeSignalReason.practiceMaintenance,
        ]),
      );
    });
  });

  group('PracticeSignal', () {
    test('stores topic, reason, and strength', () {
      const signal = PracticeSignal(
        topicId: 'fonksiyonlar',
        reason: PracticeSignalReason.initialPractice,
        strength: 0.80,
      );

      expect(signal.topicId, 'fonksiyonlar');
      expect(signal.reason, PracticeSignalReason.initialPractice);
      expect(signal.strength, 0.80);
    });
  });
}