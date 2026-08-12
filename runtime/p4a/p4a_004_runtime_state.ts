export type RuntimeState = {
  sh_id: string;
  account_id: string;
  continuity: "CONTINUOUS" | "NEW";
  time_gap_seconds: number | null;
  last_activity_at: string | null;
};

export function resolveRuntimeState(input: {
  sh_id: string;
  account_id: string;
  now: string;
  last_activity_at?: string | null;
  session_gap_seconds: number;
}): RuntimeState {
  const last = input.last_activity_at ? Date.parse(input.last_activity_at) : NaN;
  const now = Date.parse(input.now);
  const gap = Number.isFinite(last) && Number.isFinite(now) ? Math.max(0, (now - last) / 1000) : null;
  return {
    sh_id: input.sh_id,
    account_id: input.account_id,
    continuity: gap !== null && gap <= input.session_gap_seconds ? "CONTINUOUS" : "NEW",
    time_gap_seconds: gap,
    last_activity_at: input.last_activity_at ?? null,
  };
}
