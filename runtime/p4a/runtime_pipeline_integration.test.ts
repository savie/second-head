import { composeRuntimePipeline } from "./runtime_pipeline_integration";

describe("P4A-008 runtime pipeline integration", () => {
  it("composes identity, context and model stages without changing SH identity", () => {
    const result = composeRuntimePipeline({
      request_id: "req-1",
      sh_id: "sh-000",
      identity: { sh_id: "sh-000" },
      context: { items: [] },
      model: { provider: "mock" },
      response: "ok",
    });

    expect(result.ok).toBe(true);
    expect(result.sh_id).toBe("sh-000");
    expect(result.response).toBe("ok");
    expect(result.stages.map((s) => s.stage)).toEqual(["IDENTITY", "CONTEXT", "MODEL"]);
  });

  it("fails closed when a required stage is missing", () => {
    const result = composeRuntimePipeline({
      request_id: "req-2",
      sh_id: "sh-000",
      identity: { sh_id: "sh-000" },
      context: { items: [] },
      model: undefined,
      response: "should-not-escape",
    });

    expect(result.ok).toBe(false);
    expect(result.response).toBeUndefined();
    expect(result.failure_stage).toBe("MODEL");
  });
});
