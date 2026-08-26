import { hasExplicitMemoryOptOut } from "./semantic_lifecycle.ts";

Deno.test("memory opt-out detects Indonesian explicit denial", () => {
  if (!hasExplicitMemoryOptOut("Saya tidak meminta kamu menyimpan kode ini sebagai Memory. Apa kode tadi?")) {
    throw new Error("Indonesian memory opt-out was not detected");
  }
});

Deno.test("memory opt-out detects English explicit denial", () => {
  if (!hasExplicitMemoryOptOut("I don't want you to save this as Memory.")) {
    throw new Error("English memory opt-out was not detected");
  }
});

Deno.test("ordinary memory request is not treated as opt-out", () => {
  if (hasExplicitMemoryOptOut("Tolong simpan bahwa saya suka jawaban singkat sebagai Memory.")) {
    throw new Error("ordinary memory request was incorrectly treated as opt-out");
  }
});
