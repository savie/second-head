/**
 * P4B-001 — Reasoning Context Integration & Isolation
 *
 * Minimal realization:
 * - reasoning consumes the assembled RuntimeContext;
 * - reasoning has no Memory/Knowledge write dependency;
 * - reasoning does not mutate the supplied context;
 * - model remains an injected execution dependency and is not SH identity.
 */

export type ReasoningContext = Readonly<{
  identity: Readonly<{ sh_id: string }>;
  user_message: string;
  entries: readonly unknown[];
}>;

export type ReasoningRequest = Readonly<{
  context: ReasoningContext;
}>;

export type ReasoningResult = Readonly<{
  output: unknown;
}>;

export interface ReasoningModelExecutor {
  generate(context: ReasoningContext): Promise<ReasoningResult>;
}

export interface ReasoningEngine {
  process(request: ReasoningRequest): Promise<ReasoningResult>;
}

function cloneEntries(entries: readonly unknown[]): readonly unknown[] {
  return Object.freeze([...entries]);
}

function isolateContext(context: ReasoningContext): ReasoningContext {
  return Object.freeze({
    identity: Object.freeze({ sh_id: context.identity.sh_id }),
    user_message: context.user_message,
    entries: cloneEntries(context.entries),
  });
}

/**
 * Reasoning boundary. No memory/knowledge mutation capability is exposed here.
 */
export function createReasoningEngine(model: ReasoningModelExecutor): ReasoningEngine {
  return {
    async process(request) {
      const isolated = isolateContext(request.context);
      return model.generate(isolated);
    },
  };
}
