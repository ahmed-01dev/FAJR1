/// App state container — one consistent state-management approach
/// (ChangeNotifier + provider), settings + prayer + adhkar wired
/// together with proper change notification (§4).
library app;

import 'package:flutter/material.dart';
import '../features/settings/settings.dart';
import '../features/prayer/prayer_calculator.dart';
import '../features/adhkar/adhkar_repository.dart';
import '../features/adhkar/adhkar_data.dart';

/// Global app state exposed to widgets via provider.
class AppState extends ChangeNotifier {
  AppState({
    required SettingsRepository settingsRepo,
    required AdhkarRepository adhkarRepo,
  }) : _settingsRepo = settingsRepo,
       _adhkarRepo = adhkarRepo;

  final SettingsRepository _settingsRepo;
  final AdhkarRepository _adhkarRepo;
  final PrayerCalculator _prayer = const PrayerCalculator();

  AppSettings _settings = const AppSettings();
  AdhkarProgress? _adhkarProgress;
  String? _startupError;

  AppSettings get settings => _settings;
  AdhkarProgress? get adhkarProgress => _adhkarProgress;
  String? get startupError => _startupError;

  /// Loads settings from local storage only. Network/Firebase are NOT
  /// awaited here — startup can never hang on the internet (§7).
  Future<void> loadLocal() async {
    try {
      _settings = await _settingsRepo.load();
      _adhkarProgress = await _adhkarRepo.load(DateTime.now());
    } catch (e) {
      _startupError = 'تعذّر تحميل الإعدادات المحلية. سيعمل التطبيق بالقيم الافتراضية.';
    }
    notifyListeners();
  }

  /// Update settings and persist atomically.
  Future<void> updateSettings(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _settingsRepo.save(next);
  }

  Future<void> completeDhikr(String id) async {
    await _adhkarRepo.markComplete(id, DateTime.now());
    _adhkarProgress = await _adhkarRepo.load(DateTime.now());
    notifyListeners();
  }

  Future<void> undoDhikr(String id) async {
    await _adhkarRepo.undoComplete(id, DateTime.now());
    _adhkarProgress = await _adhkarRepo.load(DateTime.now());
    notifyListeners();
  }

  Future<void> setDhikrCount(String id, int c) async {
    await _adhkarRepo.setCount(id, c, DateTime.now());
    _adhhkarProgressReload();
  }

  void _adhkarProgressReload() async {
    _adhkarProgress = await _adhkarRepo.load(DateTime.now());
    notifyListeners();
  }

  /// Today's prayer times; null when no location is set yet (no invented
  /// coordinates — UI asks the user to pick a city first).
  PrayerDay? todayTimes() {
    if (!settings.hasLocation) return null;
    return _prayer.timesFor(
      date: DateTime.now(),
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.calcMethod,
      madhab: settings.asrMadhab,
    );
  }

  (PrayerName, DateTime, Duration)? nextPrayerInfo() {
    final today = todayTimes();
    if (today == null) return null;
    final (name, time) = _prayer.nextPrayer(
      today: today,
      now: DateTime.now(),
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.calcMethod,
      madhab: settings.asrMadhab,
    );
    return (name, time, _prayer.remainingUntil(DateTime.now(), time));
  }

  List<Dhikr> adhkarOf(DhikrCategory c) =>
      AdhkarData.all.where((d) => d.category == c).toList();
}
