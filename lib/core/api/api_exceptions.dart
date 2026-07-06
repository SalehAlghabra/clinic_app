class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  ValidationException({
    required String message,
    required this.errors,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode, data: errors);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

class NetworkException extends ApiException {
  NetworkException({required String message}) : super(message: message);
}
