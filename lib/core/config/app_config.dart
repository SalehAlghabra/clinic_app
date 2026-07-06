class AppConfig {
  // ─── Base URL Configuration ────────────────────────────────────────────────
  //
  // Switch the comment below depending on your dev environment:
  //
  //   Physical device (USB debugging) — use your machine's local network IP:
  //     static const String baseUrl = 'http://192.168.x.x:8000';
  //
  //   Android Emulator — use the special loopback alias:
  //     static const String baseUrl = 'http://10.0.2.2:8000';
  //
  //   iOS Simulator — use localhost directly:
  //     static const String baseUrl = 'http://127.0.0.1:8000';
  //
  //   Production server — replace with your deployed URL:
  //     static const String baseUrl = 'https://your-clinic-api.com';
  //
  // IMPORTANT: Never hardcode this URL anywhere else in the project.
  //            All HTTP calls go through ApiClient which reads this value.
  // ──────────────────────────────────────────────────────────────────────────

  static const String baseUrl = 'http://192.168.1.x:8000'; // ← change x to your machine's IP

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
