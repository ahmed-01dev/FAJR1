/// Adhkar progress tracking — persisted locally, survives app restarts,
/// resets at day boundaries, and supports session undo (§11, §17).
library features.adhkar;

import 'adhkar_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-category session progress, keyed by local date so a new day
/// starts fresh without losing yesterday's completed records.
class AdhkarProgress {
  const AdhkarProgress({
    required this.date,
    required this.completedIds,
    required this.dailyCounts,
  });

  final String date; // yyyy-mm-dd in the user's local zone
  final Set<String> completedIds;
  /// dhikrId -> taps done today (for resuming an in-progress counter).
  final Map<String, int> dailyCounts;

  AdhkarProgress copyWith({Set<String>? completed, Map<String, int>? counts}) =>
      AdhkarProgress(
        date: date,
        completedIds: completed ?? completedIds,
        dailyCounts: counts ?? dailyCounts,
      );
}

class AdhkarRepository {
  static const _completedKey = 'fajr.adhkar.completed';
  static const _dateKey = 'fajr.adhkar.date';
  static const _countsKey = 'fajr.adhkar.counts';

  const AdhkarRepository();

  /// Loads today's progress. If the stored date is in the past, the
  /// counters reset (new day) but completion history remains retrievable
  /// for stats/achievements.
  Future<AdhkarProgress> load(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dayKey(now);
    final storedDate = prefs.getString(_dateKey);
    final completed = prefs.getStringList(_completedKey)?.toSet() ?? {};
    if (storedDate == today) {
      final counts = <String, int>{};
      prefs.getKeys().where((k) => k.startsWith('$_countsKey.')).forEach((k) {
        counts[k.substring('$_countsKey.'.length)] = prefs.getInt(k) ?? 0;
      });
      return AdhkarProgress(
        date: today,
        completedIds: completed,
        dailyCounts: counts,
      );
    }
    return AdhkarProgress(date: today, completedIds: completed, dailyCounts: {});
  }

  Future<void> save(AdhkarProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, p.date);
    await prefs.setStringList(_completedKey, p.completedIds.toList());
    final prefix = '$_countsKey.';
    // Clear old per-id counters before writing the fresh map.
    for (final k in prefs.getKeys().where((k) => k.startsWith(prefix))) {
      await prefs.remove(k);
    }
    for (final e in p.dailyCounts.entries) {
      await prefs.setInt('$prefix${e.key}', e.value);
    }
  }

  /// Mark a dhikr complete; idempotent — completing twice does nothing.
  Future<void> markComplete(String dhikrId, DateTime now) async {
    final p = await load(now);
    if (p.completedIds.contains(dhikrId)) return;
    await save(p.copyWith(completed: {...p.completedIds, dhikrId}));
  }

  /// Undo a mistaken completion (session correction, §11).
  Future<void> undoComplete(String dhikrId, DateTime now) async {
    final p = await load(now);
    if (!p.completedIds.contains(dhikrId)) return;
    await save(p.copyWith(completed: {...p.completedIds}..remove(dhikrId)));
  }

  Future<void> setCount(String dhikrId, int count, DateTime now) async {
    final p = await load(now);
    await save(p.copyWith(counts: {...p.dailyCounts, dhikrId: count}));
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
