import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/engine/planning/standard_quantitative_subject_base_weights.dart';

void main() {
  group('standardQuantitativeSubjectBaseWeights', () {
    const acceptedRoundedWeights = {
      'mathematics': 0.371,
      'physics': 0.140,
      'turkish': 0.130,
      'chemistry': 0.124,
      'biology': 0.122,
      'history': 0.028,
      'geography': 0.028,
      'philosophy': 0.028,
      'religion': 0.028,
    };

    test('normalizes the accepted rounded base weights', () {
      final weights = standardQuantitativeSubjectBaseWeights();
      final roundedTotal = acceptedRoundedWeights.values.fold(
        0.0,
        (total, weight) => total + weight,
      );

      expect(weights.keys, acceptedRoundedWeights.keys);

      for (final entry in acceptedRoundedWeights.entries) {
        expect(weights[entry.key], closeTo(entry.value / roundedTotal, 1e-12));
      }
    });

    test('returns weights that sum to one', () {
      final weights = standardQuantitativeSubjectBaseWeights();
      final total = weights.values.fold(0.0, (sum, weight) => sum + weight);

      expect(weights.values, everyElement(greaterThan(0.0)));
      expect(total, closeTo(1.0, 1e-12));
    });

    test('returns an unmodifiable weight map', () {
      final weights = standardQuantitativeSubjectBaseWeights();

      expect(() => weights['mathematics'] = 1.0, throwsUnsupportedError);
    });
  });
}
