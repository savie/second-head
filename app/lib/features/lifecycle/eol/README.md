# EOL Frontend

End of Life is implemented as an isolated sub-feature under the Lifecycle domain.

Flow:

`Overview → Impact Review → Confirmation → Execution Boundary → Terminal UI`

The frontend reads existing local Journey, relationship, and Recovery stores for impact review. It does not mutate Supabase during impact preparation, clear application data, delete Recovery snapshots, or reinterpret relationship semantics.

`EolService` delegates terminal execution to the backend lifecycle authority. `LocalEolService.executeFrontendClosure()` calls `runtime_end_of_life_sh`; after successful backend EOL it also terminates the authenticated provider session so the deactivated account cannot remain inside the active app session.

The backend EOL operation deactivates the source SH and account and activates prepared Legacy records. Re-login is blocked at actor-resolution time for deactivated accounts.

This implementation does not establish or change SH Canonical semantics.
