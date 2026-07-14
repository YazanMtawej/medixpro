// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ميديكس برو';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get menu => 'القائمة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPatients => 'المرضى';

  @override
  String get navReports => 'التقارير';

  @override
  String get navMeds => 'الأدوية';

  @override
  String get navSchedule => 'المواعيد';

  @override
  String get navRequests => 'الطلبات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navMyAppointments => 'مواعيدي';

  @override
  String get appointmentsPerformance => 'أداء المواعيد';

  @override
  String get pendingVisits => 'زيارات معلقة';

  @override
  String get finishedToday => 'أُنجزت اليوم';

  @override
  String get allAppointments => 'جميع المواعيد';

  @override
  String get patientDemographics => 'التركيبة السكانية للمرضى';

  @override
  String get populationDistribution => 'نظرة عامة على توزيع السكان';

  @override
  String get maleRatio => 'نسبة الذكور';

  @override
  String get femaleRatio => 'نسبة الإناث';

  @override
  String get liveOverviewToday => 'نظرة حية على جدول اليوم';

  @override
  String successRate(int rate) {
    return '$rate% نجاح';
  }

  @override
  String get clinicStrongToday => 'أداء العيادة يبدو قوياً اليوم.';

  @override
  String get roomToImprove => 'هناك مجال لتحسين معدل الإنجاز.';

  @override
  String patientsCount(int count) {
    return '$count مريض';
  }

  @override
  String get femaleLargerSegment => 'المريضات يمثلن الشريحة الأكبر.';

  @override
  String get maleLargerSegment => 'المرضى الذكور يمثلون الشريحة الأكبر.';

  @override
  String get totalPatients => 'إجمالي المرضى';

  @override
  String get prescriptions => 'الوصفات الطبية';

  @override
  String get finalReports => 'التقارير النهائية';

  @override
  String get drafts => 'المسودات';

  @override
  String get todaysAppointments => 'مواعيد اليوم';

  @override
  String get todaysSchedule => 'جدول اليوم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noAppointmentsToday => 'لا توجد مواعيد اليوم';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get sectionNotifications => 'الإشعارات';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get sectionGeneral => 'عام';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profileSubtitle => 'عرض وتعديل ملفك الشخصي';

  @override
  String get patientAccounts => 'حسابات المرضى';

  @override
  String get patientAccountsSubtitle => 'إدارة وحذف حسابات المرضى';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsSubtitle => 'عرض جميع التنبيهات والتحديثات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get appearanceSubtitle => 'تبديل مظهر التطبيق';

  @override
  String get useArabic => 'العربية';

  @override
  String get languageSubtitle => 'تغيير لغة التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get smartClinicManagement => 'إدارة العيادة الذكية';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInToYourAccount => 'سجّل الدخول إلى حسابك';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get checkingCredentials => 'جارٍ التحقق من البيانات...';

  @override
  String get allRightsReserved => '© 2026 ميديكس برو · جميع الحقوق محفوظة';

  @override
  String get roleSelection => 'اختيار الدور';

  @override
  String get whoAreYou => 'من أنت؟';

  @override
  String get selectYourRole => 'اختر دورك للبدء';

  @override
  String get patient => 'مريض';

  @override
  String get patientRoleSubtitle => 'احجز المواعيد واطّلع على سجلاتك';

  @override
  String get doctor => 'طبيب';

  @override
  String get doctorRoleSubtitle => 'إدارة المرضى وعمليات العيادة';

  @override
  String get doctorVerification => 'التحقق من الطبيب';

  @override
  String get doctorVerificationPrompt =>
      'أدخل رمز التحقق المقدّم من مسؤول العيادة.';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get enterCode => 'أدخل الرمز...';

  @override
  String get dontHaveCode => 'ليس لديك رمز؟ تواصل مع المسؤول.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get pleaseEnterCode => 'يرجى إدخال الرمز';

  @override
  String get invalidVerificationCode => 'رمز التحقق غير صحيح';

  @override
  String get patientRegistration => 'تسجيل مريض';

  @override
  String get doctorRegistration => 'تسجيل طبيب';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get usernameRequired => 'اسم المستخدم مطلوب';

  @override
  String get atLeast3Chars => '3 أحرف على الأقل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get enterValidEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get atLeast8Chars => '8 أحرف على الأقل';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get age => 'العمر';

  @override
  String get ageRequired => 'العمر مطلوب';

  @override
  String get enterValidAge => 'أدخل عمراً صحيحاً (1–150)';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get enterValidPhone => 'أدخل رقم هاتف صحيح';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get initializingSystems => 'جارٍ تهيئة الأنظمة...';

  @override
  String get versionEdition => 'الإصدار 2.4.0 · نسخة المؤسسات';

  @override
  String get onboardTitle1 => 'احجز المواعيد فوراً';

  @override
  String get onboardSubtitle1 =>
      'اعثر على الطبيب المناسب واحجز المواعيد خلال ثوانٍ — بلا انتظار ولا مكالمات.';

  @override
  String get onboardTitle2 => 'سجلات طبية ذكية';

  @override
  String get onboardSubtitle2 =>
      'اطّلع على تاريخك الصحي ووصفاتك وتقاريرك في أي وقت بمكان واحد آمن.';

  @override
  String get onboardTitle3 => 'تواصل بين الطبيب والمريض';

  @override
  String get onboardSubtitle3 =>
      'ابقَ على تواصل مع طبيبك، واستقبل التحديثات، وأدِر رعايتك بسهولة.';

  @override
  String get startYourJourney => 'ابدأ رحلتك';

  @override
  String get continueLabel2 => 'متابعة';

  @override
  String get precisionHealthcare => 'رعاية صحية دقيقة · 2026';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get role => 'الدور';

  @override
  String get clinicInformation => 'معلومات العيادة';

  @override
  String get clinicName => 'اسم العيادة';

  @override
  String get address => 'العنوان';

  @override
  String get markAllAsRead => 'تعليم الكل كمقروء';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountWarningPrefix => 'سيؤدي هذا إلى حذف ';

  @override
  String get deleteAccountWarningSuffix =>
      ' وجميع البيانات المرتبطة به نهائياً:\n\n• السجلات الطبية\n• المواعيد\n• التقارير\n• الوصفات\n\nلا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deletePermanently => 'حذف نهائي';

  @override
  String deletedSuccessfully(String name) {
    return 'تم حذف $name بنجاح';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noPatientAccounts => 'لا توجد حسابات مرضى';

  @override
  String get patientsAppearHere => 'يظهر المرضى المسجّلون هنا';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String joinedLabel(String date) {
    return 'انضم: $date';
  }

  @override
  String get searchByNameOrPhone => 'ابحث بالاسم أو الهاتف...';

  @override
  String get total => 'الإجمالي';

  @override
  String get noPatientsYet => 'لا يوجد مرضى بعد';

  @override
  String noResultsFor(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get addPatient => 'إضافة مريض';

  @override
  String get editPatient => 'تعديل المريض';

  @override
  String get deletePatient => 'حذف المريض';

  @override
  String get deletePatientWarning =>
      'سيؤدي هذا إلى حذف المريض وجميع السجلات المرتبطة به نهائياً.';

  @override
  String get delete => 'حذف';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get contactInformation => 'معلومات التواصل';

  @override
  String get emergencyContact => 'جهة اتصال للطوارئ';

  @override
  String get medicalInformation => 'المعلومات الطبية';

  @override
  String get nationalId => 'الرقم الوطني';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get bloodType => 'فصيلة الدم';

  @override
  String get contactName => 'اسم جهة الاتصال';

  @override
  String get contactPhone => 'هاتف جهة الاتصال';

  @override
  String get allergies => 'الحساسية';

  @override
  String get chronicDiseases => 'الأمراض المزمنة';

  @override
  String get previousSurgeries => 'العمليات السابقة';

  @override
  String get currentMedications => 'الأدوية الحالية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get savePatient => 'حفظ المريض';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get phone => 'الهاتف';

  @override
  String get name => 'الاسم';

  @override
  String yrsLabel(int age) {
    return '$age سنة';
  }

  @override
  String ageYearsGender(int age, String gender) {
    return '$age سنة · $gender';
  }

  @override
  String bloodLabel(String type) {
    return 'الدم: $type';
  }

  @override
  String agePhoneLabel(int age, String phone) {
    return 'العمر: $age | $phone';
  }

  @override
  String get medicalReports => 'التقارير الطبية';

  @override
  String get searchByReportTitle => 'ابحث بعنوان التقرير أو المريض...';

  @override
  String get statusAll => 'الكل';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusFinal => 'نهائي';

  @override
  String get noReportsFound => 'لا توجد تقارير';

  @override
  String get deleteReport => 'حذف التقرير';

  @override
  String get deleteReportWarning => 'سيتم حذف هذا التقرير الطبي نهائياً.';

  @override
  String get newReport => 'تقرير جديد';

  @override
  String get untitledReport => 'تقرير بدون عنوان';

  @override
  String get unknownPatient => 'مريض غير معروف';

  @override
  String medicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أدوية',
      one: 'دواء واحد',
    );
    return '$_temp0';
  }

  @override
  String get patientInformation => 'معلومات المريض';

  @override
  String ageYears(String age) {
    return '$age سنة';
  }

  @override
  String get linkedAppointment => 'الموعد المرتبط';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get typeLabel => 'النوع';

  @override
  String get status => 'الحالة';

  @override
  String get clinicalInformation => 'المعلومات السريرية';

  @override
  String get chiefComplaint => 'الشكوى الرئيسية';

  @override
  String get medicalHistory => 'التاريخ الطبي';

  @override
  String get physicalExamination => 'الفحص السريري';

  @override
  String get diagnosis => 'التشخيص';

  @override
  String get treatmentPlan => 'خطة العلاج';

  @override
  String get doctorNotes => 'ملاحظات الطبيب';

  @override
  String get followUpDate => 'تاريخ المتابعة';

  @override
  String get prescribedMedications => 'الأدوية الموصوفة';

  @override
  String get newMedicalReport => 'تقرير طبي جديد';

  @override
  String get selectPatient => 'اختر المريض';

  @override
  String get patientLabel => 'المريض';

  @override
  String get pleaseSelectPatient => 'يرجى اختيار مريض';

  @override
  String get reportTitle => 'عنوان التقرير';

  @override
  String get linkedAppointmentOptional => 'الموعد المرتبط (اختياري)';

  @override
  String get selectPatientFirst => 'اختر المريض أولاً';

  @override
  String get noAppointmentsFound => 'لا توجد مواعيد';

  @override
  String get selectAppointment => 'اختر الموعد';

  @override
  String get none => 'بدون';

  @override
  String get noMedicationsForPatient => 'لا توجد أدوية لهذا المريض';

  @override
  String get clinicalDetails => 'التفاصيل السريرية';

  @override
  String get saveReport => 'حفظ التقرير';

  @override
  String get followUpDateOptional => 'تاريخ المتابعة (اختياري)';

  @override
  String get notSet => 'غير محدد';

  @override
  String get editReport => 'تعديل التقرير';

  @override
  String get updateReport => 'تحديث التقرير';

  @override
  String get medicationsTitle => 'الأدوية';

  @override
  String get searchMedicationOrPatient => 'ابحث عن دواء أو مريض...';

  @override
  String get newPrescription => 'وصفة جديدة';

  @override
  String get deletePrescription => 'حذف الوصفة';

  @override
  String get deletePrescriptionWarning => 'سيتم حذف هذه الوصفة نهائياً.';

  @override
  String get noPrescriptionsYet => 'لا توجد وصفات بعد';

  @override
  String get tapToAddPrescription => 'اضغط + لإضافة وصفة جديدة';

  @override
  String durationDaysShort(int days) {
    return '$days يوم';
  }

  @override
  String get commonMedications => 'الأدوية الشائعة';

  @override
  String get searchCommonMedications => 'ابحث في الأدوية الشائعة...';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get dosage => 'الجرعة';

  @override
  String get dosageHint => 'الجرعة (مثال: 500 ملغ)';

  @override
  String get frequency => 'التكرار';

  @override
  String get routeLabel => 'طريقة الإعطاء';

  @override
  String get durationDays => 'المدة (أيام)';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get selectShort => 'اختر';

  @override
  String get instructions => 'التعليمات';

  @override
  String get instructionsHint => 'التعليمات (مثال: تؤخذ بعد الطعام)';

  @override
  String get additionalNotes => 'ملاحظات إضافية';

  @override
  String get savePrescription => 'حفظ الوصفة';

  @override
  String get editPrescription => 'تعديل الوصفة';

  @override
  String get updatePrescription => 'تحديث الوصفة';

  @override
  String get freqOnceDaily => 'مرة يومياً';

  @override
  String get freqTwiceDaily => 'مرتين يومياً';

  @override
  String get freqThreeTimesDaily => 'ثلاث مرات يومياً';

  @override
  String get freqFourTimesDaily => 'أربع مرات يومياً';

  @override
  String get freqEvery8Hours => 'كل 8 ساعات';

  @override
  String get freqEvery12Hours => 'كل 12 ساعة';

  @override
  String get freqAsNeeded => 'عند الحاجة';

  @override
  String get freqWeekly => 'أسبوعياً';

  @override
  String get routeOral => 'فموي';

  @override
  String get routeInjection => 'حقن';

  @override
  String get routeTopical => 'موضعي';

  @override
  String get routeInhalation => 'استنشاق';

  @override
  String get routeSublingual => 'تحت اللسان';

  @override
  String get routeIv => 'وريدي (IV)';

  @override
  String get routeEyeDrops => 'قطرة عين';

  @override
  String get routeEarDrops => 'قطرة أذن';

  @override
  String get appointmentsTitle => 'المواعيد';

  @override
  String get newAppointment => 'موعد جديد';

  @override
  String get appointmentTitle => 'عنوان الموعد';

  @override
  String get durationMinutesLabel => 'المدة (بالدقائق)';

  @override
  String get editAppointment => 'تعديل الموعد';

  @override
  String get saveAppointment => 'حفظ الموعد';

  @override
  String get updateAppointment => 'تحديث الموعد';

  @override
  String get appointmentDetails => 'تفاصيل الموعد';

  @override
  String get searchAppointmentOrPatient => 'ابحث عن موعد أو مريض...';

  @override
  String get pleaseSelectDateAndTime => 'يرجى اختيار التاريخ والوقت';

  @override
  String get pleaseSelectBothDateTime => 'يرجى اختيار التاريخ والوقت معاً';

  @override
  String get appointmentDeleteWarning => 'سيتم حذف هذا الموعد نهائياً.';

  @override
  String get deleteAppointment => 'حذف الموعد';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get reason => 'السبب';

  @override
  String get reasonForVisit => 'سبب الزيارة';

  @override
  String get symptoms => 'الأعراض';

  @override
  String get followUp => 'المتابعة';

  @override
  String get duration => 'المدة';

  @override
  String minutesValue(int count) {
    return '$count دقيقة';
  }

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get noAppointmentsYet => 'لا توجد مواعيد بعد';

  @override
  String get startByBooking => 'ابدأ بحجز موعدك الأول';

  @override
  String get upcoming => 'القادمة';

  @override
  String get upcomingAppointments => 'المواعيد القادمة';

  @override
  String get welcomeBackEmoji => 'مرحباً بعودتك 👋';

  @override
  String get yourHealthSimplified => 'صحتك، ببساطة';

  @override
  String get typeFollowUp => 'متابعة';

  @override
  String get typeConsultation => 'استشارة';

  @override
  String get typeEmergency => 'طارئ';

  @override
  String get typeGeneral => 'عام';

  @override
  String get typeLabResults => 'نتائج المختبر';

  @override
  String get typeProcedure => 'إجراء';

  @override
  String get typeVaccination => 'تطعيم';

  @override
  String get today => 'اليوم';

  @override
  String get statusScheduled => 'مجدول';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusNoShow => 'لم يحضر';

  @override
  String get statusRescheduled => 'أُعيد جدولته';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusSuggested => 'مقترح';

  @override
  String get tabSuggested => 'مقترحة';

  @override
  String get tabDone => 'منتهية';

  @override
  String get nothingHereYet => 'لا يوجد شيء هنا بعد';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String suggestedDateLabel(String date) {
    return 'المقترح: $date';
  }

  @override
  String get patientWillBeNotifiedSuggest =>
      'سيتم إخطار المريض ويمكنه التأكيد أو الرفض.';

  @override
  String get appointmentRequests => 'طلبات المواعيد';

  @override
  String get reviewRespondRequests => 'راجع طلبات المرضى وردّ عليها';

  @override
  String get requested => 'المطلوب';

  @override
  String get accept => 'قبول';

  @override
  String get suggest => 'اقتراح';

  @override
  String get reject => 'رفض';

  @override
  String get acceptRequest => 'قبول الطلب';

  @override
  String get appointmentCreatedAtRequestedTime =>
      'سيتم إنشاء الموعد في الوقت الذي طلبه المريض.';

  @override
  String get optionalNoteForPatient => 'ملاحظة اختيارية للمريض';

  @override
  String get confirm => 'تأكيد';

  @override
  String get suggestAlternativeTime => 'اقتراح وقت بديل';

  @override
  String get noteForPatientOptional => 'ملاحظة للمريض (اختياري)';

  @override
  String get sendSuggestion => 'إرسال الاقتراح';

  @override
  String get rejectRequest => 'رفض الطلب';

  @override
  String get patientNotifiedRejection => 'سيتم إخطار المريض بالرفض.';

  @override
  String get reasonForRejectionOptional => 'سبب الرفض (اختياري)';

  @override
  String get clearCompleted => 'مسح المكتملة';

  @override
  String get clear => 'مسح';

  @override
  String get declineSuggestion => 'رفض الاقتراح';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get decline => 'رفض';

  @override
  String get doctorProposedNewTime => 'اقترح الطبيب وقتاً جديداً';

  @override
  String noteWithText(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String get noRequestsYet => 'لا توجد طلبات بعد';

  @override
  String get tapNewRequestToBook => 'اضغط \"طلب جديد\" لحجز موعدك الأول';

  @override
  String sentAgo(String time) {
    return 'أُرسل $time';
  }

  @override
  String get requestDetails => 'تفاصيل الطلب';

  @override
  String get preferredDateTime => 'التاريخ والوقت المفضّل';

  @override
  String get additionalInfoOptional => 'معلومات إضافية (اختياري)';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get clearCompletedConfirm =>
      'إزالة جميع الطلبات المقبولة والمرفوضة من قائمتك؟';

  @override
  String get doctorNotifiedDecline =>
      'سيتم إخطار الطبيب بأنك رفضت الوقت المقترح.';

  @override
  String get patientReqStatusPending => '⏳  بانتظار المراجعة';

  @override
  String get patientReqStatusAccepted => '✅  مؤكد';

  @override
  String get patientReqStatusRejected => '❌  غير موافق عليه';

  @override
  String get patientReqStatusSuggested => '📅  تم اقتراح وقت جديد';

  @override
  String preferredLabel(String date) {
    return 'المفضّل: $date';
  }

  @override
  String drName(String name) {
    return 'د. $name';
  }

  @override
  String get whatDoYouNeed => 'ما الذي تحتاجه؟';

  @override
  String get whatDoYouNeedHint => 'مثال: فحص روتيني، ألم في الظهر...';

  @override
  String get selectPreferredDate => 'اختر التاريخ المفضّل';

  @override
  String get selectPreferredTime => 'اختر الوقت المفضّل';

  @override
  String get reasonForVisitHint => 'لماذا تحتاج هذا الموعد؟';

  @override
  String get symptomsHint => 'صِف أعراضك...';

  @override
  String get pleaseSelectDate => 'يرجى اختيار تاريخ';

  @override
  String get pleaseSelectTime => 'يرجى اختيار وقت';

  @override
  String get clinicLocation => 'موقع العيادة';

  @override
  String get setClinicLocation => 'تحديد موقع العيادة';

  @override
  String get saveLocation => 'حفظ الموقع';

  @override
  String get locationSaved => 'تم حفظ موقع العيادة';

  @override
  String get locationSaveFailed => 'تعذّر حفظ الموقع. حاول مرة أخرى.';

  @override
  String get tapToSetLocation => 'اضغط على الخريطة لتحديد موقع عيادتك';

  @override
  String get noClinicLocation => 'لم يتم تحديد موقع العيادة بعد';

  @override
  String get viewClinicLocation => 'عرض موقع العيادة';

  @override
  String get clinicLocationRequired => 'موقع العيادة مطلوب';

  @override
  String get setLocationBeforeAccept =>
      'يجب تحديد موقع عيادتك على الخريطة قبل أن تتمكن من قبول طلبات المواعيد.';

  @override
  String get getDirections => 'احصل على الاتجاهات';

  @override
  String get couldNotOpenMaps => 'تعذّر فتح تطبيق الخرائط.';
}
