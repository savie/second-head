import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Candidate = Record<string, unknown>;
function objectValue(value: unknown): Candidate | undefined { return value && typeof value === "object" && !Array.isArray(value) ? value as Candidate : undefined; }
const KNOWLEDGE_ORIGINS = new Set(["MEMORY", "EXPLICIT_TEACHING", "EXTERNAL_REFERENCE"]);
function normalizeKnowledgeOrigin(value: unknown): string { const raw = typeof value === "string" ? value.trim().toUpperCase().replace(/[ -]+/g, "_") : ""; if (KNOWLEDGE_ORIGINS.has(raw)) return raw; if (["USER_TEACHING", "OWNER_TEACHING", "EXPLICIT_USER_TEACHING", "TEACHING", "USER_INSTRUCTION", "OWNER_INSTRUCTION"].includes(raw)) return "EXPLICIT_TEACHING"; return ""; }

export function hasExplicitMemoryOptOut(userMessage: string): boolean {
  const text = userMessage.trim();
  if (!text) return false;
  const memoryTerm = "(?:memory|memori)";
  const deny = "(?:tidak|tak|jangan|don't|do not|dont|not|never|no)";
  const persistence = "(?:simpan|menyimpan|simpanlah|ingat|mengingat|save|store|remember|retain|keep)";
  return new RegExp(`(?:${deny}).{0,80}${persistence}.{0,80}(?:sebagai|as|ke|into|in)?\\s*${memoryTerm}|(?:${persistence}).{0,80}(?:${deny}).{0,80}${memoryTerm}`, "i").test(text)
    || /(?:do not|don't|dont|jangan|tidak|tak)\s+(?:meminta|minta|ingin|mau|want|ask).{0,80}(?:simpan|save|store|remember).{0,80}(?:memory|memori)/i.test(text);
}

export function hasExplicitMemoryOptIn(userMessage: string): boolean {
  const text = userMessage.trim();
  if (!text) return false;
  return /(?:tolong\s+)?(?:simpan|ingat|remember|save|store|catat|keep|retain)\b.{0,160}(?:sebagai|as|ke|into|in)?\s*(?:memory|memori)\b/i.test(text)
    || /\b(?:jadikan|tetapkan)\b.{0,160}(?:memory|memori)\b/i.test(text);
}

function extractExplicitMemoryContent(userMessage: string): string {
  const text = userMessage.trim();
  const saveMatch = text.match(/^(?:tolong\s+)?(?:simpan(?:lah)?|save|store|remember|ingat(?:lah)?|catat|keep|retain)\b\s*(?:bahwa|that|:)?\s*(.*?)\s*(?:(?:sebagai|as|ke|into|in)\s+(?:memory|memori))?\s*\.?$/i);
  if (saveMatch?.[1]?.trim()) return saveMatch[1].trim();
  const designateMatch = text.match(/^\s*(?:jadikan|tetapkan)\b\s*(.*?)\s+(?:sebagai|as)\s+(?:memory|memori)\s*\.?$/i);
  if (designateMatch?.[1]?.trim()) return designateMatch[1].trim();
  return text;
}

function replacementRequest(userMessage: string): { newContent: string; oldPattern: string } | undefined {
  const m = userMessage.match(/\b(APK\s*#?\d+)\b.*?\b(?:sebagai\s+pengganti|menggantikan|replace(?:\s+with)?|replacing)\b.*?\b(APK\s*#?\d+)\b/i);
  if (!m) return undefined;
  return { newContent: `${m[1]} menggantikan ${m[2]} sebagai runtime test vehicle.`, oldPattern: m[2] };
}
function explicitPersistenceFallback(userMessage: string): { memory?: Candidate; knowledge?: Candidate } | undefined {
  const text = userMessage.trim();
  if (!/^(?:tolong\s+)?(?:simpan|ingat|remember|save|store|catat|jadikan|tetapkan|pelajari|learn)\b/i.test(text)) return undefined;
  if (/\b(?:knowledge|pengetahuan|pelajari|learn|teaching|ajarkan)\b/i.test(text)) return { knowledge: { content: text, source: "runtime:p5a:explicit_user_request", origin: "EXPLICIT_TEACHING", scope: "PRIVATE", visibility: "OWNER_ONLY", provenance: { source_message: text, capture_mode: "EXPLICIT_USER_REQUEST" } } };
  return { memory: { content: extractExplicitMemoryContent(text), memory_type: "LONG_TERM", source: "runtime:p5a:explicit_user_request", scope: "PRIVATE", visibility: "OWNER_ONLY", lifecycle: "CANDIDATE" } };
}

function memoryDeleteRequest(userMessage: string): boolean {
  return /(?:\b(?:hapus|delete|remove|hilangkan|buang)\b).{0,160}\b(?:memory|memori)\b/i.test(userMessage)
    || /\b(?:memory|memori)\b.{0,160}\b(?:hapus|delete|remove|hilangkan|buang)\b/i.test(userMessage);
}
function deletionTokens(text: string): string[] {
  return text.toLowerCase().normalize('NFKC').split(/[^a-z0-9\u00c0-\u024f]+/i).filter(x => x.length >= 4 && !['memory','memori','tentang','about','hapus','delete','remove','hilangkan','buang'].includes(x));
}
async function deleteRequestedMemory(supabase: ReturnType<typeof createClient>, shId: string, userMessage: string): Promise<{ memory: string; memory_id: string } | null> {
  if (!memoryDeleteRequest(userMessage)) return null;
  const { data, error } = await supabase.from('memories').select('memory_id,content').eq('sh_id', shId).limit(100);
  if (error) throw new Error('MEMORY_DELETE_LOOKUP_FAILED: ' + error.message);
  const tokens = deletionTokens(userMessage);
  const codeTokens = tokens.filter(x => /[0-9]/.test(x));
  const scored = (data ?? []).map((row: {memory_id: string; content: string}) => {
    const content = String(row.content ?? '').toLowerCase().normalize('NFKC');
    let score = 0;
    for (const token of tokens) if (content.includes(token)) score += /[0-9]/.test(token) || token.length >= 7 ? 3 : 1;
    if (codeTokens.length && codeTokens.every(t => content.includes(t))) score += 10;
    return { row, score };
  }).filter(x => x.score > 0).sort((a,b) => b.score-a.score);
  if (!scored.length || (scored.length > 1 && scored[0].score === scored[1].score)) throw new Error('MEMORY_DELETE_REJECTED: target memory could not be uniquely identified');
  const target = scored[0].row;
  const { error: deleteError } = await supabase.rpc('runtime_delete_record_with_journey', { p_domain: 'MEMORY', p_record_id: target.memory_id });
  if (deleteError) throw new Error('MEMORY_DELETE_FAILED: ' + deleteError.message);
  return { memory: String(target.content), memory_id: String(target.memory_id) };
}

export async function recordSemanticLifecycle(supabase: ReturnType<typeof createClient>, shId: string, userMessage: string, modelResponse: { semantic_signals?: Record<string, unknown> }) {
  const deletion = await deleteRequestedMemory(supabase, shId, userMessage);
  if (deletion) return { memory: null, knowledge: null, deletedMemory: deletion };
  const signals = objectValue(modelResponse.semantic_signals) ?? {};
  const replacement = replacementRequest(userMessage);
  if (replacement) {
    const { data, error } = await supabase.rpc("runtime_replace_memory", { p_sh_id: shId, p_new_content: replacement.newContent, p_old_pattern: replacement.oldPattern, p_source: "runtime:p5a:explicit_user_request", p_scope: "PRIVATE", p_visibility: "OWNER_ONLY" });
    if (error) throw new Error(`MEMORY_REPLACEMENT_FAILED: ${error.message}`);
    const memory = typeof data === "string" ? data : null;
    if (!memory) throw new Error("MEMORY_REPLACEMENT_FAILED: recorder returned no memory id");
    return { memory, knowledge: null };
  }

  const memoryOptOut = hasExplicitMemoryOptOut(userMessage);
  const memoryOptIn = hasExplicitMemoryOptIn(userMessage);
  const fallback = explicitPersistenceFallback(userMessage);
  // Memory is explicit opt-in. For an explicit persistence request, prefer the
  // user-derived payload over a model paraphrase so semantically identical saves
  // converge on the same canonical content and database deduplication boundary.
  const memoryCandidate = (!memoryOptOut && memoryOptIn) ? (fallback?.memory ?? objectValue(signals.memory_candidate)) : undefined;
  let memory: string | null = null; let knowledge: string | null = null;
  if (memoryCandidate) {
    const content = typeof memoryCandidate.content === "string" ? memoryCandidate.content.trim() : "";
    if (content) {
      const isExplicitFallback = Boolean(fallback?.memory && memoryCandidate === fallback.memory);
      const { data, error } = await supabase.rpc("runtime_record_memory_with_journey", { p_sh_id: shId, p_content: content, p_memory_type: memoryCandidate.memory_type ?? "LONG_TERM", p_source: isExplicitFallback ? "runtime:p5a:explicit_user_request" : "runtime:p4d:memory_candidate", p_confidence: memoryCandidate.confidence ?? null, p_scope: "PRIVATE", p_visibility: "OWNER_ONLY", p_lifecycle: "CANDIDATE" });
      if (error) throw new Error(`MEMORY_RECORD_FAILED: ${error.message}`);
      memory = typeof data === "string" ? data : null;
      if (!memory) throw new Error("MEMORY_RECORD_FAILED: recorder returned no memory id");
    }
  }
  const knowledgeCandidate = objectValue(signals.knowledge_candidate) ?? fallback?.knowledge;
  if (knowledgeCandidate) {
    const content = typeof knowledgeCandidate.content === "string" ? knowledgeCandidate.content.trim() : "";
    const candidateSource = typeof knowledgeCandidate.source === "string" ? knowledgeCandidate.source.trim() : "";
    const origin = normalizeKnowledgeOrigin(knowledgeCandidate.origin) || (fallback?.knowledge ? "EXPLICIT_TEACHING" : "");
    const source = candidateSource || (fallback?.knowledge ? "runtime:p5a:explicit_user_request" : "runtime:p4d:knowledge_candidate");
    if (content && source && origin) {
      const isExplicitFallback = Boolean(fallback?.knowledge && knowledgeCandidate === fallback.knowledge);
      const { data, error } = await supabase.rpc("runtime_record_knowledge_with_journey", { p_sh_id: shId, p_content: content, p_source: isExplicitFallback ? "runtime:p5a:explicit_user_request" : source, p_origin: origin, p_provenance: knowledgeCandidate.provenance ?? { source_message: userMessage }, p_scope: "PRIVATE", p_visibility: "OWNER_ONLY", p_confidence: knowledgeCandidate.confidence ?? null });
      if (error) throw new Error(`KNOWLEDGE_ACQUISITION_FAILED: ${error.message}`);
      knowledge = typeof data === "string" ? data : null;
      if (!knowledge) throw new Error("KNOWLEDGE_ACQUISITION_FAILED: recorder returned no knowledge id");
    }
  }
  return { memory, knowledge, deletedMemory: null };
}
