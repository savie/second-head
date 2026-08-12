export type RuntimeResponseInput = {
  request_id: string;
  sh_id: string;
  response: unknown;
};

export type RuntimeResponseOutput = {
  ok: true;
  request_id: string;
  sh_id: string;
  response: unknown;
};

/**
 * P4A-009: finalize the runtime response without exposing internal
 * orchestration metadata or granting new authority to the response layer.
 * This boundary does not mutate identity, ownership, memory, or state.
 */
export function finalizeRuntimeResponse(
  input: RuntimeResponseInput,
): RuntimeResponseOutput {
  if (!input.request_id || !input.sh_id) {
    throw new Error("INVALID_RUNTIME_RESPONSE_CONTEXT");
  }

  return {
    ok: true,
    request_id: input.request_id,
    sh_id: input.sh_id,
    response: input.response,
  };
}
