import { orchestrateStages, RuntimeOrchestrationResult, RuntimeStageResult } from "./runtime_orchestration_contract";

export type RuntimePipelineInput = {
  request_id: string;
  sh_id: string;
  identity: unknown;
  context: unknown;
  model: unknown;
  response: unknown;
};

/**
 * P4A-008: compose the already-authorized runtime slices without introducing
 * new authority. This is a pure integration boundary: no persistence, model
 * provider selection, tool invocation, or identity creation occurs here.
 */
export function composeRuntimePipeline(input: RuntimePipelineInput): RuntimeOrchestrationResult {
  const stages: RuntimeStageResult[] = [
    { stage: "IDENTITY", ok: Boolean(input.identity), data: input.identity },
    { stage: "CONTEXT", ok: Boolean(input.context), data: input.context },
    { stage: "MODEL", ok: Boolean(input.model), data: input.model },
  ];

  return orchestrateStages(input.request_id, stages, input.response, input.sh_id);
}
