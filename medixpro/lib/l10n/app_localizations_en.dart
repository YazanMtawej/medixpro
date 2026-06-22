// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedixPro';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get menu => 'Menu';

  @override
  String get navHome => 'Home';

  @override
  String get navPatients => 'Patients';

  @override
  String get navReports => 'Reports';

  @override
  String get navMeds => 'Meds';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navRequests => 'Requests';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMyAppointments => 'My Appts';

  @override
  String get appointmentsPerformance => 'Appointments Performance';

  @override
  String get pendingVisits => 'Pending visits';

  @override
  String get finishedToday => 'Finished today';

  @override
  String get allAppointments => 'All appointments';

  @override
  String get patientDemographics => 'Patient Demographics';

  @override
  String get populationDistribution => 'Population distribution overview';

  @override
  String get maleRatio => 'Male Ratio';

  @override
  String get femaleRatio => 'Female Ratio';

  @override
  String get liveOverviewToday => 'Live overview for today\'s schedule';

  @override
  String successRate(int rate) {
    return '$rate% Success';
  }

  @override
  String get clinicStrongToday => 'Clinic performance looks strong today.';

  @override
  String get roomToImprove => 'There is room to improve completion rate.';

  @override
  String patientsCount(int count) {
    return '$count Patients';
  }

  @override
  String get femaleLargerSegment =>
      'Female patients represent the larger segment.';

  @override
  String get maleLargerSegment => 'Male patients represent the larger segment.';

  @override
  String get totalPatients => 'Total Patients';

  @override
  String get prescriptions => 'Prescriptions';

  @override
  String get finalReports => 'Final Reports';

  @override
  String get drafts => 'Drafts';

  @override
  String get todaysAppointments => 'Today\'s Appointments';

  @override
  String get todaysSchedule => 'Today\'s Schedule';

  @override
  String get viewAll => 'View all';

  @override
  String get noAppointmentsToday => 'No appointments today';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionGeneral => 'General';

  @override
  String get profile => 'Profile';

  @override
  String get profileSubtitle => 'View and edit your profile';

  @override
  String get patientAccounts => 'Patient Accounts';

  @override
  String get patientAccountsSubtitle => 'Manage and delete patient accounts';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'View all alerts and updates';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get appearanceSubtitle => 'Switch app appearance';

  @override
  String get useArabic => 'العربية';

  @override
  String get languageSubtitle => 'Switch app language';

  @override
  String get logout => 'Logout';

  @override
  String get smartClinicManagement => 'Smart Clinic Management';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToYourAccount => 'Sign in to your account';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get checkingCredentials => 'Checking credentials...';

  @override
  String get allRightsReserved => '© 2026 MedixPro · All rights reserved';

  @override
  String get roleSelection => 'Role Selection';

  @override
  String get whoAreYou => 'Who are you?';

  @override
  String get selectYourRole => 'Select your role to get started';

  @override
  String get patient => 'Patient';

  @override
  String get patientRoleSubtitle => 'Book appointments & view your records';

  @override
  String get doctor => 'Doctor';

  @override
  String get doctorRoleSubtitle => 'Manage patients & clinic operations';

  @override
  String get doctorVerification => 'Doctor Verification';

  @override
  String get doctorVerificationPrompt =>
      'Enter the verification code provided by your clinic administrator.';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterCode => 'Enter code...';

  @override
  String get dontHaveCode => 'Don\'t have a code? Contact your administrator.';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueLabel => 'Continue';

  @override
  String get pleaseEnterCode => 'Please enter the code';

  @override
  String get invalidVerificationCode => 'Invalid verification code';

  @override
  String get patientRegistration => 'Patient Registration';

  @override
  String get doctorRegistration => 'Doctor Registration';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get atLeast3Chars => 'At least 3 characters';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get atLeast8Chars => 'At least 8 characters';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get age => 'Age';

  @override
  String get ageRequired => 'Age is required';

  @override
  String get enterValidAge => 'Enter a valid age (1–150)';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get enterValidPhone => 'Enter a valid phone number';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get createAccount => 'Create Account';

  @override
  String get initializingSystems => 'Initializing systems...';

  @override
  String get versionEdition => 'VERSION 2.4.0 · ENTERPRISE EDITION';

  @override
  String get onboardTitle1 => 'Book Appointments Instantly';

  @override
  String get onboardSubtitle1 =>
      'Find the right doctor and schedule appointments in seconds — no waiting, no calls.';

  @override
  String get onboardTitle2 => 'Smart Medical Records';

  @override
  String get onboardSubtitle2 =>
      'Access your health history, prescriptions, and reports anytime in one secure place.';

  @override
  String get onboardTitle3 => 'Doctor-Patient Communication';

  @override
  String get onboardSubtitle3 =>
      'Stay connected with your doctor, receive updates, and manage your care easily.';

  @override
  String get startYourJourney => 'Start Your Journey';

  @override
  String get continueLabel2 => 'Continue';

  @override
  String get precisionHealthcare => 'PRECISION HEALTHCARE · 2026';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get role => 'Role';

  @override
  String get clinicInformation => 'Clinic Information';

  @override
  String get clinicName => 'Clinic Name';

  @override
  String get address => 'Address';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarningPrefix => 'This will permanently delete ';

  @override
  String get deleteAccountWarningSuffix =>
      '\'s account and ALL associated data:\n\n• Medical records\n• Appointments\n• Reports\n• Prescriptions\n\nThis action cannot be undone.';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String deletedSuccessfully(String name) {
    return '$name deleted successfully';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noPatientAccounts => 'No patient accounts';

  @override
  String get patientsAppearHere => 'Patients who register appear here';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String joinedLabel(String date) {
    return 'Joined: $date';
  }

  @override
  String get searchByNameOrPhone => 'Search by name or phone...';

  @override
  String get total => 'Total';

  @override
  String get noPatientsYet => 'No patients yet';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get addPatient => 'Add Patient';

  @override
  String get editPatient => 'Edit Patient';

  @override
  String get deletePatient => 'Delete Patient';

  @override
  String get deletePatientWarning =>
      'This will permanently delete the patient and all related records.';

  @override
  String get delete => 'Delete';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get medicalInformation => 'Medical Information';

  @override
  String get nationalId => 'National ID';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get allergies => 'Allergies';

  @override
  String get chronicDiseases => 'Chronic Diseases';

  @override
  String get previousSurgeries => 'Previous Surgeries';

  @override
  String get currentMedications => 'Current Medications';

  @override
  String get notes => 'Notes';

  @override
  String get savePatient => 'Save Patient';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get requiredField => 'Required';

  @override
  String get phone => 'Phone';

  @override
  String get name => 'Name';

  @override
  String yrsLabel(int age) {
    return '$age yrs';
  }

  @override
  String ageYearsGender(int age, String gender) {
    return '$age years · $gender';
  }

  @override
  String bloodLabel(String type) {
    return 'Blood: $type';
  }

  @override
  String agePhoneLabel(int age, String phone) {
    return 'Age: $age | $phone';
  }

  @override
  String get medicalReports => 'Medical Reports';

  @override
  String get searchByReportTitle => 'Search by report title or patient...';

  @override
  String get statusAll => 'All';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusFinal => 'Final';

  @override
  String get noReportsFound => 'No reports found';

  @override
  String get deleteReport => 'Delete Report';

  @override
  String get deleteReportWarning =>
      'This medical report will be permanently deleted.';

  @override
  String get newReport => 'New Report';

  @override
  String get untitledReport => 'Untitled Report';

  @override
  String get unknownPatient => 'Unknown Patient';

  @override
  String medicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medications',
      one: '1 medication',
    );
    return '$_temp0';
  }

  @override
  String get patientInformation => 'Patient Information';

  @override
  String ageYears(String age) {
    return '$age years';
  }

  @override
  String get linkedAppointment => 'Linked Appointment';

  @override
  String get titleLabel => 'Title';

  @override
  String get typeLabel => 'Type';

  @override
  String get status => 'Status';

  @override
  String get clinicalInformation => 'Clinical Information';

  @override
  String get chiefComplaint => 'Chief Complaint';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get physicalExamination => 'Physical Examination';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get treatmentPlan => 'Treatment Plan';

  @override
  String get doctorNotes => 'Doctor Notes';

  @override
  String get followUpDate => 'Follow-up Date';

  @override
  String get prescribedMedications => 'Prescribed Medications';

  @override
  String get newMedicalReport => 'New Medical Report';

  @override
  String get selectPatient => 'Select Patient';

  @override
  String get patientLabel => 'Patient';

  @override
  String get pleaseSelectPatient => 'Please select a patient';

  @override
  String get reportTitle => 'Report Title';

  @override
  String get linkedAppointmentOptional => 'Linked Appointment (optional)';

  @override
  String get selectPatientFirst => 'Select patient first';

  @override
  String get noAppointmentsFound => 'No appointments found';

  @override
  String get selectAppointment => 'Select appointment';

  @override
  String get none => 'None';

  @override
  String get noMedicationsForPatient => 'No medications for this patient';

  @override
  String get clinicalDetails => 'Clinical Details';

  @override
  String get saveReport => 'Save Report';

  @override
  String get followUpDateOptional => 'Follow-up Date (optional)';

  @override
  String get notSet => 'Not set';

  @override
  String get editReport => 'Edit Report';

  @override
  String get updateReport => 'Update Report';

  @override
  String get medicationsTitle => 'Medications';

  @override
  String get searchMedicationOrPatient => 'Search medication or patient...';

  @override
  String get newPrescription => 'New Prescription';

  @override
  String get deletePrescription => 'Delete Prescription';

  @override
  String get deletePrescriptionWarning =>
      'This prescription will be permanently removed.';

  @override
  String get noPrescriptionsYet => 'No prescriptions yet';

  @override
  String get tapToAddPrescription => 'Tap + to add a new prescription';

  @override
  String durationDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get commonMedications => 'Common Medications';

  @override
  String get searchCommonMedications => 'Search common medications...';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get dosage => 'Dosage';

  @override
  String get dosageHint => 'Dosage (e.g. 500mg)';

  @override
  String get frequency => 'Frequency';

  @override
  String get routeLabel => 'Route';

  @override
  String get durationDays => 'Duration (days)';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get selectShort => 'Select';

  @override
  String get instructions => 'Instructions';

  @override
  String get instructionsHint => 'Instructions (e.g. Take after meals)';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get savePrescription => 'Save Prescription';

  @override
  String get editPrescription => 'Edit Prescription';

  @override
  String get updatePrescription => 'Update Prescription';

  @override
  String get freqOnceDaily => 'Once Daily';

  @override
  String get freqTwiceDaily => 'Twice Daily';

  @override
  String get freqThreeTimesDaily => 'Three Times Daily';

  @override
  String get freqFourTimesDaily => 'Four Times Daily';

  @override
  String get freqEvery8Hours => 'Every 8 Hours';

  @override
  String get freqEvery12Hours => 'Every 12 Hours';

  @override
  String get freqAsNeeded => 'As Needed';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get routeOral => 'Oral';

  @override
  String get routeInjection => 'Injection';

  @override
  String get routeTopical => 'Topical';

  @override
  String get routeInhalation => 'Inhalation';

  @override
  String get routeSublingual => 'Sublingual';

  @override
  String get routeIv => 'Intravenous (IV)';

  @override
  String get routeEyeDrops => 'Eye Drops';

  @override
  String get routeEarDrops => 'Ear Drops';

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get newAppointment => 'New Appointment';

  @override
  String get appointmentTitle => 'Appointment Title';

  @override
  String get durationMinutesLabel => 'Duration (minutes)';

  @override
  String get editAppointment => 'Edit Appointment';

  @override
  String get saveAppointment => 'Save Appointment';

  @override
  String get updateAppointment => 'Update Appointment';

  @override
  String get appointmentDetails => 'Appointment Details';

  @override
  String get searchAppointmentOrPatient => 'Search appointment or patient...';

  @override
  String get pleaseSelectDateAndTime => 'Please select date and time';

  @override
  String get pleaseSelectBothDateTime => 'Please select both date and time';

  @override
  String get appointmentDeleteWarning =>
      'This appointment will be permanently deleted.';

  @override
  String get deleteAppointment => 'Delete Appointment';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get reason => 'Reason';

  @override
  String get reasonForVisit => 'Reason for Visit';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get followUp => 'Follow-up';

  @override
  String get duration => 'Duration';

  @override
  String minutesValue(int count) {
    return '$count minutes';
  }

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get noAppointmentsYet => 'No appointments yet';

  @override
  String get startByBooking => 'Start by booking your first appointment';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String get welcomeBackEmoji => 'Welcome back 👋';

  @override
  String get yourHealthSimplified => 'Your health, simplified';

  @override
  String get typeFollowUp => 'Follow Up';

  @override
  String get typeConsultation => 'Consultation';

  @override
  String get typeEmergency => 'Emergency';

  @override
  String get typeGeneral => 'General';

  @override
  String get typeLabResults => 'Lab Results';

  @override
  String get typeProcedure => 'Procedure';

  @override
  String get typeVaccination => 'Vaccination';

  @override
  String get today => 'Today';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusNoShow => 'No Show';

  @override
  String get statusRescheduled => 'Rescheduled';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusSuggested => 'Suggested';

  @override
  String get tabSuggested => 'Suggested';

  @override
  String get tabDone => 'Done';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get selectTime => 'Select time';

  @override
  String suggestedDateLabel(String date) {
    return 'Suggested: $date';
  }

  @override
  String get patientWillBeNotifiedSuggest =>
      'The patient will be notified and can confirm or decline.';

  @override
  String get appointmentRequests => 'Appointment Requests';

  @override
  String get reviewRespondRequests => 'Review and respond to patient requests';

  @override
  String get requested => 'Requested';

  @override
  String get accept => 'Accept';

  @override
  String get suggest => 'Suggest';

  @override
  String get reject => 'Reject';

  @override
  String get acceptRequest => 'Accept Request';

  @override
  String get appointmentCreatedAtRequestedTime =>
      'Appointment will be created at the patient\'s requested time.';

  @override
  String get optionalNoteForPatient => 'Optional note for the patient';

  @override
  String get confirm => 'Confirm';

  @override
  String get suggestAlternativeTime => 'Suggest Alternative Time';

  @override
  String get noteForPatientOptional => 'Note for patient (optional)';

  @override
  String get sendSuggestion => 'Send Suggestion';

  @override
  String get rejectRequest => 'Reject Request';

  @override
  String get patientNotifiedRejection =>
      'The patient will be notified of the rejection.';

  @override
  String get reasonForRejectionOptional => 'Reason for rejection (optional)';

  @override
  String get clearCompleted => 'Clear Completed';

  @override
  String get clear => 'Clear';

  @override
  String get declineSuggestion => 'Decline Suggestion';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get decline => 'Decline';

  @override
  String get doctorProposedNewTime => 'Doctor proposed a new time';

  @override
  String noteWithText(String note) {
    return 'Note: $note';
  }

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get tapNewRequestToBook =>
      'Tap \"New Request\" to book your first appointment';

  @override
  String sentAgo(String time) {
    return 'Sent $time';
  }

  @override
  String get requestDetails => 'Request Details';

  @override
  String get preferredDateTime => 'Preferred Date & Time';

  @override
  String get additionalInfoOptional => 'Additional Info (optional)';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get newRequest => 'New Request';

  @override
  String get myRequests => 'My Requests';

  @override
  String get clearCompletedConfirm =>
      'Remove all accepted and rejected requests from your list?';

  @override
  String get doctorNotifiedDecline =>
      'The doctor will be notified that you declined the suggested time.';

  @override
  String get patientReqStatusPending => '⏳  Awaiting review';

  @override
  String get patientReqStatusAccepted => '✅  Confirmed';

  @override
  String get patientReqStatusRejected => '❌  Not approved';

  @override
  String get patientReqStatusSuggested => '📅  New time proposed';

  @override
  String preferredLabel(String date) {
    return 'Preferred: $date';
  }

  @override
  String drName(String name) {
    return 'Dr. $name';
  }

  @override
  String get whatDoYouNeed => 'What do you need?';

  @override
  String get whatDoYouNeedHint => 'e.g. Routine checkup, back pain...';

  @override
  String get selectPreferredDate => 'Select preferred date';

  @override
  String get selectPreferredTime => 'Select preferred time';

  @override
  String get reasonForVisitHint => 'Why do you need this appointment?';

  @override
  String get symptomsHint => 'Describe your symptoms...';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get pleaseSelectTime => 'Please select a time';

  @override
  String get clinicLocation => 'Clinic Location';

  @override
  String get setClinicLocation => 'Set Clinic Location';

  @override
  String get saveLocation => 'Save Location';

  @override
  String get locationSaved => 'Clinic location saved';

  @override
  String get locationSaveFailed => 'Could not save location. Please try again.';

  @override
  String get tapToSetLocation => 'Tap on the map to set your clinic location';

  @override
  String get noClinicLocation => 'No clinic location set yet';

  @override
  String get viewClinicLocation => 'View clinic location';
}
