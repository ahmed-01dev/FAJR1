# البناء والإصدار

## APK تجريبي (Debug)

```bash
flutter build apk --debug
# الناتج: build/app/outputs/flutter-apk/app-debug.apk
```

## APK إصدار (Release) — بالتوقيع الافتراضي

الإعداد الحالي يستخدم توقيع debug للـ release (مناسب للاختبار فقط):

```bash
flutter build apk --release
# الناتج: build/app/outputs/flutter-apk/app-release.apk
```

## توقيع إنتاجي حقيقي (قبل النشر)

1. **إنشاء مفتاح توقيع** (لا يُرفع للمستودع أبدًا):
   ```bash
   keytool -genkey -v -keystore fajr-release.keystore -alias fajr \
     -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **إنشاء `android/key.properties`** (مستبعد في `.gitignore`):
   ```properties
   storePassword=كلمة_مرور_المخزن
   keyPassword=كلمة_مرور_المفتاح
   keyAlias=fajr
   storeFile=../fajr-release.keystore
   ```

3. **تعديل `android/app/build.gradle`** — استبدل قسم `signingConfigs`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile file(keystoreProperties['storeFile'])
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.release
           }
       }
   }
   ```

4. **أو عبر GitHub Secrets:** ضع القيم كـ Secrets وعدّل workflow ليقرأها — توثيق كامل في [GitHub docs](https://docs.github.com/actions/security-guides/encrypted-secrets).

## App Bundle (لـ Google Play)

```bash
flutter build appbundle --release
# الناتج: build/app/outputs/bundle/release/app-release.aab
```

## APK من CI

من تبويب **Actions** ← آخر تشغيل ناجح ← **Artifacts** ← `fajr-release-apk`.

## قبل النشر الرسمي (Google Play)

- [ ] توقيع إنتاجي (الأعلى)
- [ ] سياسة خصوصية على رابط ويب عام (محتوى جاهز في `docs/privacy-policy.md`)
- [ ] أيقونة تطبيق نهائية (الحالية placeholder)
- [ ] مراجعة Google Play واختبار على أجهزة فعلية
