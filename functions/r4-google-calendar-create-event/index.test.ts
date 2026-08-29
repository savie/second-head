import { describe, expect, it } from "vitest";

function validateCreateEventInput(value: unknown): boolean {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const v = value as Record<string, unknown>;
  if (typeof v.summary !== "string" || !v.summary.trim() || v.summary.length > 500) return false;
  for (const key of ["start", "end"]) {
    const point = v[key];
    if (!point || typeof point !== "object" || Array.isArray(point)) return false;
    const p = point as Record<string, unknown>;
    if (typeof p.dateTime !== "string" || !p.dateTime.trim()) return false;
    if (Number.isNaN(Date.parse(p.dateTime))) return false;
  }
  return new Date((v.end as {dateTime:string}).dateTime).getTime()
    > new Date((v.start as {dateTime:string}).dateTime).getTime();
}

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
