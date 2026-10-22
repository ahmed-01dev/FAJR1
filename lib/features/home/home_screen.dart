/// Home screen — concise daily dashboard (§8). Next prayer countdown,
/// today's times, adhkar progress, quick shortcuts.
library features.home;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../adhkar/adhkar_screen.dart';
import '../prayer/prayer_calculator.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // One lightweight timer, cancelled in dispose (§23 performance).
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final next = s.nextPrayerInfo();
    final today = s.todayTimes();

    return Scaffold(
      appBar: AppBar(title: const Text('فَجْر'), actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'الإعدادات',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(state: s),
            ),
          ),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _greeting(),
          const SizedBox(height: 16),
          if (next == null) _noLocationCard() else _nextPrayerCard(next),
          const SizedBox(height: 16),
          if (today != null) _timesCard(today),
          const SizedBox(height: 16),
          _adhkarShortcut(),
        ],
      ),
    );
  }

  Widget _greeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'صباح الخير'
        : hour < 17
        ? 'طاب يومك'
        : hour < 20
        ? 'مساء الخير'
        : 'طابت ليلتك';
    final today = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(today, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _noLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.location_off_outlined, size: 40),
            const SizedBox(height: 8),
            Text('لم تُحدد مدينتك بعد', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'اختر مدينتك من الإعدادات لحساب مواقيت الصلاة.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(state: widget.state),
                ),
              ),
              child: const Text('اختر المدينة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextPrayerCard((PrayerName, DateTime, Duration) next) {
    final (name, time, remaining) = next;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('الصلاة التالية', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(name.label, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            )),
            const SizedBox(height: 4),
            Text('$h:$m', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              'متبقٍ ${formatRemaining(remaining)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timesCard(PrayerDay today) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(PrayerName.values.length, (i) {
            final name = PrayerName.values[i];
            final t = today.byName(name);
            final hh = t.hour.toString().padLeft(2, '0');
            final mm = t.minute.toString().padLeft(2, '0');
            final isNext = t.isAfter(DateTime.now());
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isNext ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  Text('$hh:$mm', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _adhkarShortcut() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome_outlined),
        title: const Text('أذكار الصباح والمساء'),
        subtitle: Text(
          'تابع أذكارك اليومية من مصادر موثقة',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdhkarScreen(state: widget.state)),
        ),
      ),
    );
  }
}
