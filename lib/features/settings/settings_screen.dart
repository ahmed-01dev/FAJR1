/// Settings screen — theme, city, method, madhab, digits (§26).
library features.settings;

import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import 'settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    final s = _state.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          _section('المظهر'),
          ...ThemeModePref.values.map(
            (t) => RadioListTile<ThemeModePref>(
              value: t,
              groupValue: s.themeMode,
              onChanged: (v) => _update(s.copyWith(themeMode: v!)),
              title: Text(switch (t) {
                ThemeModePref.system => 'حسب النظام',
                ThemeModePref.light => 'فاتح',
                ThemeModePref.dark => 'داكن',
              }),
            ),
          ),
          _section('المدينة: ${s.cityName.isEmpty ? 'غير محددة' : s.cityName}'),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('تغيير المدينة'),
            subtitle: Text(
              'تُستخدم لحساب المواقيت محليًا على جهازك',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: _pickCity,
          ),
          _section('طريقة الحساب'),
          ...CalcMethod.values.map(
            (m) => RadioListTile<CalcMethod>(
              value: m,
              groupValue: s.calcMethod,
              onChanged: (v) => _update(s.copyWith(calcMethod: v!)),
              title: Text(m.label),
            ),
          ),
          _section('المذهب (العصر)'),
          ...AsrMadhab.values.map(
            (m) => RadioListTile<AsrMadhab>(
              value: m,
              groupValue: s.asrMadhab,
              onChanged: (v) => _update(s.copyWith(asrMadhab: v!)),
              title: Text(switch (m) {
                AsrMadhab.shafi => 'الشافعي (الجمهور)',
                AsrMadhab.hanafi => 'الحنفي',
              }),
            ),
          ),
          _section('الأرقام'),
          ...DigitsPref.values.map(
            (d) => RadioListTile<DigitsPref>(
              value: d,
              groupValue: s.digits,
              onChanged: (v) => _update(s.copyWith(digits: v!)),
              title: Text(switch (d) {
                DigitsPref.arabic => '٠١٢٣٤٥٦٧٨٩',
                DigitsPref.western => '0123456789',
              }),
            ),
          ),
          _section('حول التطبيق'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('عن فَجْر'),
            subtitle: Text('الإصدار 0.1.0 — يعمل دون إنترنت', style: Theme.of(context).textTheme.bodySmall),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: const Text('المزامنة السحابية'),
            subtitle: Text(
              'غير متاحة حاليًا — تتطلب إعداد Firebase. بياناتك محفوظة على جهازك.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  void _update(AppSettings next) {
    _state.updateSettings(next);
    setState(() {});
  }

  Future<void> _pickCity() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        children: const ['القاهرة', 'مكة المكرمة', 'الرياض', 'دبي', 'عمّان', 'لندن']
            .map((c) => ListTile(title: Text(c), onTap: () => Navigator.pop(context, c)))
            .toList(),
      ),
    );
    if (result != null) {
      _update(_state.settings.copyWith(cityName: result));
    }
  }
}
