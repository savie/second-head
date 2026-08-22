import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Candidate = Record<string, unknown>;
function objectValue(value: unknown): Candidate | undefined { return value && typeof value === "object" && !Array.isArray(value) ? value as Candidate : undefined; }
const KNOWLEDGE_ORIGINS = new Set(["MEMORY", "EXPLICIT_TEACHING", "EXTERNAL_REFERENCE"]);
function normalizeKnowledgeOrigin(value: unknown): string { const raw = typeof value === "string" ? value.trim().toUpperCase().replace(/[ -]+/g, "_") : ""; if (KNOWLEDGE_ORIGINS.has(raw)) return raw; if (["USER_TEACHING", "OWNER_TEACHING", "EXPLICIT_USER_TEACHING", "TEACHING", "USER_INSTRUCTION", "OWNER_INSTRUCTION"].includes(raw)) return "EXPLICIT_TEACHING"; return ""; }
function replacementRequest(userMessage: string): { newContent: string; oldPattern: string } | undefined {
  const m = userMessage.match(/\b(APK\s*#?\d+)\b.*?\b(?:sebagai\s+pengganti|menggantikan|replace(?:\s+with)?|replacing)\b.*?\b(APK\s*#?\d+)\b/i);
  if (!m) return undefined;
  return { newContent: `${m[1]} menggantikan ${m[2]} sebagai runtime test vehicle.`, oldPattern: m[2] };
}
function explicitPersistenceFallback(userMessage: string): { memory?: Candidate; knowledge?: Candidate } | undefined {
  const text = userMessage.trim();
  if (!/^(?:tolong\s+)?(?:simpan|ingat|remember|save|store|catat|jadikan|tetapkan|pelajari|learn)\b/i.test(text)) return undefined;
  if (/\b(?:knowledge|pengetahuan|pelajari|learn|teaching|ajarkan)\b/i.test(text)) return { knowledge: { content: text, source: "runtime:p5a:explicit_user_request", origin: "EXPLICIT_TEACHING", scope: "PRIVATE", visibility: "OWNER_ONLY", provenance: { source_message: text, capture_mode: "EXPLICIT_USER_REQUEST" } } };
  return { memory: { content: text, memory_type: "LONG_TERM", source: "runtime:p5a:explicit_user_request", scope: "PRIVATE", visibility: "OWNER_ONLY", lifecycle: "CANDIDATE" } };
}
export async function recordSemanticLifecycle(supabase: ReturnType<typeof createClient>, shId: string, userMessage: string, modelResponse: { semantic_signals?: Record<string, unknown> }) {
  const signals = objectValue(modelResponse.semantic_signals) ?? {};
  const replacement = replacementRequest(userMessage);
  if (replacement) {
    const { data, error } = await supabase.rpc("runtime_replace_memory", { p_sh_id: shId, p_new_content: replacement.newContent, p_old_pattern: replacement.oldPattern, p_source: "runtime:p5a:explicit_user_request", p_scope: "PRIVATE", p_visibility: "OWNER_ONLY" });
    if (error) throw new Error(`MEMORY_REPLACEMENT_FAILED: ${error.message}`);
    const memory = typeof data === "string" ? data : null;
    if (!memory) throw new Error("MEMORY_REPLACEMENT_FAILED: recorder returned no memory id");
    return { memory, knowledge: null };
  }
  const fallback = explicitPersistenceFallback(userMessage);
  let memory: string | null = null; let knowledge: string | null = null;
  const memoryCandidate = objectValue(signals.memory_candidate) ?? fallback?.memory;
  if (memoryCandidate) {
    const content = typeof memoryCandidate.content === "string" ? memoryCandidate.content.trim() : "";
    if (content) {
      const { data, error } = await supabase.rpc("runtime_record_memory_with_journey", { p_sh_id: shId, p_content: content, p_memory_type: memoryCandidate.memory_type ?? "LONG_TERM", p_source: memoryCandidate.source ?? "runtime:p4d:memory_candidate", p_confidence: memoryCandidate.confidence ?? null, p_scope: memoryCandidate.scope ?? "PRIVATE", p_visibility: memoryCandidate.visibility ?? "OWNER_ONLY", p_lifecycle: memoryCandidate.lifecycle ?? "CANDIDATE" });
      if (error) throw new Error(`MEMORY_RECORD_FAILED: ${error.message}`);
      memory = typeof data === "string" ? data : null;
      if (!memory) throw new Error("MEMORY_RECORD_FAILED: recorder returned no memory id");
    }
  }
  const knowledgeCandidate = objectValue(signals.knowledge_candidate) ?? fallback?.knowledge;
  if (knowledgeCandidate) {
    const content = typeof knowledgeCandidate.content === "string" ? knowledgeCandidate.content.trim() : "";
    const source = typeof knowledgeCandidate.source === "string" ? knowledgeCandidate.source.trim() : "";
    const origin = normalizeKnowledgeOrigin(knowledgeCandidate.origin);
    if (content && source && origin) {
      const { data, error } = await supabase.rpc("runtime_record_knowledge_with_journey", { p_sh_id: shId, p_content: content, p_source: source, p_origin: origin, p_provenance: knowledgeCandidate.provenance ?? { source_message: userMessage }, p_scope: knowledgeCandidate.scope ?? "PRIVATE", p_visibility: knowledgeCandidate.visibility ?? "OWNER_ONLY", p_confidence: knowledgeCandidate.confidence ?? null });
      if (error) throw new Error(`KNOWLEDGE_ACQUISITION_FAILED: ${error.message}`);
      knowledge = typeof data === "string" ? data : null;
      if (!knowledge) throw new Error("KNOWLEDGE_ACQUISITION_FAILED: recorder returned no knowledge id");
    }
  }
  return { memory, knowledge };
}
