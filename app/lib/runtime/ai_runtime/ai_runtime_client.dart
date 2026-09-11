import '../runtime_contract.dart';
import '../../core/result.dart';

/// Initial AI Runtime implementation boundary.
///
/// This implementation intentionally does not depend on:
/// - AI providers
/// - model vendors
/// - Supabase
///
/// Provider execution will be introduced behind a separate adapter boundary.
final class AIRuntimeClient implements RuntimeClient {
  const AIRuntimeClient();

  @override
  Future<AppResult<RuntimeResponse>> send(RuntimeRequest request) async {
    return AppFailure<RuntimeResponse>(
      UnexpectedAppError(
        'AI Runtime execution is not implemented yet',
      ),
    );
  }
}
