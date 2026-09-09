import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BUCKET = "second-head-conversation";
const PAGE_SIZE = 1000;
const DELETE_BATCH_SIZE = 1000;

function legacyServiceRole(authHeader: string | null): boolean {
  if (!authHeader?.startsWith("Bearer ")) return false;
  const parts = authHeader.slice(7).split(".");
  if (parts.length !== 3) return false;
  try {
    const payload = JSON.parse(atob(parts[1].replace(/-/g, "+").replace(/_/g, "/")));
    return payload?.role === "service_role";
  } catch (_) {
    return false;
  }
}

function configuredSecretKeys(): string[] {
  const raw = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    return Object.values(parsed).filter((value): value is string => typeof value === "string");
  } catch (_) {
    return [];
  }
}

function isServiceWorker(req: Request): boolean {
  const apiKey = req.headers.get("apikey");
  return legacyServiceRole(req.headers.get("Authorization")) || (!!apiKey && configuredSecretKeys().includes(apiKey));
}

function unauthorized() {
  return new Response(JSON.stringify({ error: "CONVERSATION_ATTACHMENT_RECONCILIATION_UNAUTHORIZED" }), { status: 401, headers: { "Content-Type": "application/json" } });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "METHOD_NOT_ALLOWED" }), { status: 405, headers: { "Content-Type": "application/json" } });
  if (!isServiceWorker(req)) return unauthorized();

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? (() => {
    const raw = Deno.env.get("SUPABASE_SECRET_KEYS");
    if (!raw) return null;
    try {
      const keys = JSON.parse(raw) as Record<string, string>;
      return keys.default ?? Object.values(keys)[0] ?? null;
    } catch (_) {
      return null;
    }
  })();
  if (!supabaseUrl || !serviceKey) return new Response(JSON.stringify({ error: "RUNTIME_CONFIGURATION_ERROR" }), { status: 500, headers: { "Content-Type": "application/json" } });

  const admin = createClient(supabaseUrl, serviceKey);
  const objectRefs: string[] = [];
  for (let offset = 0; ; offset += PAGE_SIZE) {
    const { data, error } = await admin.storage.from(BUCKET).list("", { limit: PAGE_SIZE, offset, sortBy: { column: "name", order: "asc" } });
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: { "Content-Type": "application/json" } });
    for (const item of data ?? []) if (item.id !== null && item.name) objectRefs.push(item.name);
    if ((data ?? []).length < PAGE_SIZE) break;
  }

  const orphanRefs: string[] = [];
  const retryableWithObject: string[] = [];
  const referenced: string[] = [];
  for (let i = 0; i < objectRefs.length; i += 500) {
    const refs = objectRefs.slice(i, i + 500);
    const { data, error } = await admin.rpc("runtime_reconcile_conversation_attachment_storage_refs_internal", { p_storage_refs: refs });
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: { "Content-Type": "application/json" } });
    for (const row of data ?? []) {
      if (row.disposition === "ORPHAN_OBJECT") orphanRefs.push(row.storage_ref);
      else if (row.disposition === "RETRYABLE_ATTACHMENT_RESOURCE") retryableWithObject.push(row.storage_ref);
      else referenced.push(row.storage_ref);
    }
  }

  const { data: resources, error: resourceError } = await admin.from("conversation_attachments").select("attachment_id,storage_ref,status,message_id");
  if (resourceError) return new Response(JSON.stringify({ error: resourceError.message }), { status: 500, headers: { "Content-Type": "application/json" } });

  const objectRefSet = new Set(objectRefs);
  const retryableWithoutObject: string[] = [];
  const missingPersistedObject: string[] = [];
  for (const resource of resources ?? []) {
    if ((resource.status === "PENDING" || resource.status === "FAILED") && !objectRefSet.has(resource.storage_ref)) retryableWithoutObject.push(resource.storage_ref);
    if (resource.status === "PERSISTED" && !objectRefSet.has(resource.storage_ref)) missingPersistedObject.push(resource.storage_ref);
  }

  const deleted: string[] = [];
  const deleteErrors: Array<{ storage_ref: string; error: string }> = [];
  for (let i = 0; i < orphanRefs.length; i += DELETE_BATCH_SIZE) {
    const batch = orphanRefs.slice(i, i + DELETE_BATCH_SIZE);
    const { data, error } = await admin.storage.from(BUCKET).remove(batch);
    if (error) {
      for (const storageRef of batch) deleteErrors.push({ storage_ref: storageRef, error: error.message });
      continue;
    }
    for (const item of data ?? []) if (item.name) deleted.push(item.name);
  }

  return new Response(JSON.stringify({ ok: deleteErrors.length === 0, bucket: BUCKET, scanned_objects: objectRefs.length, orphan_objects_found: orphanRefs.length, orphan_objects_deleted: deleted.length, retryable_with_object: retryableWithObject.length, retryable_without_object: retryableWithoutObject.length, persisted_missing_object: missingPersistedObject.length, referenced_or_retained: referenced.length, delete_errors: deleteErrors }), { status: deleteErrors.length === 0 ? 200 : 500, headers: { "Content-Type": "application/json" } });
});
