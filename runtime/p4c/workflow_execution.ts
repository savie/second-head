export type WorkflowStatus =
  | "PLANNED"
  | "RUNNING"
  | "COMPLETED"
  | "FAILED"
  | "CANCELLED";

export type WorkflowStep<T> = {
  id: string;
  run: (signal?: AbortSignal) => Promise<T>;
};

export type WorkflowEvent = {
  type:
    | "WORKFLOW_STARTED"
    | "STEP_COMPLETED"
    | "WORKFLOW_COMPLETED"
    | "WORKFLOW_FAILED"
    | "WORKFLOW_CANCELLED";
  workflowId: string;
  stepId?: string;
  status: WorkflowStatus;
  timestamp: string;
  error?: string;
};

export type WorkflowExecutionResult<T> = {
  workflowId: string;
  status: "COMPLETED" | "FAILED" | "CANCELLED";
  completedSteps: string[];
  failedStep?: string;
  events: WorkflowEvent[];
  output?: T;
  error?: string;
};

export type WorkflowExecutionOptions = {
  signal?: AbortSignal;
  timeoutMs?: number;
};

/**
 * Bounded, deterministic workflow execution for P4C-002/P4C-003.
 * It executes only the supplied finite step list; it does not create an
 * autonomous/open-ended agent loop or mutate persistence by itself.
 *
 * Cancellation is cooperative: the signal is passed to each step and the
 * executor also stops before starting another step. A timeout requests
 * cancellation and prevents further workflow progress. Steps that perform
 * external work should observe the AbortSignal and clean up their own
 * transient resources.
 */
export async function executeWorkflow<T>(
  workflowId: string,
  steps: WorkflowStep<T>[],
  now: () => string = () => new Date().toISOString(),
  options: WorkflowExecutionOptions = {},
): Promise<WorkflowExecutionResult<T>> {
  if (!workflowId) throw new Error("workflowId is required");
  if (options.timeoutMs !== undefined && options.timeoutMs < 0) {
    throw new Error("timeoutMs must be non-negative");
  }

  const controller = new AbortController();
  const externalSignal = options.signal;
  const onExternalAbort = () => controller.abort(externalSignal?.reason);
  if (externalSignal) {
    if (externalSignal.aborted) controller.abort(externalSignal.reason);
    else externalSignal.addEventListener("abort", onExternalAbort, { once: true });
  }

  let timeoutHandle: ReturnType<typeof setTimeout> | undefined;
  if (options.timeoutMs !== undefined) {
    timeoutHandle = setTimeout(() => controller.abort(new Error("workflow timeout")), options.timeoutMs);
  }

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

  const cancellationReason = () => {
    const reason = controller.signal.reason;
    return reason instanceof Error ? reason.message : String(reason ?? "workflow cancelled");
  };

  try {
    for (const step of steps) {
      if (controller.signal.aborted) {
        const message = cancellationReason();
        events.push({
          type: "WORKFLOW_CANCELLED",
          workflowId,
          stepId: step.id,
          status: "CANCELLED",
          timestamp: now(),
          error: message,
        });
        return {
          workflowId,
          status: "CANCELLED",
          completedSteps,
          failedStep: undefined,
          events,
          error: message,
        };
      }

      try {
        output = await step.run(controller.signal);
        if (controller.signal.aborted) {
          const message = cancellationReason();
          events.push({
            type: "WORKFLOW_CANCELLED",
            workflowId,
            stepId: step.id,
            status: "CANCELLED",
            timestamp: now(),
            error: message,
          });
          return {
            workflowId,
            status: "CANCELLED",
            completedSteps,
            failedStep: undefined,
            events,
            error: message,
          };
        }

        completedSteps.push(step.id);
        events.push({
          type: "STEP_COMPLETED",
          workflowId,
          stepId: step.id,
          status: "RUNNING",
          timestamp: now(),
        });
      } catch (error) {
        if (controller.signal.aborted) {
          const message = cancellationReason();
          events.push({
            type: "WORKFLOW_CANCELLED",
            workflowId,
            stepId: step.id,
            status: "CANCELLED",
            timestamp: now(),
            error: message,
          });
          return {
            workflowId,
            status: "CANCELLED",
            completedSteps,
            failedStep: undefined,
            events,
            error: message,
          };
        }

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
  } finally {
    if (timeoutHandle !== undefined) clearTimeout(timeoutHandle);
    if (externalSignal) externalSignal.removeEventListener("abort", onExternalAbort);
  }
}