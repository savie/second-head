export type CreateEventInput = Readonly<{
  summary: string;
  description?: string;
  location?: string;
  start: { dateTime: string; timeZone?: string };
  end: { dateTime: string; timeZone?: string };
}>;

export function validateCreateEventInput(value: unknown): value is CreateEventInput {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const v = value as Record<string, unknown>;
  if (typeof v.summary !== "string" || !v.summary.trim() || v.summary.length > 500) return false;
  if (v.description !== undefined && (typeof v.description !== "string" || v.description.length > 5000)) return false;
  if (v.location !== undefined && (typeof v.location !== "string" || v.location.length > 1000)) return false;

  for (const key of ["start", "end"]) {
    const point = v[key];
    if (!point || typeof point !== "object" || Array.isArray(point)) return false;
    const p = point as Record<string, unknown>;
    if (typeof p.dateTime !== "string" || !p.dateTime.trim()) return false;
    if (p.timeZone !== undefined && typeof p.timeZone !== "string") return false;
    if (Number.isNaN(Date.parse(p.dateTime))) return false;
  }

  const start = new Date((v.start as { dateTime: string }).dateTime).getTime();
  const end = new Date((v.end as { dateTime: string }).dateTime).getTime();
  return end > start;
}
