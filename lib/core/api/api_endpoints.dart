class ApiEndpoints {
  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyResetOtp = '/api/auth/verify-reset-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String updateProfile = '/api/auth/profile';
  static const String fcmToken = '/api/auth/fcm-token';

  // Doctors & Schedules
  static const String doctors = '/api/doctors';
  static String doctorDetail(int id) => '/api/doctors/$id';
  static String doctorSchedules(int doctorId) => '/api/doctors/$doctorId/schedules';
  static String availableSlots(int doctorId) => '/api/doctors/$doctorId/available-slots';

  // Settings
  static const String settings = '/api/settings';

  // Appointments (Patient)
  static const String appointmentPreview = '/api/appointments/preview';
  static const String bookAppointment = '/api/appointments';
  static const String patientAppointments = '/api/appointments/my';
  static String cancelAppointment(int id) => '/api/appointments/$id/cancel';

  // Appointments (Doctor)
  static const String doctorAppointments = '/api/appointments/doctor';
  static String updateAppointmentStatus(int id) => '/api/appointments/$id/status';
  static const String cancelDayAppointments = '/api/appointments/cancel-day';

  // Medical Records
  static const String medicalRecords = '/api/medical-records';
  static const String patientMedicalRecords = '/api/medical-records/my';
  static String addPrescription(int recordId) => '/api/medical-records/$recordId/prescriptions';
  static String medicalRecordDetail(int recordId) => '/api/medical-records/$recordId';

  // Invoices
  static const String patientInvoices = '/api/invoices/my';
  static String invoiceDetail(int appointmentId) => '/api/invoices/$appointmentId';

  // Wallet
  static const String walletBalance = '/api/wallet/balance';
  static const String walletTransactions = '/api/wallet/transactions';
}
