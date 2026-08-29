import { assert } from "https://deno.land/std@0.224.0/assert/assert.ts";
import { assertFalse } from "https://deno.land/std@0.224.0/assert/assert_false.ts";
import { validateCreateEventInput } from "./contract.ts";

Deno.test("R4 accepts a bounded timed event", () => {
  assert(validateCreateEventInput({
    summary: "SH R4 verification",
    start: { dateTime: "2030-01-01T10:00:00Z" },
    end: { dateTime: "2030-01-01T11:00:00Z" },
  }));
});

Deno.test("R4 rejects missing summary", () => {
  assertFalse(validateCreateEventInput({
    summary: "",
    start: { dateTime: "2030-01-01T10:00:00Z" },
    end: { dateTime: "2030-01-01T11:00:00Z" },
  }));
});

Deno.test("R4 rejects an end before start", () => {
  assertFalse(validateCreateEventInput({
    summary: "bad",
    start: { dateTime: "2030-01-01T11:00:00Z" },
    end: { dateTime: "2030-01-01T10:00:00Z" },
  }));
});
