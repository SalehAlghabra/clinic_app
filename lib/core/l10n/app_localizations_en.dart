// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Clinic Management';

  @override
  String get languageCode => 'en';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get networkError =>
      'No internet connection. Please check your network.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to access your clinic profile';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'e.g. name@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Register';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join us to manage your appointments';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'e.g. John Doe';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHint => 'e.g. 0501234567';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get otpTitle => 'Verify Your Email';

  @override
  String get otpSubtitle => 'We sent a 6-digit code to';

  @override
  String get otpCodeLabel => 'Enter OTP Code';

  @override
  String get verifyButton => 'Verify & Login';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpSentMessage => 'OTP sent to your email successfully.';

  @override
  String get otpResentMessage => 'OTP resent to your email.';

  @override
  String get splashTagline => 'Your health, our priority.';

  @override
  String get patientDashboard => 'Patient Dashboard';

  @override
  String get doctorDashboard => 'Doctor Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get walletTitle => 'My Wallet';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get myAppointments => 'My Appointments';

  @override
  String get medicalRecordsTitle => 'Medical Records';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get doctorsTitle => 'Doctors';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String requiredField(String field) {
    return '$field is required';
  }

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get noDataFound => 'No data found';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_confirmed => 'Confirmed';

  @override
  String get status_rejected => 'Rejected';

  @override
  String get status_cancelled => 'Cancelled';

  @override
  String get status_completed => 'Completed';

  @override
  String get transactionType_deposit => 'Deposit';

  @override
  String get transactionType_booking_deduct => 'Booking Deduction';

  @override
  String get transactionType_refund_full => 'Full Refund';

  @override
  String get transactionType_refund_partial => 'Partial Refund';

  @override
  String get transactionType_penalty => 'Penalty';
}
