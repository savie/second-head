import {
  failureResponse,
  successResponse,
  validateRuntimeRequest,
} from "./runtime_failure_boundary.ts";

describe("P4A-006 runtime failure boundary", () => {
  it("rejects malformed or empty requests", () => {
    expect(validateRuntimeRequest(null).ok).toBe(false);
    expect(validateRuntimeRequest({ user_message: "   " }).ok).toBe(false);
    expect(validateRuntimeRequest({ user_message: 42 }).ok).toBe(false);
  });

  it("accepts a bounded user message", () => {
    expect(validateRuntimeRequest({ user_message: "hello" })).toEqual({
      ok: true,
      user_message: "hello",
    });
  });

  it("does not expose internal error details", () => {
    expect(failureResponse("req-1", "INTERNAL_ERROR")).toEqual({
      ok: false,
      request_id: "req-1",
      code: "INTERNAL_ERROR",
      retryable: true,
    });
  });

  it("preserves SH identity on successful response", () => {
    expect(successResponse("req-2", "sh-000", { text: "ok" })).toEqual({
      ok: true,
      request_id: "req-2",
      sh_id: "sh-000",
      data: { text: "ok" },
    });
  });
});
