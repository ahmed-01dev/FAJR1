import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kBg = Color(0xFF0D1B2A);
const kCard = Color(0xFF16263A);
const kGreen = Color(0xFF0E9F6E);
const kGold = Color(0xFFD4AF37);
const kText = Color(0xFFF8F5EF);

const verses = [
  {'text': 'وَقُرْآنَ الْفَجْرِ ۖ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا', 'ref': 'الإسراء ٧٨'},
  {'text': 'تَتَجَافَىٰ جُنُوبُهُمْ عَنِ الْمَضَاجِعِ يَدْعُونَ رَبَّهُمْ خَوْفًا وَطَمَعًا', 'ref': 'السجدة ١٦'},
  {'text': 'كَانُوا قَلِيلًا مِّنَ اللَّيْلِ مَا يَهْجَعُونَ', 'ref': 'الذاريات ١٧'},
  {'text': 'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ', 'ref': 'المائدة ٢'},
];

const ranks = [
  ['🌱', 'المبتدئ', 0],
  ['🌅', 'صاحي الفجر', 100],
  ['⏰', 'الموقِظ', 300],
  ['🤝', 'صديق الفجر', 600],
  ['🛡️', 'حارس الفجر', 1000],
  ['⚔️', 'قائد الفجر', 1600],
  ['👑', 'فاتح الفجر', 2500],
];

String dstr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() => runApp(const FajrApp());

class FajrApp extends StatelessWidget {
  const FajrApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فَجْر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kGreen, secondary: kGold, surface: kCard),
      ),
      builder: (c, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool? onboarded;
  @override
  void initState() {
    super.initState();
    () async {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => onboarded = p.getBool('onboarded') ?? false);
    }();
  }

@override
  Widget build(BuildContext context) {
    if (onboarded == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kGreen)));
    }
    return onboarded! ? const MainShell() : Onboarding(onDone: () => setState(() => onboarded = true));
  }
}

class Onboarding extends StatefulWidget {
  final VoidCallback onDone;
  const Onboarding({super.key, required this.onDone});
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final ctrl = PageController();
  final nameCtrl = TextEditingController();
  int page = 0;

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: ctrl,
        onPageChanged: (i) => setState(() => page = i),
        children: [
          slide('🌙', 'وَالْفَجْرِ • وَلَيَالٍ عَشْرٍ', 'الفجر أجمل لما نصحّي بعض', isVerse: true),
          slide('🤝', 'مش لوحدك', 'انضم لمجموعة تساعدك وتساعد غيرك'),
          namePage(),
        ],
      ),
    );
  }

Widget namePage() {
    return Scaffold(
      backgroundColor: kBg,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('صحيت؟ ساعد غيرك', style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 8),
            Text('بضغطة واحدة تبدأ رحلة إيقاظ أصحابك', style: GoogleFonts.cairo(color: kText.withOpacity(.7))),
            const SizedBox(height: 28),
            TextField(
              controller: nameCtrl,
              style: GoogleFonts.cairo(color: kText),
              decoration: InputDecoration(
                hintText: 'اكتب اسمك',
                hintStyle: GoogleFonts.cairo(color: kText.withOpacity(.5)),
                filled: true,
                fillColor: kCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () async {
                  final p = await SharedPreferences.getInstance();
                  final n = nameCtrl.text.trim();
                  if (n.isNotEmpty) await p.setString('name', n);
                  await p.setBool('onboarded', true);
                  widget.onDone();
                },
                child: Text('ابدأ الآن 🚀', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget slide(String icon, String title, String sub, {bool isVerse = false}) {
    return Scaffold(
      backgroundColor: kBg,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            isVerse
                ? Text(title, textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 30, color: kGold))
                : Text(title, style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: kText)),
            const SizedBox(height: 12),
            Text(sub, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 16, color: kText.withOpacity(.7))),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10, height: 10,
                decoration: BoxDecoration(color: i == page ? kGreen : kCard, shape: BoxShape.circle),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  String name = 'صديق الفجر';
  int xp = 0, streak = 0, wakeCount = 0, helpCount = 0, tasbih = 0;
  String lastWake = '';
  List<Map<String, dynamic>> logs = [];
  List<int> azkarCount = [0, 0, 0];
  List<int> helpers = [0, 0, 0];
  Timer? timer;
  Duration left = const Duration();

final demoNames = ['محمد', 'عبد الله', 'أمينة'];
  final demoXp = [180, 95, 60];
  final azkarNames = ['أستغفر الله العظيم', 'اللهم صلِّ على محمد', 'لا حول ولا قوة إلا بالله'];

@override
  void initState() {
    super.initState();
    _load();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => left = _nextFajr().difference(DateTime.now()));
    });
  }

@override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      name = p.getString('name') ?? name;
      xp = p.getInt('xp') ?? 0;
      streak = p.getInt('streak') ?? 0;
      wakeCount = p.getInt('wakeCount') ?? 0;
      helpCount = p.getInt('helpCount') ?? 0;
      tasbih = p.getInt('tasbih') ?? 0;
      lastWake = p.getString('lastWake') ?? '';
      try {
        logs = (jsonDecode(p.getString('logs') ?? '[]') as List).cast<Map<String, dynamic>>();
        azkarCount = (jsonDecode(p.getString('azkar') ?? '[0,0,0]') as List).cast<int>();
        helpers = (jsonDecode(p.getString('helpers') ?? '[0,0,0]') as List).cast<int>();
      } catch (_) {}
    });
  }

DateTime _nextFajr() {
    final n = DateTime.now();
    var f = DateTime(n.year, n.month, n.day, 5, 12);
    if (f.isBefore(n)) f = f.add(const Duration(days: 1));
    return f;
  }

Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('xp', xp);
    await p.setInt('streak', streak);
    await p.setInt('wakeCount', wakeCount);
    await p.setInt('helpCount', helpCount);
    await p.setInt('tasbih', tasbih);
    await p.setString('lastWake', lastWake);
    await p.setString('logs', jsonEncode(logs));
    await p.setString('azkar', jsonEncode(azkarCount));
    await p.setString('helpers', jsonEncode(helpers));
  }

void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.cairo()),
      backgroundColor: kCard,
      behavior: SnackBarBehavior.floating,
    ));
  }

void _addLog(String t) {
    logs.insert(0, {'d': dstr(DateTime.now()), 't': t});
  }

int get rankIndex {
    int i = 0;
    for (int j = 0; j < ranks.length; j++) {
      if (xp >= (ranks[j][2] as int)) i = j;
    }
    return i;
  }

void _gainXp(int n) {
    final before = rankIndex;
    xp += n;
    final after = rankIndex;
    if (after > before) {
      Future.delayed(Duration.zero, () => _snack('🎉 ترقية! وصلت لرتبة ${ranks[after][1]} ${ranks[after][0]}'));
    }
  }

Future<void> _wakeUp() async {
    final today = dstr(DateTime.now());
    if (lastWake == today) {
      _snack('أنت صحيت خلاص النهارده 😄 جزاك الله خيرًا');
      return;
    }
    final yesterday = dstr(DateTime.now().subtract(const Duration(days: 1)));
    streak = (lastWake == yesterday) ? streak + 1 : 1;
    lastWake = today;
    wakeCount++;
    final bonus = streak >= 30 ? 8 : (streak >= 7 ? 4 : 0);
    _gainXp(10 + bonus);
    _addLog('صحيت للفجر ✅ (+${10 + bonus}) — سلسلة $streak يوم 🔥');
    await _save();
    setState(() {});
    if (!mounted) return;
    showModalBottomSheet(
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🌅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: kGold), borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text('بَشِّرِ الْمَشَّائِينَ فِي الظُّلَمِ إِلَى الْمَسَاجِدِ بِالنُّورِ التَّامِّ يَوْمَ الْقِيَامَةِ',
                  textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 20, color: kGold)),
              const SizedBox(height: 6),
              Text('رواه أبو داود والترمذي', style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.6))),
            ]),
          ),
          const SizedBox(height: 12),
          Text('جزاك الله خيرًا! ابدأ يومك بنية 💚', style: GoogleFonts.cairo(color: kText)),
        ]),
      ),
    );
  }

Future<void> _callHelper(int i) async {
    if (helpers[i] == 0) {
      helpers[i] = 1;
      _gainXp(5);
      _addLog('اتصلت لإيقاظ ${demoNames[i]} 📞 (+5)');
      await _save();
      setState(() {});
      _snack('جاري الاتصال بـ${demoNames[i]}... 📞');
    } else if (helpers[i] == 1) {
      helpers[i] = 2;
      helpCount++;
      _gainXp(25);
      _addLog('${demoNames[i]} استيقظ بفضل الله 🌅 (+25)');
      await _save();
      setState(() {});
      _snack('جزاك الله خيرًا! ${demoNames[i]} استيقظ 🌅 (+25)');
    }
  }

String two(int n) => n.toString().padLeft(2, '0');

Widget card(Widget child) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
        child: child,
      );

Widget stat(String icon, String val, String label) => Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        Text(val, style: GoogleFonts.cairo(color: kText, fontSize: 18)),
        Text(label, style: GoogleFonts.cairo(color: kText.withOpacity(.5), fontSize: 11)),
      ]);

Widget helperRow(int i) {
    final labels = ['اتصل توقظه 📞', 'تأكيد: استيقظ ✅', 'استيقظ بحمد الله ✅'];
    return card(Row(children: [
      CircleAvatar(backgroundColor: kBg, child: Text(demoNames[i][0], style: GoogleFonts.cairo(color: kGold))),
      const SizedBox(width: 10),
      Expanded(child: Text(demoNames[i], style: GoogleFonts.cairo(color: kText, fontSize: 16))),
      TextButton(
        onPressed: helpers[i] == 2 ? null : () => _callHelper(i),
        child: Text(labels[helpers[i]], style: GoogleFonts.cairo(color: helpers[i] == 2 ? kGreen : kGold, fontSize: 12)),
      ),
    ]));
  }

Widget homeTab() {
    final ri = rankIndex;
    final next = ri < ranks.length - 1 ? ranks[ri + 1] : null;
    final progress = next != null
        ? ((xp - (ranks[ri][2] as int)) / ((next[2] as int) - (ranks[ri][2] as int))).clamp(0.0, 1.0)
        : 1.0;
    final verse = verses[DateTime.now().day % verses.length];
    return ListView(children: [
      const SizedBox(height: 8),
      card(Column(children: [
        Text(verse['text']!, textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 20, color: kGold)),
        const SizedBox(height: 6),
        Text('${verse['ref']} — آية اليوم', style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.6))),
      ])),
      card(Column(children: [
        Text('⏳ باقي على الفجر', style: GoogleFonts.cairo(color: kText.withOpacity(.7))),
        const SizedBox(height: 4),
        Text('${two(left.inHours)}:${two(left.inMinutes % 60)}:${two(left.inSeconds % 60)}',
            style: GoogleFonts.cairo(fontSize: 34, color: kGreen, fontWeight: FontWeight.bold)),
      ])),
      card(Column(children: [
        Text('${ranks[ri][0]}', style: const TextStyle(fontSize: 40)),
        Text('${ranks[ri][1]}', style: GoogleFonts.cairo(color: kText, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, color: kGreen, backgroundColor: kBg, borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 8),
        Text(next != null ? 'باقي ${(next[2] as int) - xp} نقطة لرتبة ${next[1]}' : 'وصلت لأعلى رتبة 👑 مبروك!',
            style: GoogleFonts.cairo(fontSize: 12, color: kText.withOpacity(.7))),
      ])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 64,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: _wakeUp,
            child: Text('أنا صحيت 🌅', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      card(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        stat('🔥', '$streak', 'سلسلة'),
        stat('⭐', '$xp', 'نقاط'),
        stat('🌅', '$wakeCount', 'صحوات'),
        stat('🤝', '$helpCount', 'أيقظت'),
      ])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('وقّظ أصحابك 🤝', style: GoogleFonts.cairo(color: kGold, fontSize: 16)),
      ),
      ...List.generate(3, (i) => helperRow(i)),
      const SizedBox(height: 20),
    ]);
  }

Widget groupTab() {
    final members = [
      {'n': name, 'x': xp, 'me': true},
      {'n': demoNames[0], 'x': demoXp[0], 'me': false},
      {'n': demoNames[1], 'x': demoXp[1], 'me': false},
      {'n': demoNames[2], 'x': demoXp[2], 'me': false},
    ];
    members.sort((a, b) => (b['x'] as int).compareTo(a['x'] as int));
    const medals = ['🥇', '🥈', '🥉', '🏅'];
    return ListView(children: [
      const SizedBox(height: 12),
      Text('«وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ»', textAlign: TextAlign.center, style: GoogleFonts.amiriQuran(fontSize: 20, color: kGold)),
      Text('المطففين ٢٦ — لوحة المتصدرين', textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 11, color: kText.withOpacity(.6))),
      const SizedBox(height: 8),
      ...members.asMap().entries.map((e) => card(Row(children: [
            Text(medals[e.key], style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(e.value['n'] as String, style: GoogleFonts.cairo(color: kText, fontSize: 16))),
            Text('${e.value['x']} ⭐', style: GoogleFonts.cairo(color: (e.value['me'] as bool) ? kGreen : kGold)),
          ]))),
      const SizedBox(height: 20),
    ]);
  }

Widget azkarTab() {
    return ListView(children: [
      const SizedBox(height: 12),
      card(Column(children: [
        Text('📿 المسبحة', style: GoogleFonts.cairo(color: kGold, fontSize: 18)),
        const SizedBox(height: 8),
        Text('$tasbih', style: GoogleFonts.cairo(color: kText, fontSize: 34)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton(
              onPressed: () async {
                setState(() => tasbih++);
                await _save();
              },
              child: const Text('+1')),
          const SizedBox(width: 10),
          TextButton(
              onPressed: () async {
                setState(() => tasbih = 0);
                await _save();
              },
              child: Text('تصفير', style: GoogleFonts.cairo(color: kText.withOpacity(.6)))),
        ]),
      ])),
      ...List.generate(3, (i) => card(Column(children: [
            Text(azkarNames[i], style: GoogleFonts.cairo(color: kText, fontSize: 16)),
            const SizedBox(height: 6),
            Text('${azkarCount[i]}', style: GoogleFonts.cairo(color: kGreen, fontSize: 22)),
            const SizedBox(height: 6),
            FilledButton.tonal(
              onPressed: () async {
                setState(() => azkarCount[i]++);
                await _save();
              },
              child: const Text('+1'),
            ),
          ]))),
      const SizedBox(height: 20),
    ]);
  }

Widget logTab() {
    return ListView(children: [
      const SizedBox(height: 12),
      if (logs.isEmpty)
        card(Text('لسه مفيش نشاط — ابدأ أول صحوة للفجر 🌅',
            textAlign: TextAlign.center, style: GoogleFonts.cairo(color: kText.withOpacity(.7))))
      else
        ...logs.take(30).map((l) => card(Row(children: [
              const Icon(Icons.circle, size: 8, color: kGreen),
              const SizedBox(width: 10),
              Expanded(child: Text(l['t'] as String, style: GoogleFonts.cairo(color: kText, fontSize: 13))),
              Text(l['d'] as String, style: GoogleFonts.cairo(color: kText.withOpacity(.4), fontSize: 10)),
            ]))),
      const SizedBox(height: 20),
    ]);
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBg,
        centerTitle: true,
        title: Text('🌙 فَجْر', style: GoogleFonts.cairo(color: kGold, fontSize: 22)),
      ),
      body: IndexedStack(index: tab, children: [homeTab(), groupTab(), azkarTab(), logTab()]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: kCard,
        indicatorColor: kGreen,
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'المتصدرين'),
          NavigationDestination(icon: Icon(Icons.circle_outlined), selectedIcon: Icon(Icons.circle), label: 'الأذكار'),
          NavigationDestination(icon: Icon(Icons.list_outlined), selectedIcon: Icon(Icons.list), label: 'السجل'),
        ],
      ),
    );
  }
}
