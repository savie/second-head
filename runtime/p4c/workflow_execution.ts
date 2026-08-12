export type WorkflowStatus =
  | "PLANNED"
  | "RUNNING"
  | "COMPLETED"
  | "FAILED"
  | "CANCELLED";

export type WorkflowStep<T> = {
  id: string;
  run: () => Promise<T>;
};

export type WorkflowEvent = {
  type: "WORKFLOW_STARTED" | "STEP_COMPLETED" | "WORKFLOW_COMPLETED" | "WORKFLOW_FAILED";
  workflowId: string;
  stepId?: string;
  status: WorkflowStatus;
  timestamp: string;
  error?: string;
};

export type WorkflowExecutionResult<T> = {
  workflowId: string;
  status: "COMPLETED" | "FAILED";
  completedSteps: string[];
  failedStep?: string;
  events: WorkflowEvent[];
  output?: T;
  error?: string;
};

/**
 * Bounded, deterministic workflow execution for P4C-002.
 * It executes only the supplied finite step list; it does not create an
 * autonomous/open-ended agent loop or mutate persistence by itself.
 */
export async function executeWorkflow<T>(
  workflowId: string,
  steps: WorkflowStep<T>[],
  now: () => string = () => new Date().toISOString(),
): Promise<WorkflowExecutionResult<T>> {
  if (!workflowId) throw new Error("workflowId is required");

  const events: WorkflowEvent[] = [
    {
      type: "WORKFLOW_STARTED",
      workflowId,
      status: "RUNNING",
      timestamp: now(),
    },
  ];
  const completedSteps: string[] = [];
  let output: T | undefined;

  for (const step of steps) {
    try {
      output = await step.run();
      completedSteps.push(step.id);
      events.push({
        type: "STEP_COMPLETED",
        workflowId,
        stepId: step.id,
        status: "RUNNING",
        timestamp: now(),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      events.push({
        type: "WORKFLOW_FAILED",
        workflowId,
        stepId: step.id,
        status: "FAILED",
        timestamp: now(),
        error: message,
      });
      return {
        workflowId,
        status: "FAILED",
        completedSteps,
        failedStep: step.id,
        events,
        error: message,
      };
    }
  }

  events.push({
    type: "WORKFLOW_COMPLETED",
    workflowId,
    status: "COMPLETED",
    timestamp: now(),
  });

  return {
    workflowId,
    status: "COMPLETED",
    completedSteps,
    events,
    output,
  };
}
