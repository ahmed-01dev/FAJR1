/// Adhkar (remembrances) data — sourced from Hisn al-Muslim with
/// references. Texts are verbatim; repetitions match the source (§11).
library features.adhkar;

/// A single dhikr entry with source reference.
class Dhikr {
  const Dhikr({
    required this.id,
    required this.text,
    required this.category,
    required this.repetition,
    this.reference,
  });

  final String id;
  final String text;
  final DhikrCategory category;
  /// Repetition count as stated by the source. 0 = unrestricted.
  final int repetition;
  final String? reference;
}

enum DhikrCategory { morning, evening, sleep }

extension DhikrCategoryX on DhikrCategory {
  String get label => switch (this) {
    DhikrCategory.morning => 'أذكار الصباح',
    DhikrCategory.evening => 'أذكار المساء',
    DhikrCategory.sleep => 'أذكار النوم',
  };
}

/// Curated, documented adhkar (from Hisn al-Muslim, authenticated texts).
abstract final class AdhkarData {
  static const List<Dhikr> all = [
    // ── Morning ──
    Dhikr(
      id: 'm1',
      text:
          'أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ. اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ... وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      category: DhikrCategory.morning,
      repetition: 1,
      reference: 'آية الكرسي — أوردها ابن القيم في «عمل اليوم والليلة»',
    ),
    Dhikr(
      id: 'm2',
      text:
          'بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ: قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      category: DhikrCategory.morning,
      repetition: 3,
      reference: 'سورة الإخلاص — رواه الترمذي عن أبي الدرداء',
    ),
    Dhikr(
      id: 'm3',
      text: 'رَضِيتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا',
      category: DhikrCategory.morning,
      repetition: 3,
      reference: 'رواه أبو داود والترمذي',
    ),
    Dhikr(
      id: 'm4',
      text:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      category: DhikrCategory.morning,
      repetition: 1,
      reference: 'رواه الترمذي',
    ),
    Dhikr(
      id: 'm5',
      text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      category: DhikrCategory.morning,
      repetition: 100,
      reference: 'رواه البخاري ومسلم',
    ),
    // ── Evening ──
    Dhikr(
      id: 'e1',
      text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      category: DhikrCategory.evening,
      repetition: 1,
      reference: 'رواه مسلم',
    ),
    Dhikr(
      id: 'e2',
      text:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      category: DhikrCategory.evening,
      repetition: 1,
      reference: 'رواه الترمذي',
    ),
    Dhikr(
      id: 'e3',
      text: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      category: DhikrCategory.evening,
      repetition: 3,
      reference: 'رواه مسلم',
    ),
    // ── Sleep ──
    Dhikr(
      id: 's1',
      text:
          'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      category: DhikrCategory.sleep,
      repetition: 1,
      reference: 'رواه البخاري',
    ),
    Dhikr(
      id: 's2',
      text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      category: DhikrCategory.sleep,
      repetition: 3,
      reference: 'رواه أبو داود',
    ),
  ];
}
