enum ToolRisk { readOnly, low, medium, high }

enum ToolActionStatus { proposed, awaitingConfirmation, executing, succeeded, failed, rejected }

final class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.version,
    required this.description,
    required this.risk,
    required this.requiresConfirmation,
  });

  final String id;
  final String version;
  final String description;
  final ToolRisk risk;
  final bool requiresConfirmation;
}

final class ToolActionRequest {
  const ToolActionRequest({
    required this.toolId,
    required this.arguments,
    this.confirmed = false,
    this.idempotencyKey,
  });

  final String toolId;
  final Map<String, Object?> arguments;
  final bool confirmed;
  final String? idempotencyKey;
}

final class ToolActionResult {
  const ToolActionResult({
    required this.toolId,
    required this.status,
    this.actionId,
    this.output,
    this.errorCode,
    this.errorMessage,
    this.auditRecorded = false,
  });

  final String toolId;
  final ToolActionStatus status;
  final String? actionId;
  final Map<String, Object?>? output;
  final String? errorCode;
  final String? errorMessage;
  final bool auditRecorded;
}

abstract interface class ToolActionExecutor {
  Future<ToolActionResult> execute(ToolActionRequest request);
}
