import { assertEquals, assertRejects } from "jsr:@std/assert";
import { connectorRegistry } from "../../runtime/p4g/connectors/google_calendar.ts";

Deno.test("R7 connector registry exposes Google Calendar adapter", () => {
  const connector = connectorRegistry.google_calendar;
  assertEquals(connector.connector_id, "google_calendar");
  assertEquals(connector.capability, "calendar");
  assertEquals(typeof connector.createEvent, "function");
});

Deno.test("R7 connector adapter normalizes non-success provider response", async () => {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = (async () => new Response(JSON.stringify({ error: { message: "denied" } }), { status: 403 })) as typeof fetch;
  try {
    const result = await connectorRegistry.google_calendar.createEvent(
      "token",
      {
        summary: "R7 contract test",
        start: { dateTime: "2026-09-01T10:00:00Z" },
        end: { dateTime: "2026-09-01T11:00:00Z" },
      },
      "r7testevent",
    );
    assertEquals(result.result, undefined);
    assertEquals(result.httpStatus, 403);
    assertEquals(result.errorCode, "R4_GOOGLE_CALENDAR_WRITE_REJECTED");
  } finally {
    globalThis.fetch = originalFetch;
  }
});

Deno.test("R7 connector adapter returns normalized successful provider result", async () => {
  const originalFetch = globalThis.fetch;
  globalThis.fetch = (async () => new Response(JSON.stringify({
    id: "evt-r7",
    htmlLink: "https://calendar.google.com/event?eid=evt-r7",
    status: "confirmed",
  }), { status: 200 })) as typeof fetch;
  try {
    const result = await connectorRegistry.google_calendar.createEvent(
      "token",
      {
        summary: "R7 contract test",
        start: { dateTime: "2026-09-01T10:00:00Z" },
        end: { dateTime: "2026-09-01T11:00:00Z" },
      },
      "r7testevent",
    );
    assertEquals(result.result?.provider, "GOOGLE_CALENDAR");
    assertEquals(result.result?.event_id, "evt-r7");
    assertEquals(result.result?.calendar_id, "primary");
  } finally {
    globalThis.fetch = originalFetch;
  }
});
