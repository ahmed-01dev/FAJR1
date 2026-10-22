/// User settings model with typed fields, validation, and persistence (§26).
library features.settings;

import 'package:shared_preferences/shared_preferences.dart';

/// Theme preference.
enum ThemeModePref { system, light, dark }

/// Madhab for Asr calculation.
enum AsrMadhab { shafi, hanafi }

/// Numeric display preference for Arabic digits.
enum DigitsPref { arabic, western }

/// Verified calculation methods supported by the adhan library.
enum CalcMethod {
  mwl('رابطة العالم الإسلامي'),
  isna('الجمعية الإسلامية لأمريكا الشمالية'),
  egypt('الهيئة المصرية العامة للمساحة'),
  makkah('أم القرى'),
  karachi('جامعة العلوم الإسلامية، كراتشي');

  const CalcMethod(this.label);
  final String label;
}

/// Typed, validated user settings.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModePref.system,
    this.asrMadhab = AsrMadhab.shafi,
    this.digits = DigitsPref.western,
    this.calcMethod = CalcMethod.egypt,
    this.cityName = '',
    this.latitude,
    this.longitude,
    this.onboardingDone = false,
    this.notifyPrayers = true,
    this.notifyAdhkar = true,
  });

  final ThemeModePref themeMode;
  final AsrMadhab asrMadhab;
  final DigitsPref digits;
  final CalcMethod calcMethod;
  final String cityName;
  /// Null until the user picks a city/coordinates (no invented defaults).
  final double? latitude;
  final double? longitude;
  final bool onboardingDone;
  final bool notifyPrayers;
  final bool notifyAdhkar;

  bool get hasLocation => latitude != null && longitude != null;

  AppSettings copyWith({
    ThemeModePref? themeMode,
    AsrMadhab? asrMadhab,
    DigitsPref? digits,
    CalcMethod? calcMethod,
    String? cityName,
    double? latitude,
    double? longitude,
    bool? onboardingDone,
    bool? notifyPrayers,
    bool? notifyAdhkar,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    asrMadhab: asrMadhab ?? this.asrMadhab,
    digits: digits ?? this.digits,
    calcMethod: calcMethod ?? this.calcMethod,
    cityName: cityName ?? this.cityName,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    notifyPrayers: notifyPrayers ?? this.notifyPrayers,
    notifyAdhkar: notifyAdhkar ?? this.notifyAdhkar,
  );

  Map<String, Object> toMap() => {
    'themeMode': themeMode.name,
    'asrMadhab': asrMadhab.name,
    'digits': digits.name,
    'calcMethod': calcMethod.name,
    'cityName': cityName,
    'latitude': latitude,
    'longitude': longitude,
    'onboardingDone': onboardingDone,
    'notifyPrayers': notifyPrayers,
    'notifyAdhkar': notifyAdhkar,
  };

  /// Strict loader: unknown enum values or corrupt types fall back to
  /// defaults rather than crashing (§22).
  static AppSettings fromMap(Map<String, Object?> map) {
    ThemeModePref themeMode = ThemeModePref.system;
    if (map['themeMode'] is String &&
        ThemeModePref.values.any((e) => e.name == map['themeMode'])) {
      themeMode = ThemeModePref.values.firstWhere(
        (e) => e.name == map['themeMode'],
      );
    }
    AsrMadhab madhab = AsrMadhab.shafi;
    if (map['asrMadhab'] is String &&
        AsrMadhab.values.any((e) => e.name == map['asrMadhab'])) {
      madhab = AsrMadhab.values.firstWhere((e) => e.name == map['asrMadhab']);
    }
    DigitsPref digits = DigitsPref.western;
    if (map['digits'] is String &&
        DigitsPref.values.any((e) => e.name == map['digits'])) {
      digits = DigitsPref.values.firstWhere((e) => e.name == map['digits']);
    }
    CalcMethod method = CalcMethod.egypt;
    if (map['calcMethod'] is String &&
        CalcMethod.values.any((e) => e.name == map['calcMethod'])) {
      method = CalcMethod.values.firstWhere(
        (e) => e.name == map['calcMethod'],
      );
    }
    final lat = map['latitude'];
    final lng = map['longitude'];
    return AppSettings(
      themeMode: themeMode,
      asrMadhab: madhab,
      digits: digits,
      calcMethod: method,
      cityName: map['cityName'] is String ? map['cityName'] as String : '',
      latitude: lat is double ? lat : null,
      longitude: lng is double ? lng : null,
      onboardingDone: map['onboardingDone'] == true,
      notifyPrayers: map['notifyPrayers'] != false,
      notifyAdhkar: map['notifyAdhkar'] != false,
    );
  }
}

/// Local persistence for settings via shared_preferences.
class SettingsRepository {
  static const _key = 'fajr.settings';

  const SettingsRepository();

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      // Simple JSON-free map round-trip via toMap/fromMap pairs.
      final map = <String, Object?>{};
      raw.split('\n').forEach((line) {
        final idx = line.indexOf('=');
        if (idx <= 0) return;
        final k = line.substring(0, idx);
        var v = line.substring(idx + 1);
        if (v == 'null') v = null;
        if (v == 'true' || v == 'false') {
          map[k] = v == 'true';
        } else if (double.tryParse(v) != null) {
          map[k] = double.parse(v);
        } else {
          map[k] = v;
        }
      });
      return AppSettings.fromMap(map);
    } catch (_) {
      return const AppSettings(); // corrupt data → safe defaults, never crash
    }
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    final map = s.toMap();
    final buf = StringBuffer();
    map.forEach((k, v) => buf.writeln('$k=$v'));
    await prefs.setString(_key, buf.toString());
  }
}
