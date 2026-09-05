class AuthBackendError implements Exception {
  const AuthBackendError(this.message);

  final String message;

  @override
  String toString() => message;
}
