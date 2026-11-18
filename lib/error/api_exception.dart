import 'api_error.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final ApiError apiError;

  ApiException(this.status, this.message)
      : apiError = ApiError(status: status, message: message);

  ApiException.fromError(this.apiError)
      : status = apiError.status,
        message = apiError.message;

  @override
  String toString() => 'ApiException: [$status] $message';
}
