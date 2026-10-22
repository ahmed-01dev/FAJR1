/// First-run onboarding: pick city, method, theme — all stored locally.
library features.onboarding;

import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../settings/settings.dart';

/// Curated city list with well-known coordinates (public geographic data).
const _cities = <(String, double, double)>[
  ('القاهرة', 30.0444, 31.2357),
  ('الإسكندرية', 31.2001, 29.9187),
  ('مكة المكرمة', 21.3891, 39.8579),
  ('المدينة المنورة', 24.5247, 39.5692),
  ('الرياض', 24.7136, 46.6753),
  ('جدة', 21.4858, 39.1925),
  ('دبي', 25.2048, 55.2708),
  ('أبوظبي', 24.4539, 54.3773),
  ('الدوحة', 25.2854, 51.5310),
  ('الكويت', 29.3759, 47.9774),
  ('عمّان', 31.9454, 35.9284),
  ('بيروت', 33.8938, 35.5018),
  ('دمشق', 33.5138, 36.2765),
  ('بغداد', 33.3152, 44.3661),
  ('القدس', 31.7683, 35.2137),
  ('الخرطوم', 15.5007, 32.5599),
  ('الدار البيضاء', 33.5731, -7.5898),
  ('تونس', 36.8065, 10.1815),
  ('الجزائر', 36.7538, 3.0588),
  ('طرابلس', 32.8872, 13.1913),
  ('إسطنبول', 41.0082, 28.9784),
  ('لندن', 51.5074, -0.1278),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});
  final AppState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;
  String _name = '';
  String? _city;
  CalcMethod _method = CalcMethod.egypt;
  ThemeModePref _theme = ThemeModePref.dark;

  void _done() async {
    final state = widget.state;
    final city = _cities.firstWhere((c) => c.$1 == _city);
    await state.updateSettings(
      state.settings.copyWith(
        cityName: city.$1,
        latitude: city.$2,
        longitude: city.$3,
        calcMethod: _method,
        themeMode: _theme,
        onboardingDone: true,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(state: state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: PageController(),
        onPageChanged: (i) => setState(() => _page = i),
        children: [_welcomePage(), _cityPage(), _methodPage(), _namePage()],
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _nav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_page > 0)
              TextButton(
                onPressed: () => setState(() => _page--),
                child: const Text('السابق'),
              )
            else
              const SizedBox.shrink(),
            if (_page < 3)
              FilledButton(
                onPressed: (_page == 1 && _city == null)
                    ? null
                    : () => setState(() => _page++),
                child: const Text('التالي'),
              )
            else
              FilledButton(
                onPressed: (_name.trim().isEmpty || _city == null)
                    ? null
                    : _done,
                child: const Text('ابدأ رحلتك'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _welcomePage() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text('🌙', style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text('أهلًا بك في فَجْر', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'رفيقك اليومي لمواقيت الصلاة والأذكار والعبادات.\nكل شيء يعمل دون إنترنت وبياناتك تبقى على جهازك.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );

  Widget _cityPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('اختر مدينتك', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'تُستخدم لحساب مواقيت الصلاة محليًا على جهازك — لا تُرسل لأي خادم.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        ..._cities.map(
          (c) => RadioListTile<String>(
            value: c.$1,
            groupValue: _city,
            onChanged: (v) => setState(() => _city = v),
            title: Text(c.$1),
          ),
        ),
      ],
    );
  }

  Widget _methodPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('طريقة حساب المواقيت', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'اختر الجهة المعتمدة في بلدك. يمكنك تغييرها لاحقًا من الإعدادات.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(authority: 16),
        ...CalcMethod.values.map(
          (m) => RadioListTile<CalcMethod>(
            value: m,
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            title: Text(m.label),
          ),
        ),
        const SizedBox(height: 16),
        Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
        ...ThemeModePref.values.map(
          (t) => RadioListTile<ThemeModePref>(
            value: t,
            groupValue: _theme,
            onChanged: (v) => setState(() => _theme = v!),
            title: Text(
              switch (t) {
                ThemeModePref.system => 'حسب النظام',
                ThemeModePref.light => 'فاتح',
                ThemeModePref.dark => 'داكن',
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _namePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ما اسمك؟', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _name = v),
              decoration: const InputDecoration(
                hintText: 'اسمك (اختياري للعرض فقط)',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'يُحفظ على جهازك فقط ولا يُشارك مع أحد.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
