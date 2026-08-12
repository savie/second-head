import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { MAX_MESSAGE_LENGTH, validateRuntimeRequest } from "./runtime_request_contract.ts";

Deno.test("accepts a bounded authenticated runtime request", () => {
  assertEquals(validateRuntimeRequest({
    request_id: "req-001",
    auth_uid: "user-001",
    user_message: "hello",
  }), {
    accepted: true,
    request_id: "req-001",
    auth_uid: "user-001",
    user_message: "hello",
  });
});

Deno.test("fails closed when auth uid is absent", () => {
  assertEquals(validateRuntimeRequest({
    request_id: "req-002",
    user_message: "hello",
  }), { accepted: false, code: "UNAUTHENTICATED" });
});

Deno.test("rejects oversized messages", () => {
  assertEquals(validateRuntimeRequest({
    request_id: "req-003",
    auth_uid: "user-001",
    user_message: "x".repeat(MAX_MESSAGE_LENGTH + 1),
  }), { accepted: false, code: "MESSAGE_TOO_LARGE" });
});

Deno.test("rejects malformed input", () => {
  assertEquals(validateRuntimeRequest(null), { accepted: false, code: "INVALID_REQUEST" });
  assertEquals(validateRuntimeRequest({ request_id: "req-004", auth_uid: "user-001", user_message: "" }), {
    accepted: false,
    code: "INVALID_REQUEST",
  });
});
