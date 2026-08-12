export type RuntimeStage =
  | "IDENTITY"
  | "CONTEXT"
  | "MODEL"
  | "MEMORY"
  | "AUDIT"
  | "CONVERSATION";

export type RuntimeStageResult<T = unknown> = {
  stage: RuntimeStage;
  ok: boolean;
  data?: T;
  error_code?: string;
};

export type RuntimeOrchestrationResult<T = unknown> = {
  ok: boolean;
  request_id: string;
  sh_id?: string;
  stages: RuntimeStageResult[];
  response?: T;
  failure_stage?: RuntimeStage;
};

export function orchestrateStages<T>(
  request_id: string,
  stages: RuntimeStageResult[],
  response?: T,
  sh_id?: string,
): RuntimeOrchestrationResult<T> {
  const failed = stages.find((stage) => !stage.ok);
  return {
    ok: !failed,
    request_id,
    sh_id,
    stages,
    response: failed ? undefined : response,
    failure_stage: failed?.stage,
  };
}

export function stageResult<T>(
  stage: RuntimeStage,
  data?: T,
): RuntimeStageResult<T> {
  return { stage, ok: true, data };
}

export function stageFailure(
  stage: RuntimeStage,
  error_code: string,
): RuntimeStageResult {
  return { stage, ok: false, error_code };
}
