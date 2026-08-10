-- BL-P1-002 — Account & SH Identity Schema
-- Source of truth: Git repository migration artifact.
-- Scope: identity schema only. No RLS, auth trigger, identity service, or governance engine.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE public.accounts (
  account_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL,
  status text NOT NULL DEFAULT 'created',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX accounts_email_lower_unique
  ON public.accounts (lower(email));

CREATE TABLE public.sh_instances (
  sh_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES public.accounts(account_id),
  sh_type text NOT NULL DEFAULT 'PRIMARY',
  is_primary boolean NOT NULL DEFAULT true,
  canonical_name text,
  creator_ref text,
  status text NOT NULL DEFAULT 'created',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  version integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sh_instances_account_sh_pair_unique UNIQUE (sh_id, account_id)
);

CREATE UNIQUE INDEX sh_instances_one_primary_per_account
  ON public.sh_instances (account_id)
  WHERE is_primary = true;

CREATE TABLE public.sh_ownership (
  ownership_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  sh_id uuid NOT NULL,
  role text NOT NULL DEFAULT 'OWNER',
  granted_at timestamptz NOT NULL DEFAULT now(),
  evidence_ref text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sh_ownership_account_sh_fk
    FOREIGN KEY (sh_id, account_id)
    REFERENCES public.sh_instances (sh_id, account_id),
  CONSTRAINT sh_ownership_one_role_per_sh UNIQUE (sh_id, role)
);

CREATE TABLE public.account_auth_links (
  link_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES public.accounts(account_id),
  provider text NOT NULL,
  subject_ref text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT account_auth_links_provider_subject_unique
    UNIQUE (provider, subject_ref)
);

COMMENT ON TABLE public.accounts IS 'ACCOUNT_ID identity anchor; Account is distinct from SH identity.';
COMMENT ON TABLE public.sh_instances IS 'Persistent SH_ID identity anchor; not equivalent to model, runtime, database row, hardware, memory, or session.';
COMMENT ON TABLE public.sh_ownership IS 'Explicit, auditable ownership relationship; ownership is distinct from evolution/continuity.';
COMMENT ON TABLE public.account_auth_links IS 'Links platform authentication subjects to ACCOUNT_ID; population/creation flow is BL-P1-003.';
