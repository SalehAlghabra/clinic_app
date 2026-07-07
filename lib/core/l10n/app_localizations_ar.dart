// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نظام إدارة العيادة';

  @override
  String get languageCode => 'ar';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get ok => 'حسنًا';

  @override
  String get success => 'نجاح';

  @override
  String get error => 'خطأ';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get networkError => 'لا يوجد اتصال بالإنترنت. يرجى التحقق من شبكتك.';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للوصول إلى ملفك في العيادة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'مثال: name@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'انضم إلينا لإدارة مواعيدك';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'مثال: محمد أحمد';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => 'مثال: 0501234567';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get registerButton => 'إنشاء الحساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get otpTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get otpSubtitle => 'أرسلنا رمزًا من 6 أرقام إلى';

  @override
  String get otpCodeLabel => 'أدخل رمز التحقق';

  @override
  String get verifyButton => 'تحقق وتسجيل الدخول';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get otpSentMessage => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني.';

  @override
  String get otpResentMessage => 'تمت إعادة إرسال رمز التحقق.';

  @override
  String get splashTagline => 'صحتك، أولويتنا.';

  @override
  String get patientDashboard => 'لوحة تحكم المريض';

  @override
  String get doctorDashboard => 'لوحة تحكم الطبيب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح.';

  @override
  String get walletTitle => 'محفظتي';

  @override
  String get walletBalance => 'رصيد المحفظة';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get appointmentsTitle => 'المواعيد';

  @override
  String get bookAppointment => 'حجز موعد';

  @override
  String get myAppointments => 'مواعيدي';

  @override
  String get medicalRecordsTitle => 'السجلات الطبية';

  @override
  String get invoicesTitle => 'الفواتير';

  @override
  String get doctorsTitle => 'الأطباء';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String requiredField(String field) {
    return '$field مطلوب';
  }

  @override
  String get invalidEmail => 'أدخل عنوان بريد إلكتروني صحيح';

  @override
  String get passwordTooShort =>
      'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get noDataFound => 'لا توجد بيانات';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get status_pending => 'في الانتظار';

  @override
  String get status_confirmed => 'مؤكد';

  @override
  String get status_rejected => 'مرفوض';

  @override
  String get status_cancelled => 'ملغى';

  @override
  String get status_completed => 'مكتمل';

  @override
  String get transactionType_deposit => 'إيداع';

  @override
  String get transactionType_booking_deduct => 'خصم الحجز';

  @override
  String get transactionType_refund_full => 'استرداد كامل';

  @override
  String get transactionType_refund_partial => 'استرداد جزئي';

  @override
  String get transactionType_penalty => 'غرامة';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTimeSlot => 'اختر وقت الحجز';

  @override
  String get bookingSummary => 'ملخص الحجز';

  @override
  String get paymentDetails => 'تفاصيل الدفع';

  @override
  String get depositRequired => 'مبلغ التأمين المطلوب';

  @override
  String get balanceAfter => 'الرصيد بعد الخصم';

  @override
  String get remainingAtVisit => 'المتبقي عند الزيارة';

  @override
  String get insufficientBalance => 'رصيد غير كافٍ. يرجى شحن محفظتك.';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get notesLabel => 'ملاحظات (اختياري)';

  @override
  String get cancellationReason => 'سبب الإلغاء (اختياري)';

  @override
  String get upcomingAppointments => 'المقبلة';

  @override
  String get pastAppointments => 'المنتهية والملغاة';

  @override
  String get cancelAppointmentConfirm => 'هل أنت متأكد من إلغاء هذا الموعد؟';

  @override
  String get noAppointments => 'لا توجد مواعيد حالية';

  @override
  String get appointmentBookedSuccess => 'تم حجز الموعد بنجاح!';

  @override
  String get appointmentCancelledSuccess => 'تم إلغاء الموعد بنجاح!';
}
