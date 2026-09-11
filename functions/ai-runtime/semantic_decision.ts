export type SemanticDomain =
  | "MEMORY"
  | "KNOWLEDGE"
  | "EXPERIENCE"
  | "JOURNEY";

export type SemanticSignal = {
  domain: SemanticDomain;
  confidence: number;
  evidence: string;
  source: "MODEL" | "USER";
};

export type SemanticDecision =
  | "ACCEPT"
  | "REJECT"
  | "CONFIRM";

/**
 * Runtime policy boundary.
 * Model output is only a candidate. Persistence authority stays here.
 */
export function evaluateSemanticSignal(signal: SemanticSignal): SemanticDecision {
  if (signal.source === "USER") {
    return "ACCEPT";
  }

  if (signal.domain === "EXPERIENCE") {
    return "CONFIRM";
  }

  if (signal.confidence < 0.8) {
    return "REJECT";
  }

  return "CONFIRM";
}
