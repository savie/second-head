import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Candidate = Record<string, unknown>;

function objectValue(value: unknown): Candidate | undefined {
  return value && typeof value === "object" && !Array.isArray(value) ? value as Candidate : undefined;
}

export async function recordSemanticLifecycle(
  supabase: ReturnType<typeof createClient>,
  shId: string,
  userMessage: string,
  modelResponse: { semantic_signals?: Record<string, unknown> },
) {
  const signals = objectValue(modelResponse.semantic_signals);
  if (!signals) return { memory: null, knowledge: null };

  let memory: string | null = null;
  let knowledge: string | null = null;

  const memoryCandidate = objectValue(signals.memory_candidate);
  if (memoryCandidate) {
    const content = typeof memoryCandidate.content === "string" ? memoryCandidate.content.trim() : "";
    if (content) {
      const { data, error } = await supabase.rpc("runtime_record_memory", {
        p_sh_id: shId,
        p_content: content,
        p_memory_type: memoryCandidate.memory_type ?? "LONG_TERM",
        p_source: memoryCandidate.source ?? "runtime:p4d:memory_candidate",
        p_confidence: memoryCandidate.confidence ?? null,
        p_scope: memoryCandidate.scope ?? "PRIVATE",
        p_visibility: memoryCandidate.visibility ?? "OWNER_ONLY",
        p_lifecycle: memoryCandidate.lifecycle ?? "CANDIDATE",
      });
      if (error) throw new Error(`MEMORY_RECORD_FAILED: ${error.message}`);
      memory = typeof data === "string" ? data : null;
    }
  }

  const knowledgeCandidate = objectValue(signals.knowledge_candidate);
  if (knowledgeCandidate) {
    const content = typeof knowledgeCandidate.content === "string" ? knowledgeCandidate.content.trim() : "";
    const source = typeof knowledgeCandidate.source === "string" ? knowledgeCandidate.source.trim() : "";
    const origin = typeof knowledgeCandidate.origin === "string" ? knowledgeCandidate.origin : "";
    if (content && source && origin) {
      const { data, error } = await supabase.rpc("runtime_record_knowledge_candidate", {
        p_sh_id: shId,
        p_content: content,
        p_source: source,
        p_origin: origin,
        p_provenance: knowledgeCandidate.provenance ?? { source_message: userMessage },
        p_scope: knowledgeCandidate.scope ?? "PRIVATE",
        p_visibility: knowledgeCandidate.visibility ?? "OWNER_ONLY",
        p_confidence: knowledgeCandidate.confidence ?? null,
      });
      if (error) throw new Error(`KNOWLEDGE_ACQUISITION_FAILED: ${error.message}`);
      knowledge = typeof data === "string" ? data : null;
    }
  }

  return { memory, knowledge };
}
