# Clinic Management Mobile Application (Flutter Frontend)

This mobile application is a premium, feature-rich clinic management client built with Flutter. It connects to a Laravel backend (powered by Sanctum & email OTP authentication) and implements custom dashboards for both **Patients** and **Doctors**.

---

## Technical Stack & Architecture

* **Framework**: Flutter (Dart) with Material 3 styling.
* **State Management**: BLoC pattern (using `flutter_bloc` package).
* **Router**: GoRouter with redirect guards verifying authentication tokens and role authorization.
* **Network Client**: Dio with interceptors automatically attaching secure authorization and locale `Accept-Language` headers.
* **Local Persistence**: Secure key-value storage with `flutter_secure_storage`.
* **Localization**: Full English (LTR) and Arabic (RTL) localization via standard ARB resource sheets.
* **Animations**: Micro-interactions, staggered fade-ins, and scales utilizing `flutter_animate`.

---

## Features

### 1. Unified Authentication & MFA
* Secure password login accompanied by mandatory email One-Time Password (OTP) verification after every login.
* Register new patient accounts with custom validators.
* Countdowns and automated locks on single-use codes.

### 2. Patient Flow
* **Dashboard**: Greeting name parsed from active credentials and dynamically updating wallet balance cards.
* **Doctor Browsing**: Interactive lists filtered by specialization or name, presenting weekday schedules and consult details.
* **Appointment Booking Wizard**: Calendar picker with dynamic slot availability, preview statements (deposit requirements vs balance offsets), and no-show warning panels.
* **Tabbed Bookings**: Grouped into "Upcoming" and "Past & Cancelled" lists.
* **Cancellation Policies**: Integrated refunds back to the wallet or penalty deductions (if cancelled within 24 hours of the appointment).
* **Wallet Statements**: Visual ledger showing topped balances and transactions history log.
* **Invoices Receipts**: Breakdown consult bills, deposit offsets, and cash remaining due at the desk.
* **Settings & Profile tab**: View account details, toggle dark/light theme, switch English/Arabic, and logout safely.

### 3. Doctor Flow
* **Dashboard**: Statistics indicators for pending queue approvals, today's schedule summaries, and a quick-action "Cancel Day Appointments" module.
* **Queue Management**: Grouped appointments (Pending, Confirmed, History) with actions to confirm, reject, or complete patient visits.
* **Medical Sheets & Prescriptions**: Document patient symptoms, diagnosis, clinical notes, and attach dosage instructions directly.
* **Settings & Profile tab**: Toggle language/theme settings, view doctor specializations, and logout.

---

## Setup & Running Guide

### 1. Prerequisites
Ensure you have the Flutter SDK installed and configured on your development environment:
* Flutter version `^3.11.5`
* Android Studio (with emulator) or a physical Android/iOS test device.

### 2. Base URL Configuration
Update the network configuration in `lib/core/config/app_config.dart`. Replace the network IP with your development machine's local IP address so your physical mobile device can communicate with the backend:
```dart
class AppConfig {
  static const String baseUrl = 'http://<YOUR_MACHINE_IP>:8000';
  // ...
}
```

### 3. Build & Run
1. Fetch packages and run the localization code generator:
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
2. Check for any static analyzer warnings:
   ```bash
   flutter analyze
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## Demo Credentials (Passwords: `password123`)

The database is seeded with mock accounts for testing. All OTP verification codes are logged directly to the bottom of the Laravel log file at `storage/logs/laravel.log`.

| Role | Email Address | Password | Details |
|---|---|---|---|
| **Patient** | `patient1@clinic.com` to `patient15@clinic.com` | `password123` | Equipped with a starting balance of `800.00 SP`. |
| **Doctor** (Smith) | `doctor1@clinic.com` | `password123` | Dr. John Smith (Cardiology) |
| **Doctor** (Clara) | `doctor2@clinic.com` | `password123` | Dr. Clara Oswald (Dermatology) |
| **Doctor** (David) | `doctor3@clinic.com` | `password123` | Dr. David Tennant (Pediatrics) |
| **Receptionist** | `receptionist@clinic.com` | `password123` | Reception staff credentials. |
| **Admin** | `admin@clinic.com` | `password123` | System Administrator credentials. |
