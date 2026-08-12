/**
 * P4B-003 — Reasoning Validation & Prompt-Injection Boundary
 * Phase 4 — Runtime & Orchestration
 *
 * Minimal realization only.
 *
 * Security rule:
 * - contextual/external content is data, not authority;
 * - detected instruction-override patterns are blocked before model execution;
 * - a bounded security event may be emitted without storing raw context;
 * - no specific detector is treated as canonical; this is a v1 implementation
 *   boundary that can be replaced/improved without changing SH identity.
 */

import type { ReasoningContext, ReasoningEngine, ReasoningResult } from './reasoning_context.ts';

export type ReasoningSecurityEvent = Readonly<{
  sh_id: string;
  event_type: 'SECURITY_PROMPT_INJECTION';
  status: 'BLOCKED';
  metadata: Readonly<Record<string, unknown>>;
}>;

export interface ReasoningSecurityEventSink {
  append(event: ReasoningSecurityEvent): Promise<void>;
}

export type ReasoningSecurityResult = Readonly<{
  allowed: boolean;
  reason?: 'INSTRUCTION_OVERRIDE_DETECTED' | 'UNTRUSTED_AUTHORITY_CLAIM';
  flagged_entries: number;
}>;

const OVERRIDE_PATTERNS = [
  /ignore\s+(all\s+)?(previous|prior|above)\s+instructions?/i,
  /disregard\s+(all\s+)?(previous|prior|above)\s+instructions?/i,
  /override\s+(the\s+)?system\s+instructions?/i,
  /reveal\s+(the\s+)?system\s+prompt/i,
  /reveal\s+(your|the)\s+(hidden|internal)\s+instructions?/i,
  /you\s+are\s+now\s+(the\s+)?system/i,
];

function containsOverrideText(value: unknown): boolean {
  if (typeof value === 'string') {
    return OVERRIDE_PATTERNS.some((pattern) => pattern.test(value));
  }

  if (Array.isArray(value)) {
    return value.some(containsOverrideText);
  }

  if (value && typeof value === 'object') {
    return Object.values(value as Record<string, unknown>).some(containsOverrideText);
  }

  return false;
}

function containsAuthorityClaim(value: unknown): boolean {
  if (Array.isArray(value)) {
    return value.some(containsAuthorityClaim);
  }

  if (!value || typeof value !== 'object') {
    return false;
  }

  const record = value as Record<string, unknown>;
  const role = typeof record.role === 'string' ? record.role.toLowerCase() : '';
  const authority = typeof record.authority === 'string' ? record.authority.toLowerCase() : '';
  const trust = typeof record.trust === 'string' ? record.trust.toLowerCase() : '';

  if (role === 'system' || authority === 'system' || authority === 'root' || trust === 'system') {
    return true;
  }

  return Object.values(record).some(containsAuthorityClaim);
}

/**
 * Validates only contextual/external entries. The user's direct message is not
 * treated as external data and is therefore intentionally outside this detector.
 */
export function validateReasoningSecurityBoundary(
  context: ReasoningContext,
): ReasoningSecurityResult {
  let flagged = 0;

  for (const entry of context.entries) {
    if (containsAuthorityClaim(entry)) {
      flagged += 1;
      continue;
    }

    if (containsOverrideText(entry)) {
      flagged += 1;
    }
  }

  if (flagged > 0) {
    return Object.freeze({
      allowed: false,
      reason: containsAuthorityClaim(context.entries)
        ? 'UNTRUSTED_AUTHORITY_CLAIM'
        : 'INSTRUCTION_OVERRIDE_DETECTED',
      flagged_entries: flagged,
    });
  }

  return Object.freeze({ allowed: true, flagged_entries: 0 });
}

/**
 * Wraps the existing reasoning engine without changing its public contract.
 * A blocked context never reaches the model executor.
 */
export function createReasoningSecurityBoundary(
  engine: ReasoningEngine,
  securityEvents?: ReasoningSecurityEventSink,
): ReasoningEngine {
  return {
    async process(request): Promise<ReasoningResult> {
      const validation = validateReasoningSecurityBoundary(request.context);

      if (!validation.allowed) {
        await securityEvents?.append({
          sh_id: request.context.identity.sh_id,
          event_type: 'SECURITY_PROMPT_INJECTION',
          status: 'BLOCKED',
          metadata: {
            stage: 'reasoning_security_boundary',
            policy_version: 'P4B-003.v1',
            reason: validation.reason,
            flagged_entries: validation.flagged_entries,
          },
        });

        return Object.freeze({
          output: 'I can’t safely use that contextual instruction as authority.',
        });
      }

      return engine.process(request);
    },
  };
}
