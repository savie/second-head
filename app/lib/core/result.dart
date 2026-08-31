sealed class AppResult<T> {
  const AppResult();
}

final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.value);

  final T value;
}

final class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.error);

  final AppError error;
}

sealed class AppError {
  const AppError();
}

final class UnexpectedAppError extends AppError {
  const UnexpectedAppError(this.message);

  final String message;
}
