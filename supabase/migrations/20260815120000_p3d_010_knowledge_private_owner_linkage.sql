-- P3D-010 — Private Knowledge explicit SH ownership linkage
-- Owner decision: PRIVATE Knowledge is owned by its SH/user and must be recoverable.
-- Reuse the existing SH ownership model; do not create a parallel ownership system.

ALTER TABLE public.knowledge
  ADD COLUMN IF NOT EXISTS sh_id uuid;

CREATE INDEX IF NOT EXISTS knowledge_private_sh_id_idx
  ON public.knowledge (sh_id)
  WHERE scope = 'PRIVATE';

ALTER TABLE public.knowledge
  DROP CONSTRAINT IF EXISTS knowledge_private_sh_id_required;

ALTER TABLE public.knowledge
  ADD CONSTRAINT knowledge_private_sh_id_required
  CHECK (scope <> 'PRIVATE' OR sh_id IS NOT NULL);

ALTER TABLE public.knowledge
  DROP CONSTRAINT IF EXISTS knowledge_private_sh_id_fk;

ALTER TABLE public.knowledge
  ADD CONSTRAINT knowledge_private_sh_id_fk
  FOREIGN KEY (sh_id)
  REFERENCES public.sh_instances(sh_id)
  NOT VALID;

CREATE POLICY knowledge_private_owner_select
ON public.knowledge
FOR SELECT
TO authenticated
USING (
  scope = 'PRIVATE'
  AND sh_id IN (
    SELECT si.sh_id
    FROM public.sh_instances AS si
    WHERE si.account_id = auth.uid()
  )
);
