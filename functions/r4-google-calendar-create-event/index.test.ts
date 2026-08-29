import { describe, expect, it } from "https://deno.land/std@0.224.0/testing/bdd.ts";
import { validateCreateEventInput } from "./contract.ts";

describe("R4 Google Calendar CREATE EVENT input boundary", () => {
  it("accepts a bounded timed event", () => {
    expect(validateCreateEventInput({
      summary: "SH R4 verification",
      start: { dateTime: "2030-01-01T10:00:00Z" },
      end: { dateTime: "2030-01-01T11:00:00Z" },
    })).toBe(true);
  });

  it("rejects missing summary", () => {
    expect(validateCreateEventInput({
      summary: "",
      start: { dateTime: "2030-01-01T10:00:00Z" },
      end: { dateTime: "2030-01-01T11:00:00Z" },
    })).toBe(false);
  });

  it("rejects an end before start", () => {
    expect(validateCreateEventInput({
      summary: "bad",
      start: { dateTime: "2030-01-01T11:00:00Z" },
      end: { dateTime: "2030-01-01T10:00:00Z" },
    })).toBe(false);
  });
});
