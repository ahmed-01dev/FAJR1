// Adhkar data integrity tests (§28): every entry has id, text, category.
// Guards against accidentally shipping broken content.
import 'package:flutter_test/flutter_test.dart';
import 'package:fajr/features/adhkar/adhkar_data.dart';

void main() {
  test('all adhkar have non-empty ids and texts', () {
    for (final d in AdhkarData.all) {
      expect(d.id, isNotEmpty);
      expect(d.text, isNotEmpty);
      expect(d.repetition, greaterThanOrEqualTo(0));
    }
  });

  test('every category has at least one dhikr', () {
    for (final c in DhikrCategory.values) {
      expect(
        AdhkarData.all.any((d) => d.category == c),
        isTrue,
        reason: 'Category ${c.label} must not be empty',
      );
    }
  });

  test('ids are unique', () {
    final ids = AdhkarData.all.map((d) => d.id).toSet();
    expect(ids.length, AdhkarData.all.length);
  });

  test('every dhikr carries a source reference (no unverifiable text)', () {
    for (final d in AdhkarData.all) {
      expect(d.reference, isNotNull,
          reason: 'Dhikr ${d.id} must cite its source (§11)');
    }
  });

  test('morning and evening sets are non-empty', () {
    expect(
      AdhkarData.all.where((d) => d.category == DhikrCategory.morning).length,
      greaterThanOrEqualTo(3),
    );
    expect(
      AdhkarData.all.where((d) => d.category == DhikrCategory.evening).length,
      greaterThanOrEqualTo(3),
    );
  });
}
