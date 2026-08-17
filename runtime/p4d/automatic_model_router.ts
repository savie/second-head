import { createModelExecutor, type ModelAdapter, type ModelResponse } from './model_abstraction.ts';
import { selectModel, type ModelCandidate, type ModelTask } from './model_selection.ts';
import { createGroqAdapter } from './groq_free_adapter.ts';
import { createHuggingFaceAdapter } from './huggingface_free_adapter.ts';
import { createOpenRouterFreeAdapter } from './openrouter_free_adapter.ts';

export type RoutedModelResponse = ModelResponse & Readonly<{
  model_id: string;
  provider: string;
  cost_tier: 'ZERO_BUDGET' | 'PAID';
  task: ModelTask;
}>;

export function inferModelTask(userMessage: string): ModelTask {
  const text = userMessage.toLowerCase();
  if (/\b(draw|image|gambar|generate (an )?image|buat gambar|ilustrasi|foto)\b/.test(text)) return 'image';
  if (/\b(analy[sz]e|reason|reasoning|deep dive|compare|bandingkan|jelaskan mendalam|debug|architecture|arsitektur)\b/.test(text)) return 'reasoning';
  return 'conversation';
}

function candidates(): ModelCandidate[] {
  return [
    {
      id: 'openrouter/free',
      capability: 'text',
      cost_tier: 'ZERO_BUDGET',
      adapter: createOpenRouterFreeAdapter(),
      tasks: ['semantic', 'conversation', 'reasoning'],
      priority: 0,
    },
    {
      id: 'groq/openai/gpt-oss-20b',
      capability: 'text',
      cost_tier: 'ZERO_BUDGET',
      adapter: createGroqAdapter(),
      tasks: ['conversation', 'reasoning'],
      priority: 1,
    },
    {
      id: 'huggingface/meta-llama/Llama-3.1-8B-Instruct',
      capability: 'text',
      cost_tier: 'ZERO_BUDGET',
      adapter: createHuggingFaceAdapter(),
      tasks: ['semantic', 'conversation'],
      priority: 2,
    },
  ];
}

/**
 * Automatically routes by task and falls back through other eligible
 * zero-budget candidates when a provider is unavailable or fails.
 */
export async function executeAutomatically(
  request: Parameters<ReturnType<typeof createModelExecutor>['execute']>[0],
  task: ModelTask,
): Promise<RoutedModelResponse> {
  const remaining = candidates();
  const failures: string[] = [];

  while (remaining.length > 0) {
    let selected: ReturnType<typeof selectModel>;
    try {
      selected = selectModel(remaining, {
        capability: request.capability,
        task,
        require_zero_budget: true,
      });
    } catch (error) {
      throw new Error(error instanceof Error ? error.message : 'MODEL_SELECTION_FAILED');
    }

    try {
      const response = await createModelExecutor(selected.adapter).execute(request);
      const provider = selected.model_id.split('/')[0];
      return {
        ...response,
        model_id: selected.model_id,
        provider,
        cost_tier: selected.cost_tier,
        task,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'MODEL_PROVIDER_FAILED';
      failures.push(`${selected.model_id}: ${message}`);
      const index = remaining.findIndex((candidate) => candidate.id === selected.model_id);
      if (index >= 0) remaining.splice(index, 1);
    }
  }

  throw new Error(`MODEL_EXECUTION_FAILED_ALL_ZERO_BUDGET: ${failures.join(' | ')}`);
}
