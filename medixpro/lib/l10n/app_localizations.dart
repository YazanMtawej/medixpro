import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MedixPro'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMeds.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get navMeds;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMyAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appts'**
  String get navMyAppointments;

  /// No description provided for @appointmentsPerformance.
  ///
  /// In en, this message translates to:
  /// **'Appointments Performance'**
  String get appointmentsPerformance;

  /// No description provided for @pendingVisits.
  ///
  /// In en, this message translates to:
  /// **'Pending visits'**
  String get pendingVisits;

  /// No description provided for @finishedToday.
  ///
  /// In en, this message translates to:
  /// **'Finished today'**
  String get finishedToday;

  /// No description provided for @allAppointments.
  ///
  /// In en, this message translates to:
  /// **'All appointments'**
  String get allAppointments;

  /// No description provided for @patientDemographics.
  ///
  /// In en, this message translates to:
  /// **'Patient Demographics'**
  String get patientDemographics;

  /// No description provided for @populationDistribution.
  ///
  /// In en, this message translates to:
  /// **'Population distribution overview'**
  String get populationDistribution;

  /// No description provided for @maleRatio.
  ///
  /// In en, this message translates to:
  /// **'Male Ratio'**
  String get maleRatio;

  /// No description provided for @femaleRatio.
  ///
  /// In en, this message translates to:
  /// **'Female Ratio'**
  String get femaleRatio;

  /// No description provided for @liveOverviewToday.
  ///
  /// In en, this message translates to:
  /// **'Live overview for today\'s schedule'**
  String get liveOverviewToday;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'{rate}% Success'**
  String successRate(int rate);

  /// No description provided for @clinicStrongToday.
  ///
  /// In en, this message translates to:
  /// **'Clinic performance looks strong today.'**
  String get clinicStrongToday;

  /// No description provided for @roomToImprove.
  ///
  /// In en, this message translates to:
  /// **'There is room to improve completion rate.'**
  String get roomToImprove;

  /// No description provided for @patientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Patients'**
  String patientsCount(int count);

  /// No description provided for @femaleLargerSegment.
  ///
  /// In en, this message translates to:
  /// **'Female patients represent the larger segment.'**
  String get femaleLargerSegment;

  /// No description provided for @maleLargerSegment.
  ///
  /// In en, this message translates to:
  /// **'Male patients represent the larger segment.'**
  String get maleLargerSegment;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get totalPatients;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @finalReports.
  ///
  /// In en, this message translates to:
  /// **'Final Reports'**
  String get finalReports;

  /// No description provided for @drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// No description provided for @todaysAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get todaysAppointments;

  /// No description provided for @todaysSchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaysSchedule;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get noAppointmentsToday;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and edit your profile'**
  String get profileSubtitle;

  /// No description provided for @patientAccounts.
  ///
  /// In en, this message translates to:
  /// **'Patient Accounts'**
  String get patientAccounts;

  /// No description provided for @patientAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage and delete patient accounts'**
  String get patientAccountsSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all alerts and updates'**
  String get notificationsSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch app appearance'**
  String get appearanceSubtitle;

  /// No description provided for @useArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get useArabic;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch app language'**
  String get languageSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @smartClinicManagement.
  ///
  /// In en, this message translates to:
  /// **'Smart Clinic Management'**
  String get smartClinicManagement;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToYourAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @checkingCredentials.
  ///
  /// In en, this message translates to:
  /// **'Checking credentials...'**
  String get checkingCredentials;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MedixPro · All rights reserved'**
  String get allRightsReserved;

  /// No description provided for @roleSelection.
  ///
  /// In en, this message translates to:
  /// **'Role Selection'**
  String get roleSelection;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get whoAreYou;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role to get started'**
  String get selectYourRole;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @patientRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book appointments & view your records'**
  String get patientRoleSubtitle;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @doctorRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage patients & clinic operations'**
  String get doctorRoleSubtitle;

  /// No description provided for @doctorVerification.
  ///
  /// In en, this message translates to:
  /// **'Doctor Verification'**
  String get doctorVerification;

  /// No description provided for @doctorVerificationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code provided by your clinic administrator.'**
  String get doctorVerificationPrompt;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code...'**
  String get enterCode;

  /// No description provided for @dontHaveCode.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a code? Contact your administrator.'**
  String get dontHaveCode;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get pleaseEnterCode;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// No description provided for @patientRegistration.
  ///
  /// In en, this message translates to:
  /// **'Patient Registration'**
  String get patientRegistration;

  /// No description provided for @doctorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Doctor Registration'**
  String get doctorRegistration;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @atLeast3Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get atLeast3Chars;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @atLeast8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Chars;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageRequired;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age (1–150)'**
  String get enterValidAge;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @initializingSystems.
  ///
  /// In en, this message translates to:
  /// **'Initializing systems...'**
  String get initializingSystems;

  /// No description provided for @versionEdition.
  ///
  /// In en, this message translates to:
  /// **'VERSION 2.4.0 · ENTERPRISE EDITION'**
  String get versionEdition;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Book Appointments Instantly'**
  String get onboardTitle1;

  /// No description provided for @onboardSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Find the right doctor and schedule appointments in seconds — no waiting, no calls.'**
  String get onboardSubtitle1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Smart Medical Records'**
  String get onboardTitle2;

  /// No description provided for @onboardSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Access your health history, prescriptions, and reports anytime in one secure place.'**
  String get onboardSubtitle2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Doctor-Patient Communication'**
  String get onboardTitle3;

  /// No description provided for @onboardSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with your doctor, receive updates, and manage your care easily.'**
  String get onboardSubtitle3;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get startYourJourney;

  /// No description provided for @continueLabel2.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel2;

  /// No description provided for @precisionHealthcare.
  ///
  /// In en, this message translates to:
  /// **'PRECISION HEALTHCARE · 2026'**
  String get precisionHealthcare;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @clinicInformation.
  ///
  /// In en, this message translates to:
  /// **'Clinic Information'**
  String get clinicInformation;

  /// No description provided for @clinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic Name'**
  String get clinicName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarningPrefix.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete '**
  String get deleteAccountWarningPrefix;

  /// No description provided for @deleteAccountWarningSuffix.
  ///
  /// In en, this message translates to:
  /// **'\'s account and ALL associated data:\n\n• Medical records\n• Appointments\n• Reports\n• Prescriptions\n\nThis action cannot be undone.'**
  String get deleteAccountWarningSuffix;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted successfully'**
  String deletedSuccessfully(String name);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPatientAccounts.
  ///
  /// In en, this message translates to:
  /// **'No patient accounts'**
  String get noPatientAccounts;

  /// No description provided for @patientsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Patients who register appear here'**
  String get patientsAppearHere;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @joinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined: {date}'**
  String joinedLabel(String date);

  /// No description provided for @searchByNameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone...'**
  String get searchByNameOrPhone;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @noPatientsYet.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get noPatientsYet;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @editPatient.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatient;

  /// No description provided for @deletePatient.
  ///
  /// In en, this message translates to:
  /// **'Delete Patient'**
  String get deletePatient;

  /// No description provided for @deletePatientWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the patient and all related records.'**
  String get deletePatientWarning;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @chronicDiseases.
  ///
  /// In en, this message translates to:
  /// **'Chronic Diseases'**
  String get chronicDiseases;

  /// No description provided for @previousSurgeries.
  ///
  /// In en, this message translates to:
  /// **'Previous Surgeries'**
  String get previousSurgeries;

  /// No description provided for @currentMedications.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get currentMedications;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @savePatient.
  ///
  /// In en, this message translates to:
  /// **'Save Patient'**
  String get savePatient;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @yrsLabel.
  ///
  /// In en, this message translates to:
  /// **'{age} yrs'**
  String yrsLabel(int age);

  /// No description provided for @ageYearsGender.
  ///
  /// In en, this message translates to:
  /// **'{age} years · {gender}'**
  String ageYearsGender(int age, String gender);

  /// No description provided for @bloodLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood: {type}'**
  String bloodLabel(String type);

  /// No description provided for @agePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} | {phone}'**
  String agePhoneLabel(int age, String phone);

  /// No description provided for @medicalReports.
  ///
  /// In en, this message translates to:
  /// **'Medical Reports'**
  String get medicalReports;

  /// No description provided for @searchByReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by report title or patient...'**
  String get searchByReportTitle;

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusFinal.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get statusFinal;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @deleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReport;

  /// No description provided for @deleteReportWarning.
  ///
  /// In en, this message translates to:
  /// **'This medical report will be permanently deleted.'**
  String get deleteReportWarning;

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get newReport;

  /// No description provided for @untitledReport.
  ///
  /// In en, this message translates to:
  /// **'Untitled Report'**
  String get untitledReport;

  /// No description provided for @unknownPatient.
  ///
  /// In en, this message translates to:
  /// **'Unknown Patient'**
  String get unknownPatient;

  /// No description provided for @medicationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medication} other{{count} medications}}'**
  String medicationsCount(int count);

  /// No description provided for @patientInformation.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInformation;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String ageYears(String age);

  /// No description provided for @linkedAppointment.
  ///
  /// In en, this message translates to:
  /// **'Linked Appointment'**
  String get linkedAppointment;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @clinicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Clinical Information'**
  String get clinicalInformation;

  /// No description provided for @chiefComplaint.
  ///
  /// In en, this message translates to:
  /// **'Chief Complaint'**
  String get chiefComplaint;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @physicalExamination.
  ///
  /// In en, this message translates to:
  /// **'Physical Examination'**
  String get physicalExamination;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @treatmentPlan.
  ///
  /// In en, this message translates to:
  /// **'Treatment Plan'**
  String get treatmentPlan;

  /// No description provided for @doctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Doctor Notes'**
  String get doctorNotes;

  /// No description provided for @followUpDate.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Date'**
  String get followUpDate;

  /// No description provided for @prescribedMedications.
  ///
  /// In en, this message translates to:
  /// **'Prescribed Medications'**
  String get prescribedMedications;

  /// No description provided for @newMedicalReport.
  ///
  /// In en, this message translates to:
  /// **'New Medical Report'**
  String get newMedicalReport;

  /// No description provided for @selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select Patient'**
  String get selectPatient;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @pleaseSelectPatient.
  ///
  /// In en, this message translates to:
  /// **'Please select a patient'**
  String get pleaseSelectPatient;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Title'**
  String get reportTitle;

  /// No description provided for @linkedAppointmentOptional.
  ///
  /// In en, this message translates to:
  /// **'Linked Appointment (optional)'**
  String get linkedAppointmentOptional;

  /// No description provided for @selectPatientFirst.
  ///
  /// In en, this message translates to:
  /// **'Select patient first'**
  String get selectPatientFirst;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No description provided for @selectAppointment.
  ///
  /// In en, this message translates to:
  /// **'Select appointment'**
  String get selectAppointment;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @noMedicationsForPatient.
  ///
  /// In en, this message translates to:
  /// **'No medications for this patient'**
  String get noMedicationsForPatient;

  /// No description provided for @clinicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Clinical Details'**
  String get clinicalDetails;

  /// No description provided for @saveReport.
  ///
  /// In en, this message translates to:
  /// **'Save Report'**
  String get saveReport;

  /// No description provided for @followUpDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Date (optional)'**
  String get followUpDateOptional;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @editReport.
  ///
  /// In en, this message translates to:
  /// **'Edit Report'**
  String get editReport;

  /// No description provided for @updateReport.
  ///
  /// In en, this message translates to:
  /// **'Update Report'**
  String get updateReport;

  /// No description provided for @medicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medicationsTitle;

  /// No description provided for @searchMedicationOrPatient.
  ///
  /// In en, this message translates to:
  /// **'Search medication or patient...'**
  String get searchMedicationOrPatient;

  /// No description provided for @newPrescription.
  ///
  /// In en, this message translates to:
  /// **'New Prescription'**
  String get newPrescription;

  /// No description provided for @deletePrescription.
  ///
  /// In en, this message translates to:
  /// **'Delete Prescription'**
  String get deletePrescription;

  /// No description provided for @deletePrescriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'This prescription will be permanently removed.'**
  String get deletePrescriptionWarning;

  /// No description provided for @noPrescriptionsYet.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions yet'**
  String get noPrescriptionsYet;

  /// No description provided for @tapToAddPrescription.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new prescription'**
  String get tapToAddPrescription;

  /// No description provided for @durationDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String durationDaysShort(int days);

  /// No description provided for @commonMedications.
  ///
  /// In en, this message translates to:
  /// **'Common Medications'**
  String get commonMedications;

  /// No description provided for @searchCommonMedications.
  ///
  /// In en, this message translates to:
  /// **'Search common medications...'**
  String get searchCommonMedications;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'Dosage (e.g. 500mg)'**
  String get dosageHint;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'Duration (days)'**
  String get durationDays;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectShort.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectShort;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @instructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Instructions (e.g. Take after meals)'**
  String get instructionsHint;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @savePrescription.
  ///
  /// In en, this message translates to:
  /// **'Save Prescription'**
  String get savePrescription;

  /// No description provided for @editPrescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Prescription'**
  String get editPrescription;

  /// No description provided for @updatePrescription.
  ///
  /// In en, this message translates to:
  /// **'Update Prescription'**
  String get updatePrescription;

  /// No description provided for @freqOnceDaily.
  ///
  /// In en, this message translates to:
  /// **'Once Daily'**
  String get freqOnceDaily;

  /// No description provided for @freqTwiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice Daily'**
  String get freqTwiceDaily;

  /// No description provided for @freqThreeTimesDaily.
  ///
  /// In en, this message translates to:
  /// **'Three Times Daily'**
  String get freqThreeTimesDaily;

  /// No description provided for @freqFourTimesDaily.
  ///
  /// In en, this message translates to:
  /// **'Four Times Daily'**
  String get freqFourTimesDaily;

  /// No description provided for @freqEvery8Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 8 Hours'**
  String get freqEvery8Hours;

  /// No description provided for @freqEvery12Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 12 Hours'**
  String get freqEvery12Hours;

  /// No description provided for @freqAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get freqAsNeeded;

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// No description provided for @routeOral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get routeOral;

  /// No description provided for @routeInjection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get routeInjection;

  /// No description provided for @routeTopical.
  ///
  /// In en, this message translates to:
  /// **'Topical'**
  String get routeTopical;

  /// No description provided for @routeInhalation.
  ///
  /// In en, this message translates to:
  /// **'Inhalation'**
  String get routeInhalation;

  /// No description provided for @routeSublingual.
  ///
  /// In en, this message translates to:
  /// **'Sublingual'**
  String get routeSublingual;

  /// No description provided for @routeIv.
  ///
  /// In en, this message translates to:
  /// **'Intravenous (IV)'**
  String get routeIv;

  /// No description provided for @routeEyeDrops.
  ///
  /// In en, this message translates to:
  /// **'Eye Drops'**
  String get routeEyeDrops;

  /// No description provided for @routeEarDrops.
  ///
  /// In en, this message translates to:
  /// **'Ear Drops'**
  String get routeEarDrops;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointmentsTitle;

  /// No description provided for @newAppointment.
  ///
  /// In en, this message translates to:
  /// **'New Appointment'**
  String get newAppointment;

  /// No description provided for @appointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment Title'**
  String get appointmentTitle;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutesLabel;

  /// No description provided for @editAppointment.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get editAppointment;

  /// No description provided for @saveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Save Appointment'**
  String get saveAppointment;

  /// No description provided for @updateAppointment.
  ///
  /// In en, this message translates to:
  /// **'Update Appointment'**
  String get updateAppointment;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetails;

  /// No description provided for @searchAppointmentOrPatient.
  ///
  /// In en, this message translates to:
  /// **'Search appointment or patient...'**
  String get searchAppointmentOrPatient;

  /// No description provided for @pleaseSelectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get pleaseSelectDateAndTime;

  /// No description provided for @pleaseSelectBothDateTime.
  ///
  /// In en, this message translates to:
  /// **'Please select both date and time'**
  String get pleaseSelectBothDateTime;

  /// No description provided for @appointmentDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This appointment will be permanently deleted.'**
  String get appointmentDeleteWarning;

  /// No description provided for @deleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get deleteAppointment;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonForVisit.
  ///
  /// In en, this message translates to:
  /// **'Reason for Visit'**
  String get reasonForVisit;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesValue(int count);

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointmentsYet;

  /// No description provided for @startByBooking.
  ///
  /// In en, this message translates to:
  /// **'Start by booking your first appointment'**
  String get startByBooking;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @welcomeBackEmoji.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcomeBackEmoji;

  /// No description provided for @yourHealthSimplified.
  ///
  /// In en, this message translates to:
  /// **'Your health, simplified'**
  String get yourHealthSimplified;

  /// No description provided for @typeFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow Up'**
  String get typeFollowUp;

  /// No description provided for @typeConsultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get typeConsultation;

  /// No description provided for @typeEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get typeEmergency;

  /// No description provided for @typeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get typeGeneral;

  /// No description provided for @typeLabResults.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get typeLabResults;

  /// No description provided for @typeProcedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get typeProcedure;

  /// No description provided for @typeVaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get typeVaccination;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get statusNoShow;

  /// No description provided for @statusRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get statusRescheduled;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get statusSuggested;

  /// No description provided for @tabSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get tabSuggested;

  /// No description provided for @tabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tabDone;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @suggestedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {date}'**
  String suggestedDateLabel(String date);

  /// No description provided for @patientWillBeNotifiedSuggest.
  ///
  /// In en, this message translates to:
  /// **'The patient will be notified and can confirm or decline.'**
  String get patientWillBeNotifiedSuggest;

  /// No description provided for @appointmentRequests.
  ///
  /// In en, this message translates to:
  /// **'Appointment Requests'**
  String get appointmentRequests;

  /// No description provided for @reviewRespondRequests.
  ///
  /// In en, this message translates to:
  /// **'Review and respond to patient requests'**
  String get reviewRespondRequests;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @suggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get suggest;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest;

  /// No description provided for @appointmentCreatedAtRequestedTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment will be created at the patient\'s requested time.'**
  String get appointmentCreatedAtRequestedTime;

  /// No description provided for @optionalNoteForPatient.
  ///
  /// In en, this message translates to:
  /// **'Optional note for the patient'**
  String get optionalNoteForPatient;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @suggestAlternativeTime.
  ///
  /// In en, this message translates to:
  /// **'Suggest Alternative Time'**
  String get suggestAlternativeTime;

  /// No description provided for @noteForPatientOptional.
  ///
  /// In en, this message translates to:
  /// **'Note for patient (optional)'**
  String get noteForPatientOptional;

  /// No description provided for @sendSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Send Suggestion'**
  String get sendSuggestion;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get rejectRequest;

  /// No description provided for @patientNotifiedRejection.
  ///
  /// In en, this message translates to:
  /// **'The patient will be notified of the rejection.'**
  String get patientNotifiedRejection;

  /// No description provided for @reasonForRejectionOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection (optional)'**
  String get reasonForRejectionOptional;

  /// No description provided for @clearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear Completed'**
  String get clearCompleted;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @declineSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Decline Suggestion'**
  String get declineSuggestion;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @doctorProposedNewTime.
  ///
  /// In en, this message translates to:
  /// **'Doctor proposed a new time'**
  String get doctorProposedNewTime;

  /// No description provided for @noteWithText.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String noteWithText(String note);

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @tapNewRequestToBook.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New Request\" to book your first appointment'**
  String get tapNewRequestToBook;

  /// No description provided for @sentAgo.
  ///
  /// In en, this message translates to:
  /// **'Sent {time}'**
  String sentAgo(String time);

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @preferredDateTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Date & Time'**
  String get preferredDateTime;

  /// No description provided for @additionalInfoOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Info (optional)'**
  String get additionalInfoOptional;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @clearCompletedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all accepted and rejected requests from your list?'**
  String get clearCompletedConfirm;

  /// No description provided for @doctorNotifiedDecline.
  ///
  /// In en, this message translates to:
  /// **'The doctor will be notified that you declined the suggested time.'**
  String get doctorNotifiedDecline;

  /// No description provided for @patientReqStatusPending.
  ///
  /// In en, this message translates to:
  /// **'⏳  Awaiting review'**
  String get patientReqStatusPending;

  /// No description provided for @patientReqStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'✅  Confirmed'**
  String get patientReqStatusAccepted;

  /// No description provided for @patientReqStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'❌  Not approved'**
  String get patientReqStatusRejected;

  /// No description provided for @patientReqStatusSuggested.
  ///
  /// In en, this message translates to:
  /// **'📅  New time proposed'**
  String get patientReqStatusSuggested;

  /// No description provided for @preferredLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred: {date}'**
  String preferredLabel(String date);

  /// No description provided for @drName.
  ///
  /// In en, this message translates to:
  /// **'Dr. {name}'**
  String drName(String name);

  /// No description provided for @whatDoYouNeed.
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get whatDoYouNeed;

  /// No description provided for @whatDoYouNeedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Routine checkup, back pain...'**
  String get whatDoYouNeedHint;

  /// No description provided for @selectPreferredDate.
  ///
  /// In en, this message translates to:
  /// **'Select preferred date'**
  String get selectPreferredDate;

  /// No description provided for @selectPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Select preferred time'**
  String get selectPreferredTime;

  /// No description provided for @reasonForVisitHint.
  ///
  /// In en, this message translates to:
  /// **'Why do you need this appointment?'**
  String get reasonForVisitHint;

  /// No description provided for @symptomsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptoms...'**
  String get symptomsHint;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @pleaseSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a time'**
  String get pleaseSelectTime;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
