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

/// Stable application-level classification for backend/runtime failures.
/// The UI may map these categories to presentation without treating local
/// state as authoritative persistence.
sealed class BackendAppError extends AppError {
  const BackendAppError(this.message);

  final String message;
}

final class UnauthenticatedAppError extends BackendAppError {
  const UnauthenticatedAppError(super.message);
}

final class AuthorizationDeniedAppError extends BackendAppError {
  const AuthorizationDeniedAppError(super.message);
}

final class NetworkUnavailableAppError extends BackendAppError {
  const NetworkUnavailableAppError(super.message);
}

final class BackendRuntimeAppError extends BackendAppError {
  const BackendRuntimeAppError(super.message);
}

final class InvalidMessageAppError extends BackendAppError {
  const InvalidMessageAppError(super.message);
}
