import {
  orchestrateStages,
  stageFailure,
  stageResult,
} from "./runtime_orchestration_contract.ts";

Deno.test("P4A-007 preserves successful stage order", () => {
  const result = orchestrateStages("req-1", [
    stageResult("IDENTITY", { sh_id: "sh-1" }),
    stageResult("CONTEXT"),
    stageResult("MODEL", { text: "ok" }),
  ], { text: "ok" }, "sh-1");

  if (!result.ok) throw new Error("expected success");
  if (result.failure_stage !== undefined) throw new Error("unexpected failure");
  if (result.stages.map((s) => s.stage).join(",") !== "IDENTITY,CONTEXT,MODEL") {
    throw new Error("stage order changed");
  }
  if (result.sh_id !== "sh-1") throw new Error("SH identity changed");
});

Deno.test("P4A-007 fails closed on the first failed stage", () => {
  const result = orchestrateStages("req-2", [
    stageResult("IDENTITY", { sh_id: "sh-1" }),
    stageFailure("CONTEXT", "CONTEXT_FAILURE"),
    stageResult("MODEL", { text: "must-not-be-used" }),
  ], { text: "must-not-be-used" }, "sh-1");

  if (result.ok) throw new Error("expected failure");
  if (result.failure_stage !== "CONTEXT") throw new Error("wrong failure stage");
  if (result.response !== undefined) throw new Error("response leaked after failure");
});
