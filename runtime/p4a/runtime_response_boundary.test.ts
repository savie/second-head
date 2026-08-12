import { finalizeRuntimeResponse } from "./runtime_response_boundary";

const result = finalizeRuntimeResponse({
  request_id: "req-p4a-009",
  sh_id: "sh-test",
  response: { text: "ok" },
});

if (!result.ok || result.request_id !== "req-p4a-009" || result.sh_id !== "sh-test") {
  throw new Error("P4A-009 response boundary failed");
}

let rejected = false;
try {
  finalizeRuntimeResponse({ request_id: "", sh_id: "sh-test", response: null });
} catch {
  rejected = true;
}

if (!rejected) {
  throw new Error("P4A-009 must reject missing request identity");
}
