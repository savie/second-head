export type RuntimeRequest = {
  request_id: string;
  user_message: string;
  auth_uid: string;
};

export type RuntimeRequestAccepted = RuntimeRequest & {
  accepted: true;
};

export type RuntimeRequestRejected = {
  accepted: false;
  code: "INVALID_REQUEST" | "UNAUTHENTICATED" | "MESSAGE_TOO_LARGE";
};

const MAX_MESSAGE_LENGTH = 32_000;

export function validateRuntimeRequest(input: unknown): RuntimeRequestAccepted | RuntimeRequestRejected {
  if (!input || typeof input !== "object") {
    return { accepted: false, code: "INVALID_REQUEST" };
  }

  const value = input as Record<string, unknown>;

  if (typeof value.request_id !== "string" || value.request_id.length === 0) {
    return { accepted: false, code: "INVALID_REQUEST" };
  }

  if (typeof value.auth_uid !== "string" || value.auth_uid.length === 0) {
    return { accepted: false, code: "UNAUTHENTICATED" };
  }

  if (typeof value.user_message !== "string" || value.user_message.trim().length === 0) {
    return { accepted: false, code: "INVALID_REQUEST" };
  }

  if (value.user_message.length > MAX_MESSAGE_LENGTH) {
    return { accepted: false, code: "MESSAGE_TOO_LARGE" };
  }

  return {
    accepted: true,
    request_id: value.request_id,
    user_message: value.user_message,
    auth_uid: value.auth_uid,
  };
}

export { MAX_MESSAGE_LENGTH };
