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

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  String text(String key) {
    return _values[key] as String? ?? key;
  }

  Locale get alternateLocale =>
      isArabic ? const Locale('en') : const Locale('ar');
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
    final result = context
        .dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
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
    'welcomeSubtitle':
        'Discover top colleges and universities to shape your future',
    'login': 'Login',
    'createAccount': 'Create Account',
    'loginWithOtp': 'Login with OTP',
    'email': 'Email',
    'sendOtp': 'Send OTP',
    'verifyOtp': 'Verify OTP',
    'otpHelp': 'Enter the 6-digit OTP sent to your mobile no:',
    'resendOtp': 'Resend OTP in : 30 second',
    'verifyAndLogin': 'Verify & Login',
    'createYourAccount': 'Create Your Account',
    'fullName': 'Full Name',
    'mobileNumber': 'Mobile No.',
    'help': 'Help',
    'needHelp': 'Need Help?',
    'tapButtonBelow': 'Tap the button below?',
    'chatWithUs': 'CHAT WITH US',
    'termsPrivacy': 'Terms of Condition & Privacy policy',
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
    'aboutText':
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Arcu, arcu dictumst habitant vel ut et pellentesque. Ut in egestas blandit netus in scelerisque. Eget lectus ultrices pellentesque id...Read More',
    'rankingInfo': 'Ranking Info',
    'ranking': 'Ranking',
    'rankingValue': '#3 worldwide (2026)',
    'upcomingIntake': 'Upcoming Intake',
    'intakeDate': 'September 2026',
    'intakeMeta': '12th pass / Bachelor’s Degree',
    'viewCourses': 'View Courses',
    'cityOrCollege': 'College/University or City Name',
    'dashboard': 'Dashboard',
    'trackApplications': 'Track My Applications',
    'myProfile': 'My Profile',
    'manageDocuments': 'Manage Documents',
    'payments': 'Payments',
    'notifications': 'Notifications',
    'termsAndConditions': 'Terms & Conditions',
    'emergencyContact': 'Emergency Contact',
    'changeLanguage': 'Change Language',
    'logout': 'Logout',
    'versionLabel': 'Version 1.0.0',
    'stepUploadDoc': 'Upload Doc.',
    'stepVerify': 'Verify',
    'stepPayment': 'Payment',
    'stepStatus': 'Status',
    'payment': 'Payment',
    'applicationFeeSummary': 'Application Fee Summary',
    'applicationFee': 'Application Fee',
    'feeAmount': '₹1,500.00',
    'totalAmount': 'Total Amount',
    'paymentMethod': 'Payment Method',
    'creditCard': 'Credit Card',
    'upiPay': 'UPI Pay',
    'netBanking': 'Net Banking',
    'payNow': 'Pay Now',
    'paymentConfirmation': 'Payment Confirmation',
    'applicationSubmitted': 'Application Submitted',
    'applicationIdValue': 'Application ID : #12345',
    'paymentProcessedPrefix': 'Your payment of ₹1,500.00 for the Fall 2026',
    'paymentProcessedSuffix':
        'program has been processed. Your application is now in the review queue.',
    'trackApplication': 'Track Application',
    'downloadReceipt': 'Download Receipt',
    'applicationProgress': 'Application Progress',
    'submitted': 'Submitted',
    'completedOnDate': 'Completed on Feb 13',
    'underReview': 'Under Review',
    'underReviewSubtitle': 'Our admission team is reviewing your profile',
    'documentsVerified': 'Documents Verified',
    'pendingReview': 'Pending review',
    'acceptedRejected': 'Accepted/Rejected',
    'waitingDecision': 'Waiting for decision',
    'docPassport': 'Passport',
    'docPassportSubtitle': 'Valid for at least 6 months',
    'docSop': 'Statement of Purpose (SOP)',
    'docSopSubtitle': 'Words about your goals',
    'docLor': 'LOR',
    'docLorSubtitle': 'From 2 different academic reference',
    'docResume': 'Resume / CV',
    'docResumeSubtitle': 'Latest professional experience',
    'uploadAllRequiredDocs': 'Please upload all required documents.',
    'uploadDocuments': 'Upload Documents',
    'requiredDocuments': 'Required Documents',
    'saveContinue': 'Save & Continue',
    'tapToBrowse': 'Tap to Browse ',
    'uploadFormats': 'PDF / JPG / PNG',
    'supportedPrefix': 'Supported: ',
    'selectedPrefix': 'Selected: ',
    'documentsApprovedSuccessfully': 'Documents approved successfully',
    'applicationDeadlineReminder':
        'Reminder: Application deadline is approaching',
    'today': 'Today',
    'yesterday': 'Yesterday',
    'notificationDescription':
        'Short description explaining the notification details\nin a compact way...',
    'notificationTime': '10:00 PM',
    'notificationDate': '03 Mar 2026',
    'logoutConfirmMessage': 'Are you sure you want to log out?',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
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
    'help': 'مساعدة',
    'needHelp': 'تحتاج مساعدة؟',
    'tapButtonBelow': 'اضغط على الزر أدناه؟',
    'chatWithUs': 'تحدث معنا',
    'termsPrivacy': 'الشروط والأحكام وسياسة الخصوصية',
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
    'aboutText':
        'هذا النص تجريبي لعرض شكل المحتوى والوصف داخل بطاقة الجامعة كما في التصميم.',
    'rankingInfo': 'معلومات التصنيف',
    'ranking': 'التصنيف',
    'rankingValue': '#3 عالميًا (2026)',
    'upcomingIntake': 'الدفعة القادمة',
    'intakeDate': 'سبتمبر 2026',
    'intakeMeta': 'ثاني عشر / بكالوريوس',
    'viewCourses': 'عرض البرامج',
    'cityOrCollege': 'اسم الجامعة أو المدينة',
    'dashboard': 'الرئيسية',
    'trackApplications': 'تتبع طلباتي',
    'myProfile': 'ملفي الشخصي',
    'manageDocuments': 'إدارة المستندات',
    'payments': 'المدفوعات',
    'notifications': 'الإشعارات',
    'termsAndConditions': 'الشروط والأحكام',
    'emergencyContact': 'جهة اتصال الطوارئ',
    'changeLanguage': 'تغيير اللغة',
    'logout': 'تسجيل الخروج',
    'versionLabel': 'الإصدار 1.0.0',
    'stepUploadDoc': 'رفع المستندات',
    'stepVerify': 'التحقق',
    'stepPayment': 'الدفع',
    'stepStatus': 'الحالة',
    'payment': 'الدفع',
    'applicationFeeSummary': 'ملخص رسوم التقديم',
    'applicationFee': 'رسوم التقديم',
    'feeAmount': '₹1,500.00',
    'totalAmount': 'الإجمالي',
    'paymentMethod': 'طريقة الدفع',
    'creditCard': 'بطاقة ائتمان',
    'upiPay': 'UPI',
    'netBanking': 'الخدمات البنكية',
    'payNow': 'ادفع الآن',
    'paymentConfirmation': 'تأكيد الدفع',
    'applicationSubmitted': 'تم إرسال الطلب',
    'applicationIdValue': 'رقم الطلب : #12345',
    'paymentProcessedPrefix':
        'تمت معالجة دفعتك بقيمة ₹1,500.00 لبرنامج خريف 2026',
    'paymentProcessedSuffix': 'وأصبح طلبك الآن في قائمة المراجعة.',
    'trackApplication': 'تتبع الطلب',
    'downloadReceipt': 'تنزيل الإيصال',
    'applicationProgress': 'تقدم الطلب',
    'submitted': 'تم الإرسال',
    'completedOnDate': 'اكتمل في 13 فبراير',
    'underReview': 'قيد المراجعة',
    'underReviewSubtitle': 'يقوم فريق القبول بمراجعة ملفك',
    'documentsVerified': 'تم التحقق من المستندات',
    'pendingReview': 'بانتظار المراجعة',
    'acceptedRejected': 'قبول/رفض',
    'waitingDecision': 'بانتظار القرار',
    'docPassport': 'جواز السفر',
    'docPassportSubtitle': 'صالح لمدة لا تقل عن 6 أشهر',
    'docSop': 'خطاب الغرض (SOP)',
    'docSopSubtitle': 'نبذة عن أهدافك',
    'docLor': 'خطاب توصية',
    'docLorSubtitle': 'من مرجعين أكاديميين مختلفين',
    'docResume': 'السيرة الذاتية',
    'docResumeSubtitle': 'أحدث خبراتك المهنية',
    'uploadAllRequiredDocs': 'يرجى رفع جميع المستندات المطلوبة.',
    'uploadDocuments': 'رفع المستندات',
    'requiredDocuments': 'المستندات المطلوبة',
    'saveContinue': 'حفظ ومتابعة',
    'tapToBrowse': 'اضغط للتصفح ',
    'uploadFormats': 'PDF / JPG / PNG',
    'supportedPrefix': 'المدعوم: ',
    'selectedPrefix': 'المحدد: ',
    'documentsApprovedSuccessfully': 'تمت الموافقة على المستندات بنجاح',
    'applicationDeadlineReminder': 'تذكير: يقترب الموعد النهائي للتقديم',
    'today': 'اليوم',
    'yesterday': 'أمس',
    'notificationDescription': 'وصف مختصر يوضح تفاصيل الإشعار\nبطريقة موجزة...',
    'notificationTime': '10:00 مساءً',
    'notificationDate': '03 مارس 2026',
    'logoutConfirmMessage': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
  },
};
