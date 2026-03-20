import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._values);

  final Locale locale;
  final Map<String, dynamic> _values;

  static Future<AppLocalizations> load(Locale locale) async {
    final code = supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';
    final raw = await rootBundle.loadString('assets/i18n/$code.json');
    final values = jsonDecode(raw) as Map<String, dynamic>;
    return AppLocalizations(Locale(code), values);
  }

  factory AppLocalizations.fallback(Locale locale) {
    final code = supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';
    return AppLocalizations(Locale(code), _fallbackValues[code]!);
  }

  static const supportedLanguageCodes = ['en', 'ar'];

  bool get isArabic => locale.languageCode == 'ar';

  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  String text(String key) {
    return _values[key] as String? ?? key;
  }

  Locale get alternateLocale => isArabic ? const Locale('en') : const Locale('ar');
}

class AppLocalizationScope extends InheritedWidget {
  const AppLocalizationScope({
    super.key,
    required this.localizations,
    required this.changeLanguage,
    required super.child,
  });

  final AppLocalizations localizations;
  final ValueChanged<Locale> changeLanguage;

  static AppLocalizationScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    assert(result != null, 'No AppLocalizationScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppLocalizationScope oldWidget) {
    return oldWidget.localizations.locale != localizations.locale;
  }
}

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizationScope.of(this).localizations;

  void toggleLanguage() {
    final scope = AppLocalizationScope.of(this);
    scope.changeLanguage(scope.localizations.alternateLocale);
  }
}

const Map<String, Map<String, dynamic>> _fallbackValues = {
  'en': {
    'appName': 'Arab Universities',
    'langLabel': 'AR',
    'welcomeTitle': 'Welcome to Arab\nUniversities',
    'welcomeSubtitle': 'Discover top colleges and universities to shape your future',
    'login': 'Login',
    'createAccount': 'Create Account',
    'loginWithOtp': 'Login with OTP',
    'email': 'Email',
    'sendOtp': 'Send OTP',
    'verifyOtp': 'Verify OTP',
    'otpHelp': 'Enter the 6-digit OTP sent to your email:',
    'resendOtp': 'Resend OTP in : 30 second',
    'verifyAndLogin': 'Verify & Login',
    'createYourAccount': 'Create Your Account',
    'fullName': 'Full Name',
    'mobileNumber': 'Mobile No.',
    'country': 'Country',
    'termsPrefix': 'I have read and agree with the ',
    'termsLink': 'Terms & Conditions.',
    'alreadyHaveAccount': 'Already have an account? ',
    'latestAcademic': 'Latest Academic',
    'inputResult': 'Input Result',
    'courseOrProgram': 'Course or Program',
    'continue': 'Continue',
    'arab': 'Arab',
    'bachelorCs': 'Bachelor of Computer Science',
    'otpDemoHint': 'Demo OTP is prefilled for UI preview.',
    'searchHint': 'University of',
    'moreFilters': 'More Filters',
    'findPerfectUniversity': 'Find Your Perfect Arab\nUniversity',
    'universityCount': '+500 University',
    'popularUniversities': 'Popular Universities',
    'viewDetails': 'View Details',
    'university': 'University',
    'college': 'College',
    'privateSchool': 'Private School',
    'location': 'Location',
    'about': 'About',
    'aboutText': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Arcu, arcu dictumst habitant vel ut et pellentesque. Ut in egestas blandit netus in scelerisque. Eget lectus ultrices pellentesque id...Read More',
    'rankingInfo': 'Ranking Info',
    'ranking': 'Ranking',
    'rankingValue': '#3 worldwide (2026)',
    'upcomingIntake': 'Upcoming Intake',
    'intakeDate': 'September 2026',
    'intakeMeta': '12th pass / Bachelor’s Degree',
    'viewCourses': 'View Courses',
    'cityOrCollege': 'College/University or City Name',
  },
  'ar': {
    'appName': 'جامعات العرب',
    'langLabel': 'EN',
    'welcomeTitle': 'مرحبًا بك في\nجامعات العرب',
    'welcomeSubtitle': 'اكتشف أفضل الكليات والجامعات لصناعة مستقبلك',
    'login': 'تسجيل الدخول',
    'createAccount': 'إنشاء حساب',
    'loginWithOtp': 'تسجيل الدخول عبر OTP',
    'email': 'البريد الإلكتروني',
    'sendOtp': 'إرسال OTP',
    'verifyOtp': 'تأكيد OTP',
    'otpHelp': 'أدخل رمز OTP المكوّن من 6 أرقام المرسل إلى بريدك الإلكتروني:',
    'resendOtp': 'إعادة إرسال OTP خلال : 30 ثانية',
    'verifyAndLogin': 'تأكيد وتسجيل الدخول',
    'createYourAccount': 'أنشئ حسابك',
    'fullName': 'الاسم الكامل',
    'mobileNumber': 'رقم الجوال',
    'country': 'الدولة',
    'termsPrefix': 'لقد قرأت وأوافق على ',
    'termsLink': 'الشروط والأحكام.',
    'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
    'latestAcademic': 'آخر مؤهل أكاديمي',
    'inputResult': 'أدخل النتيجة',
    'courseOrProgram': 'التخصص أو البرنامج',
    'continue': 'متابعة',
    'arab': 'العرب',
    'bachelorCs': 'بكالوريوس علوم الحاسب',
    'otpDemoHint': 'تم تعبئة OTP مسبقًا لعرض الواجهة.',
    'searchHint': 'جامعة أو مدينة',
    'moreFilters': 'المزيد من الفلاتر',
    'findPerfectUniversity': 'اعثر على جامعة\nالعرب المثالية',
    'universityCount': '+500 جامعة',
    'popularUniversities': 'الجامعات الشائعة',
    'viewDetails': 'عرض التفاصيل',
    'university': 'جامعة',
    'college': 'كلية',
    'privateSchool': 'مدرسة خاصة',
    'location': 'الموقع',
    'about': 'نبذة',
    'aboutText': 'هذا النص تجريبي لعرض شكل المحتوى والوصف داخل بطاقة الجامعة كما في التصميم.',
    'rankingInfo': 'معلومات التصنيف',
    'ranking': 'التصنيف',
    'rankingValue': '#3 عالميًا (2026)',
    'upcomingIntake': 'الدفعة القادمة',
    'intakeDate': 'سبتمبر 2026',
    'intakeMeta': 'ثاني عشر / بكالوريوس',
    'viewCourses': 'عرض البرامج',
    'cityOrCollege': 'اسم الجامعة أو المدينة',
  },
};
