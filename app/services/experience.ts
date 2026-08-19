import { supabase } from './supabase';

export type Experience = {
  experience_id: string;
  sh_id: string;
  account_id: string;
  experience_type: string;
  content: string;
  scope: string;
  visibility: string;
  source_ref: string | null;
  provenance: Record<string, unknown>;
  lifecycle: string;
  occurred_at: string;
  created_at: string;
  updated_at: string;
};

export async function listExperiences(limit = 50): Promise<Experience[]> {
  const { data, error } = await supabase.rpc('list_experiences', {
    p_sh_id: null,
    p_limit: limit,
  });
  if (error) throw new Error(`EXPERIENCE_RETRIEVAL_FAILED: ${error.message}`);
  return (data ?? []) as Experience[];
}

export async function getExperience(experienceId: string): Promise<Experience> {
  const { data, error } = await supabase.rpc('get_experience', {
    p_experience_id: experienceId,
  });
  if (error) throw new Error(`EXPERIENCE_RETRIEVAL_FAILED: ${error.message}`);
  if (!data || typeof data !== 'object') throw new Error('EXPERIENCE_RETRIEVAL_FAILED: empty result');
  return data as Experience;
}
