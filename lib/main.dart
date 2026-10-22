/// فَجْر — FAJR
/// Root widget: bounded startup, RTL Arabic Material 3 app (§7).
///
/// Startup waits ONLY for local data. Network, Firebase, and location are
/// never awaited before the first usable screen. If local load fails,
/// the app still enters with safe defaults — no infinite loader path.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings.dart';

void main() => runApp(const FajrApp());

class FajrApp extends StatefulWidget {
  const FajrApp({super.key});

  @override
  State<FajrApp> createState() => _FajrAppState();
}

class _FajrAppState extends State<FajrApp> with WidgetsBindingObserver {
  final _state = AppState(
    settingsRepo: const SettingsRepository(),
    adhkarRepo: const AdhkarRepository(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _state.loadLocal();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _state.dispose();
    super.dispose();
  }

  /// Refresh day-bound data when returning from background (§7).
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _state.loadLocal();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _state,
      builder: (context, _, __) {
        final mode = switch (_state.settings.themeMode) {
          ThemeModePref.light => ThemeMode.light,
          ThemeModePref.dark => ThemeMode.dark,
          ThemeModePref.system => ThemeMode.system,
        };
        return MaterialApp(
          title: 'فَجْر',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: _SplashGate(state: _state),
        );
      },
    );
  }
}

/// Bounded splash: loads local data with a hard timeout. On timeout or
/// error the app still proceeds — never a stuck loader (§7).
class _SplashGate extends StatelessWidget {
  const _SplashGate({required this.state});
  final AppState state;

  static const _timeout = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: state.loadLocal().timeout(
        _timeout,
        onTimeout: () {}, // proceed with defaults — never hang
      ),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!state.settings.onboardingDone) {
          return OnboardingScreen(state: state);
        }
        return HomeScreen(state: state);
      },
    );
  }
}
