# إعداد Firebase (اختياري)

التطبيق يعمل بالكامل دون Firebase — المواقيت والأذكار والتقدم والإعدادات كلها محلية. Firebase يلزم فقط للميزات الاجتماعية (الحسابات، الصحبة، الفرق، المزامنة).

## الخطوات

1. **إنشاء المشروع:** [console.firebase.google.com](https://console.firebase.google.com) ← **Add project** ← سمّه مثلًا `fajr-app`.

2. **تفعيل المصادقة:** **Build ← Authentication ← Get started** ← فعّل **Email/Password**.

3. **إنشاء Firestore:** **Build ← Firestore Database ← Create database** ← اختر وضع الإنتاج.

4. **إضافة تطبيق Android:** **Project settings ← Your apps ← Android** ← اسم الحزمة: `com.fajr.app` ← حمّل `google-services.json`.

5. **وضع ملف الإعداد محليًا** (⚠️ لا ترفعه أبدًا إلى المستودع — `.gitignore` يستبعده):
   ```
   android/app/google-services.json
   ```

6. **نشر القواعد:** انسخ محتوى `firestore.rules` ← **Firestore Database ← Rules ← Publish**. القواعد تمنع:
   - قراءة بيانات مستخدم آخر
   - تعديل XP أو streak من العميل (خادم فقط)
   - الانضمام المباشر للفرق (عبر دوال فقط)
   - وصول غير المسجلين لأي بيانات

7. **نشر الفهارس:** نفّذ محليًا:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase deploy --only firestore:rules,firestore:indexes
   ```

8. **دوال الخادم:** انشر مجلد `functions/` عند توفره:
   ```bash
   firebase deploy --only functions
   ```

9. **الإشعارات:** **Build ← Cloud Messaging** ← سجّل token الجهاز من التطبيق بعد تهيئة `firebase_messaging`.

## ملاحظات أمنية

- أي قيمة داخل تطبيق Flutter ليست سرًا — `google-services.json` معرّفات عميل عامة، لكنها تبقى خارج المستودع للنظافة فقط.
- مفاتيح الخادم الحقيقية (Service Account) تُدار عبر Firebase CLI أو Secrets ولا توضع في التطبيق إطلاقًا.
- اختبار القواعد: شغّل Emulator Suite محليًا قبل النشر:
  ```bash
  firebase emulators:start --only firestore,auth
  ```
