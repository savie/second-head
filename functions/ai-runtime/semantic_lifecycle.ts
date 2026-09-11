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
  const saveMatch = text.match(/^(?:tolong\s+)?(?:simpan(?:lah)?|save|store|remember|ingat(?:lah)?|catat|keep|retain)\b\s*(?:bahwa|that|:)?\s*(.*?)\s*(?:(?:sebagai|as|ke|into|in)\s+(?:memory|memori))?\s*\.?$/i);
  if (saveMatch?.[1]?.trim()) return saveMatch[1].trim();
  const designateMatch = text.match(/^\s*(?:jadikan|tetapkan)\b\s*(.*?)\s+(?:sebagai|as)\s+(?:memory|memori)\s*\.?$/i);
  if (designateMatch?.[1]?.trim()) return designateMatch[1].trim();
  return text;
}

function extractExperienceContent(userMessage: string): string {
  const text = userMessage.trim();
  const afterDomain = text.match(/\b(?:sebagai|as)\s+(?:an?\s+)?(?:experience|pengalaman)\s*:?\s*(.*?)\s*\.?$/i);
  if (afterDomain?.[1]?.trim()) return afterDomain[1].trim();
  const designate = text.match(/^\s*(?:jadikan|tetapkan)\b\s*(.*?)\s+(?:sebagai|as)\s+(?:an?\s+)?(?:experience|pengalaman)\s*\.?$/i);
  if (designate?.[1]?.trim()) return designate[1].trim();
  return text;
}

function replacementRequest(userMessage: string): { newContent: string; oldPattern: string } | undefined {
  const match = userMessage.match(/\b(APK\s*#?\d+)\b.*?\b(?:sebagai\s+pengganti|menggantikan|replace(?:\s+with)?|replacing)\b.*?\b(APK\s*#?\d+)\b/i);
  if (!match) return undefined;
  return { newContent: `${match[1]} menggantikan ${match[2]} sebagai runtime test vehicle.`, oldPattern: match[2] };
}

async function recordJourney(
  supabase: ReturnType<typeof createClient>,
  shId: string,
  eventType: string,
  payload: Record<string, unknown>,
) {
  const { data, error } = await supabase.rpc("runtime_record_journey_event", {
    p_sh_id: shId,
    p_event_type: eventType,
    p_continuity_status: "CONTINUOUS",
    p_payload: payload,
    p_source_ref: "ai-runtime:explicit-user-request",
  });
  if (error) throw new Error(`JOURNEY_RECORD_FAILED: ${error.message}`);
  return data;
}

export async function recordExplicitSemanticLifecycle(
  supabase: ReturnType<typeof createClient>,
  shId: string,
  userMessage: string,
): Promise<SemanticResult> {
  const result: SemanticResult = {};

  const replacement = replacementRequest(userMessage);
  if (replacement) {
    const { data, error } = await supabase.rpc("runtime_replace_memory", {
      p_sh_id: shId,
      p_new_content: replacement.newContent,
      p_old_pattern: replacement.oldPattern,
      p_source: "ai-runtime:explicit-user-request",
      p_scope: "PRIVATE",
      p_visibility: "OWNER_ONLY",
    });
    if (error) throw new Error(`MEMORY_REPLACEMENT_FAILED: ${error.message}`);
    result.replacement = { memory_id: data, ...replacement };
    result.journey = { event_id: await recordJourney(supabase, shId, "EVOLUTION", { mode: "MEMORY_REPLACEMENT", ...replacement, memory_id: data }) };
    return result;
  }

  if (explicitKnowledgeRequest(userMessage)) {
    const content = userMessage.trim();
    const { data, error } = await supabase.rpc("runtime_record_knowledge_with_journey", {
      p_sh_id: shId,
      p_content: content,
      p_source: "ai-runtime:explicit-user-request",
      p_origin: "EXPLICIT_TEACHING",
      p_provenance: { source_message: content, capture_mode: "EXPLICIT_USER_REQUEST" },
      p_scope: "PRIVATE",
      p_visibility: "OWNER_ONLY",
      p_confidence: 1,
    });
    if (error) throw new Error(`KNOWLEDGE_PERSISTENCE_FAILED: ${error.message}`);
    result.knowledge = { knowledge_id: data, content };
    result.journey = { event_id: data, event_type: "LEARNING" };
    return result;
  }

  if (explicitExperienceRequest(userMessage)) {
    const content = extractExperienceContent(userMessage);
    const { data, error } = await supabase.rpc("runtime_record_experience", {
      p_sh_id: shId,
      p_experience_type: "EXPLICIT_USER_REQUEST",
      p_content: content,
      p_scope: "PRIVATE",
      p_visibility: "OWNER_ONLY",
      p_transfer_policy: "NON_TRANSFERABLE",
      p_source_ref: "ai-runtime:explicit-user-request",
      p_provenance: { source_message: userMessage.trim(), capture_mode: "EXPLICIT_USER_REQUEST" },
    });
    if (error) throw new Error(`EXPERIENCE_PERSISTENCE_FAILED: ${error.message}`);
    const eventId = await recordJourney(supabase, shId, "EXPERIENCE", { experience_id: data, capture_mode: "EXPLICIT_USER_REQUEST" });
    result.experience = { experience_id: data, content };
    result.journey = { event_id: eventId, event_type: "EXPERIENCE" };
    return result;
  }

  if (explicitMemoryOptIn(userMessage)) {
    const content = extractMemoryContent(userMessage);
    const { data, error } = await supabase.rpc("runtime_record_memory_with_journey", {
      p_sh_id: shId,
      p_content: content,
      p_memory_type: "LONG_TERM",
      p_source: "ai-runtime:explicit-user-request",
      p_confidence: 1,
      p_scope: "PRIVATE",
      p_visibility: "OWNER_ONLY",
      p_lifecycle: "CANDIDATE",
    });
    if (error) throw new Error(`MEMORY_PERSISTENCE_FAILED: ${error.message}`);
    result.memory = { memory_id: data, content };
    result.journey = { event_id: data, event_type: "MEMORY" };
  }

  return result;
}
