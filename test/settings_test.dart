// Settings model tests: round-trip, validation fallback, defaults (§28).
import 'package:flutter_test/flutter_test.dart';
import 'package:fajr/features/settings/settings.dart';

void main() {
  test('defaults: system theme, shafi, western digits, egypt method', () {
    const s = AppSettings();
    expect(s.themeMode, ThemeModePref.system);
    expect(s.asrMadhab, AsrMadhab.shafi);
    expect(s.digits, DigitsPref.western);
    expect(s.calcMethod, CalcMethod.egypt);
    expect(s.hasLocation, isFalse);
    expect(s.onboardingDone, isFalse);
    expect(s.notifyPrayers, isTrue);
  });

  test('copyWith preserves untouched fields and updates touched ones', () {
    const s = AppSettings(cityName: 'القاهرة');
    final s2 = s.copyWith(latitude: 30.04, longitude: 31.23, calcMethod: CalcMethod.makkah);
    expect(s2.cityName, 'القاهرة');
    expect(s2.latitude, 30.04);
    expect(s2.longitude, 31.23);
    expect(s2.calcMethod, CalcMethod.makkah);
    expect(s2.hasLocation, isTrue);
  });

  test('toMap/fromMap round-trip is lossless', () {
    const s = AppSettings(
      themeMode: ThemeModePref.dark,
      asrMadhab: AsrMadhab.hanafi,
      digits: DigitsPref.arabic,
      calcMethod: CalcMethod.karachi,
      cityName: 'الرياض',
      latitude: 24.7136,
      longitude: 46.6753,
      onboardingDone: true,
      notifyPrayers: false,
    );
    final restored = AppSettings.fromMap(s.toMap());
    expect(restored.themeMode, s.themeMode);
    expect(restored.asrMadhab, s.asrMadhab);
    expect(restored.digits, s.digits);
    expect(restored.calcMethod, s.calcMethod);
    expect(restored.cityName, s.cityName);
    expect(restored.latitude, s.latitude);
    expect(restored.longitude, s.longitude);
    expect(restored.onboardingDone, s.onboardingDone);
    expect(restored.notifyPrayers, s.notifyPrayers);
  });

  test('fromMap falls back safely on unknown enum values (no crash)', () {
    final m = <String, Object?>{
      'themeMode': 'bogus-mode',
      'asrMadhab': 'maliki',
      'digits': 42,
      'calcMethod': null,
      'cityName': 12345,
    };
    final s = AppSettings.fromMap(m);
    expect(s.themeMode, ThemeModePref.system);
    expect(s.asrMadhab, AsrMadhab.shafi);
    expect(s.digits, DigitsPref.western);
    expect(s.calcMethod, CalcMethod.egypt);
    expect(s.cityName, isEmpty);
    expect(s.hasLocation, isFalse);
  });

  test('fromMap with non-double lat/lng does not set location', () {
    final m = <String, Object?>{'latitude': '30.04', 'longitude': '31.23'};
    final s = AppSettings.fromMap(m);
    expect(s.hasLocation, isFalse);
  });
}
