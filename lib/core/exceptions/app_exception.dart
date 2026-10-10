/// Internal exception type mapped to [Failure] at repository boundaries.
class AppException implements Exception {
  AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException($code): $message';
}
