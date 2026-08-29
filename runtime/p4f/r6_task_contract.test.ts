import { assertEquals, assertRejects } from "jsr:@std/assert";

type TaskInput = Readonly<{ title: string; due_at: string }>;

function validateTask(input: TaskInput, nowMs: number): { title: string; due_at: string } {
  const title = input.title.trim();
  const parsed = Date.parse(input.due_at);
  if (!title) throw new Error("R6_TASK_REJECTED: title is required");
  if (!Number.isFinite(parsed)) throw new Error("R6_TASK_REJECTED: ISO due time is required");
  if (parsed <= nowMs) throw new Error("R6_TASK_REJECTED: due time must be in the future");
  return { title, due_at: new Date(parsed).toISOString() };
}

Deno.test("R6 task contract accepts future owner task", () => {
  const result = validateTask(
    { title: "Review proposal", due_at: "2026-08-30T09:00:00+07:00" },
    Date.parse("2026-08-29T10:00:00+07:00"),
  );
  assertEquals(result.title, "Review proposal");
  assertEquals(result.due_at, "2026-08-30T02:00:00.000Z");
});

Deno.test("R6 task contract rejects missing title", async () => {
  await assertRejects(async () => validateTask({ title: "   ", due_at: "2026-08-30T09:00:00+07:00" }, Date.now()), "R6_TASK_REJECTED: title is required");
});

Deno.test("R6 task contract rejects past due time", async () => {
  await assertRejects(async () => validateTask({ title: "Old task", due_at: "2026-08-28T09:00:00+07:00" }, Date.parse("2026-08-29T10:00:00+07:00")), "R6_TASK_REJECTED: due time must be in the future");
});
