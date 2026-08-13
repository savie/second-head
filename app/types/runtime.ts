export type RuntimeInvocationInput = {
  userMessage: string;
  shId?: string;
  conversationId?: string | null;
};

export type RuntimeInvocationResponse = {
  sh_id: string;
  response: string;
  meta: {
    phase: string;
    model_provider: string;
    context_entries: number;
    memory_decision: string;
  };
};
