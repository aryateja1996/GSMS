import 'package:gsma/core/errors/failures.dart';

/// Lightweight Result type for use cases and repositories.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class ErrorResult<T> extends Result<T> {
  const ErrorResult(this.failure);
  final Failure failure;
}
