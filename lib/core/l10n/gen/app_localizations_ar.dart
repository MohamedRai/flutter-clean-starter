// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Clean Starter';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get emptyGeneric => 'لا يوجد شيء هنا بعد.';

  @override
  String get failureServer => 'حدث خطأ من جهتنا. يرجى المحاولة لاحقًا.';

  @override
  String get failureNetwork =>
      'تعذّر الوصول إلى الخادم. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get failureCache => 'لا توجد بيانات محفوظة.';

  @override
  String get failureUnauthorized => 'انتهت جلستك. يرجى تسجيل الدخول مجددًا.';

  @override
  String get failureForbidden => 'ليست لديك صلاحية القيام بذلك.';

  @override
  String get failureNotFound => 'لم نعثر على ما تبحث عنه.';

  @override
  String get failureBadRequest =>
      'تعذّرت معالجة الطلب. يرجى التحقق من المدخلات.';

  @override
  String get failureRateLimit =>
      'طلبات كثيرة جدًا. يرجى الانتظار قليلًا ثم المحاولة.';

  @override
  String get failureValidation => 'يرجى التحقق من الحقول المميزة.';

  @override
  String get failureUnknown => 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get navPosts => 'المنشورات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get accountSignedIn => 'أنت مسجّل الدخول (جلسة تجريبية).';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signInMessage =>
      'توضح هذه الصفحة حارس المصادقة في الموجّه. سجّل الدخول لفتح صفحة الحساب.';

  @override
  String get signInButton => 'تسجيل الدخول (تجريبي)';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundMessage => 'الصفحة المطلوبة غير موجودة.';

  @override
  String get goHome => 'الرئيسية';

  @override
  String get postsTitle => 'المنشورات';

  @override
  String get postsEmpty => 'لا توجد منشورات بعد.';

  @override
  String get postDetailTitle => 'منشور';

  @override
  String postAuthor(int userId) {
    return 'بواسطة المستخدم رقم $userId';
  }
}
