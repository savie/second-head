import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Candidate = Record<string, unknown>;
type SemanticResult = {
  memory?: Candidate;
  knowledge?: Candidate;
  experience?: Candidate;
  journey?: Candidate;
  replacement?: Candidate;
};

function explicitMemoryOptIn(userMessage: string): boolean {
  const text = userMessage.trim();
  if (!text) return false;
  return /(?:tolong\s+)?(?:simpan|ingat|remember|save|store|catat|keep|retain)\b.{0,160}(?:sebagai|as|ke|into|in)?\s*(?:memory|memori)\b/i.test(text)
    || /\b(?:jadikan|tetapkan)\b.{0,160}(?:memory|memori)\b/i.test(text);
}

function explicitExperienceRequest(userMessage: string): boolean {
  const text = userMessage.trim();
  if (!text) return false;
  const persistence = /^(?:tolong\s+)?(?:simpan(?:lah)?|save|store|remember|ingat(?:lah)?|catat|keep|retain)\b/i.test(text);
  const designate = /^(?:jadikan|tetapkan)\b/i.test(text);
  return /\b(?:experience|pengalaman)\b/i.test(text) && (persistence || designate);
}

function explicitKnowledgeRequest(userMessage: string): boolean {
  const text = userMessage.trim();
  if (!/^(?:tolong\s+)?(?:simpan|ingat|remember|save|store|catat|jadikan|tetapkan|pelajari|learn)\b/i.test(text)) return false;
  return /\b(?:knowledge|pengetahuan|pelajari|learn|teaching|ajarkan)\b/i.test(text);
}

function extractMemoryContent(userMessage: string): string {
  const text = userMessage.trim();
  return text;
}

async function recordJourney(supabase: ReturnType<typeof createClient>, shId: string, eventType: string, payload: Record<string, unknown>) {
  const { data, error } = await supabase.rpc("runtime_record_journey_event", { p_sh_id: shId, p_event_type: eventType, p_continuity_status: "CONTINUOUS", p_payload: payload, p_source_ref: "ai-runtime:explicit-user-request" });
  if (error) throw new Error(`JOURNEY_RECORD_FAILED: ${error.message}`);
  return data;
}

export async function recordExplicitSemanticLifecycle(supabase: ReturnType<typeof createClient>, shId: string, userMessage: string): Promise<SemanticResult> {
  const result: SemanticResult = {};
  if (explicitKnowledgeRequest(userMessage)) {
    result.knowledge = { content: userMessage.trim() };
  }
  if (explicitMemoryOptIn(userMessage)) {
    result.memory = { content: extractMemoryContent(userMessage) };
  }
  if (explicitExperienceRequest(userMessage)) {
    result.experience = { content: userMessage.trim() };
  }
  return result;
}
