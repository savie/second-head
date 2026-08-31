import '../core/result.dart';

abstract interface class RuntimeClient {
  Future<AppResult<RuntimeResponse>> send(RuntimeRequest request);
}

final class RuntimeRequest {
  const RuntimeRequest({
    required this.input,
  });

  final String input;
}

final class RuntimeResponse {
  const RuntimeResponse({
    required this.output,
  });

  final String output;
}
