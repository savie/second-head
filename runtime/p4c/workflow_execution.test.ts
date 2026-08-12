import { executeWorkflow } from "./workflow_execution";

describe("P4C-002 workflow execution", () => {
  it("executes a finite workflow and records step/completion events", async () => {
    const result = await executeWorkflow(
      "wf-001",
      [
        { id: "step-1", run: async () => "first" },
        { id: "step-2", run: async () => "second" },
      ],
      () => "2026-08-12T00:00:00.000Z",
    );

    expect(result.status).toBe("COMPLETED");
    expect(result.completedSteps).toEqual(["step-1", "step-2"]);
    expect(result.events.map((event) => event.type)).toEqual([
      "WORKFLOW_STARTED",
      "STEP_COMPLETED",
      "STEP_COMPLETED",
      "WORKFLOW_COMPLETED",
    ]);
  });

  it("fails at the first failing step and does not continue silently", async () => {
    const executed: string[] = [];
    const result = await executeWorkflow("wf-002", [
      {
        id: "step-1",
        run: async () => {
          executed.push("step-1");
          return "ok";
        },
      },
      {
        id: "step-2",
        run: async () => {
          executed.push("step-2");
          throw new Error("step failure");
        },
      },
      {
        id: "step-3",
        run: async () => {
          executed.push("step-3");
          return "must-not-run";
        },
      },
    ]);

    expect(result.status).toBe("FAILED");
    expect(result.failedStep).toBe("step-2");
    expect(result.completedSteps).toEqual(["step-1"]);
    expect(executed).toEqual(["step-1", "step-2"]);
    expect(result.error).toBe("step failure");
  });
});
