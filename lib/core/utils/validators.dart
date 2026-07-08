class Validators {
  static String? required(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? email(String? value, String emptyError, String invalidError) {
    if (value == null || value.trim().isEmpty) {
      return emptyError;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return invalidError;
    }
    return null;
  }

  static String? password(String? value, String emptyError, String lengthError) {
    if (value == null || value.trim().isEmpty) {
      return emptyError;
    }
    if (value.length < 6) {
      return lengthError;
    }
    return null;
  }

  static String? phone(String? value, String invalidError) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.length < 9) {
      return invalidError;
    }
    return null;
  }

  static String? otp(String? value, String emptyError, String lengthError) {
    if (value == null || value.trim().isEmpty) {
      return emptyError;
    }
    if (value.length != 6) {
      return lengthError;
    }
    return null;
  }
}
