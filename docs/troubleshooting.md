# حل المشكلات

## فشل `flutter pub get`
- تأكد من تثبيت Flutter stable: `flutter --version`
- امسح الكاش: `flutter clean && flutter pub get`

## مشكلات Gradle / Android SDK
- تأكد من `local.properties` يشير لـ Android SDK الصحيح.
- حدّث Gradle wrapper: الرجوع لملف `android/gradle/wrapper/gradle-wrapper.properties`.
- خطأ `SDK location not found`: ضع `sdk.dir=/path/to/android-sdk` في `android/local.properties`.

## فشل البناء في GitHub Actions
1. افتح تبويب **Actions** ← التشغيل الأحمر ← الخطوة الحمراء ← اقرأ آخر الأسطر.
2. أخطاء التحليل: ثبّت Flutter محليًا وشغّل `flutter analyze` لإعادة الإنتاج.
3. خطأ `google-services.json missing`: الوضع المحلي لا يحتاجه — لا يجب أن يظهر.

## الإشعارات لا تظهر
- أندرويد 13+: الإذن `POST_NOTIFICATIONS` يُطلب من المستخدم — تحقق من إعدادات التطبيق.
- وضع توفير الطاقة في بعض الأجهزة (Xiaomi, Huawei) يؤجل التنبيهات الدقيقة — موثّق كقيود معروفة للنظام.

## مواقيت غير منطقية
- تحقق من المدينة المختارة وطريقة الحساب من الإعدادات.
- تأكد من صحة توقيت الجهاز (تلقائي من الشبكة).

## تعارض الإصدارات
- `flutter pub deps` لعرض شجرة الاعتمادات.
- `flutter pub outdated` لفحص التحديثات المتاحة.
