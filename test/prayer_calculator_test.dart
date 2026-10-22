// Prayer calculation tests (§28): known inputs → verified outputs.
// Cairo + Egyptian method is a well-documented reference point.
import 'package:flutter_test/flutter_test.dart';
import 'package:fajr/features/prayer/prayer_calculator.dart';
import 'package:fajr/features/settings/settings.dart';

void main() {
  const calc = PrayerCalculator();
  // Cairo, Egypt — public geographic data.
  const cairoLat = 30.0444;
  const cairoLng = 31.2357;

  test('Fajr in Cairo (Egyptian method) is plausible and early-morning', () {
    final day = calc.timesFor(
      date: DateTime(2026, 1, 15),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    // Egyptian method uses 19.5° Fajr angle: Cairo Fajr is typically
    // around 05:00 local in mid-January. Assert a sane window.
    expect(day.fajr.hour, inInclusiveRange(4, 6));
    expect(day.dhuhr.isAfter(day.fajr), isTrue);
    expect(day.asr.isAfter(day.dhuhr), isTrue);
    expect(day.maghrib.isAfter(day.asr), isTrue);
    expect(day.isha.isAfter(day.maghrib), isTrue);
  });

  test('Times are monotonically ordered across all prayers', () {
    final day = calc.timesFor(
      date: DateTime(2026, 6, 21),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.mwl,
      madhab: AsrMadhab.shafi,
    );
    expect(day.fajr.isBefore(day.dhuhr), isTrue);
    expect(day.dhuhr.isBefore(day.asr), isTrue);
    expect(day.asr.isBefore(day.maghrib), isTrue);
    expect(day.maghrib.isBefore(day.isha), isTrue);
  });

  test('Hanafi Asr is later than Shafi Asr', () {
    final shafi = calc.timesFor(
      date: DateTime(2026, 3, 20),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    final hanafi = calc.timesFor(
      date: DateTime(2026, 3, 20),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.hanafi,
    );
    expect(hanafi.asr.isAfter(shafi.asr), isTrue,
        reason: 'Hanafi shadow ratio (2x) must give a later Asr');
  });

  test('Next prayer between Dhuhr and Asr is Asr', () {
    final day = calc.timesFor(
      date: DateTime(2026, 6, 21),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    final between = day.dhuhr.add(const Duration(minutes: 30));
    final (name, _) = calc.nextPrayer(
      today: day,
      now: between,
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    expect(name, PrayerName.asr);
  });

  test('Next prayer after Isha falls back to tomorrow Fajr', () {
    final day = calc.timesFor(
      date: DateTime(2026, 6, 21),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    final afterIsha = day.isha.add(const Duration(hours: 1));
    final (name, time) = calc.nextPrayer(
      today: day,
      now: afterIsha,
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    expect(name, PrayerName.fajr);
    expect(time.isAfter(afterIsha), isTrue);
    // Tomorrow's Fajr must be within a day of now.
    expect(time.difference(afterIsha).inHours, lessThan(24));
  });

  test('Next prayer before Fajr is Fajr (pre-dawn window)', () {
    final day = calc.timesFor(
      date: DateTime(2026, 6, 21),
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    final preDawn = DateTime(2026, 6, 21, 2, 0);
    final (name, _) = calc.nextPrayer(
      today: day,
      now: preDawn,
      latitude: cairoLat,
      longitude: cairoLng,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    expect(name, PrayerName.fajr);
  });

  test('Different methods yield different Fajr times', () {
    final egypt = calc.timesFor(
      date: DateTime(2026, 6, 21),
      latitude: 51.5074, // London
      longitude: -0.1278,
      method: CalcMethod.egypt,
      madhab: AsrMadhab.shafi,
    );
    final makkah = calc.timesFor(
      date: DateTime(2026, 6, 21),
      latitude: 51.5074,
      longitude: -0.1278,
      method: CalcMethod.makkah,
      madhab: AsrMadhab.shafi,
    );
    // Different Fajr angles (19.5 vs 18.5) must produce different times.
    expect(egypt.fajr.isAtSameMomentAs(makkah.fajr), isFalse);
  });

  test('formatRemaining formats hours/minutes/seconds in Arabic', () {
    expect(formatRemaining(const Duration(hours: 2, minutes: 30)), '2 س 30 د');
    expect(formatRemaining(const Duration(minutes: 5, seconds: 20)), '5 د 20 ث');
    expect(formatRemaining(const Duration(seconds: 45)), '45 ث');
    expect(formatRemaining(Duration.zero), '0 ث');
  });

  test('remainingUntil never returns negative', () {
    final now = DateTime(2026, 6, 21, 12, 0);
    final past = DateTime(2026, 6, 21, 11, 0);
    expect(calc.remainingUntil(now, past), Duration.zero);
  });
}
