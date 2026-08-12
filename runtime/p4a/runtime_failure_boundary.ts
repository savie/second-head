export type RuntimeFailureCode =
  | "INVALID_REQUEST"
  | "UNAUTHENTICATED"
  | "IDENTITY_NOT_RESOLVED"
  | "DEPENDENCY_FAILURE"
  | "INTERNAL_ERROR";

export type RuntimeSuccess<T> = {
  ok: true;
  request_id: string;
  sh_id: string;
  data: T;
};

export type RuntimeFailure = {
  ok: false;
  request_id: string;
  code: RuntimeFailureCode;
  retryable: boolean;
};

export function createRequestId(): string {
  return crypto.randomUUID();
}

export function validateRuntimeRequest(input: unknown):
  | { ok: true; user_message: string }
  | { ok: false; code: "INVALID_REQUEST" } {
  if (!input || typeof input !== "object") return { ok: false, code: "INVALID_REQUEST" };
  const value = input as Record<string, unknown>;
  if (typeof value.user_message !== "string") return { ok: false, code: "INVALID_REQUEST" };
  const user_message = value.user_message.trim();
  if (!user_message || user_message.length > 20000) return { ok: false, code: "INVALID_REQUEST" };
  return { ok: true, user_message };
}

export function failureResponse(
  request_id: string,
  code: RuntimeFailureCode,
): RuntimeFailure {
  return {
    ok: false,
    request_id,
    code,
    retryable: code === "DEPENDENCY_FAILURE" || code === "INTERNAL_ERROR",
  };
}

export function successResponse<T>(
  request_id: string,
  sh_id: string,
  data: T,
): RuntimeSuccess<T> {
  return { ok: true, request_id, sh_id, data };
}
