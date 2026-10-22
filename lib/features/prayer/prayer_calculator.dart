/// Prayer times engine — single place where times are computed (§9).
///
/// Wraps the `adhan` library. All calculations are local and offline.
/// Never invented, never city-hardcoded.
library features.prayer;

import 'package:adhan/adhan.dart' as adhan;
import 'settings/settings.dart';

/// The five obligatory prayers.
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

extension PrayerNameX on PrayerName {
  String get label => switch (this) {
    PrayerName.fajr => 'الفجر',
    PrayerName.dhuhr => 'الظهر',
    PrayerName.asr => 'العصر',
    PrayerName.maghrib => 'المغرب',
    PrayerName.isha => 'العشاء',
  };
}

/// A single computed day of prayer times.
class PrayerDay {
  const PrayerDay({
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime date;
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  DateTime byName(PrayerName name) => switch (name) {
    PrayerName.fajr => fajr,
    PrayerName.dhuhr => dhuhr,
    PrayerName.asr => asr,
    PrayerName.maghrib => maghrib,
    PrayerName.isha => isha,
  };
}

/// Pure calculator — deterministic, testable, no platform dependencies.
class PrayerCalculator {
  const PrayerCalculator();

  adhan.CalculationParameters _params(CalcMethod method, AsrMadhab madhab) {
    final p = switch (method) {
      CalcMethod.mwl => adhan.CalculationMethod.muslimWorldLeague(),
      CalcMethod.isna => adhan.CalculationMethod.northAmerica(),
      CalcMethod.egypt => adhan.CalculationMethod.egyptian(),
      CalcMethod.makkah => adhan.CalculationMethod.ummAlQura(),
      CalcMethod.karachi => adhan.CalculationMethod.karachi(),
    };
    p.madhab = madhab == AsrMadhab.hanafi
        ? adhan.Madhab.hanafi
        : adhan.Madhab.shafi;
    return p;
  }

  /// Compute all five times for [date] (local time) at the given
  /// coordinates. Requires a valid location — never guessed.
  PrayerDay timesFor({
    required DateTime date,
    required double latitude,
    required double longitude,
    required CalcMethod method,
    required AsrMadhab madhab,
  }) {
    final params = _params(method, madhab);
    final coordinates = adhan.Coordinates(latitude, longitude);
    final jDate = adhan.DateComponents(
      date.year,
      date.month,
      date.day,
    );
    final pt = adhan.PrayerTimes(coordinates, jDate, params);
    return PrayerDay(
      date: DateTime(date.year, date.month, date.day),
      fajr: pt.fajr,
      dhuhr: pt.dhuhr,
      asr: pt.asr,
      maghrib: pt.maghrib,
      isha: pt.isha,
    );
  }

  /// Next prayer strictly after [now]. Handles the pre-Fajr window by
  /// falling back to tomorrow's Fajr (§9: next prayer before Fajr).
  (PrayerName, DateTime) nextPrayer({
    required PrayerDay today,
    required DateTime now,
    required double latitude,
    required double longitude,
    required CalcMethod method,
    required AsrMadhab madhab,
  }) {
    for (final name in PrayerName.values) {
      final t = today.byName(name);
      if (now.isBefore(t)) return (name, t);
    }
    // After Isha → tomorrow's Fajr.
    final tomorrow = now.add(const Duration(days: 1));
    final t = timesFor(
      date: tomorrow,
      latitude: latitude,
      longitude: longitude,
      method: method,
      madhab: madhab,
    );
    return (PrayerName.fajr, t.fajr);
  }

  /// Remaining time until [time], floor to seconds.
  Duration remainingUntil(DateTime now, DateTime time) {
    final d = time.difference(now);
    return d.isNegative ? Duration.zero : d;
  }
}

/// Formats remaining duration as Arabic-friendly h/m/s.
String formatRemaining(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '$h س $m د';
  if (m > 0) return '$m د $s ث';
  return '$s ث';
}
