# EOL Frontend

End of Life is implemented as an isolated sub-feature under the Lifecycle domain.

Flow:

`Overview → Impact Review → Confirmation → Execution Boundary → Terminal UI`

The frontend reads existing local Journey, relationship, and Recovery stores for impact review. It does not mutate Supabase, clear application data, delete Recovery snapshots, or reinterpret relationship semantics.

`EolService` is the integration seam for the future backend lifecycle contract. The current `LocalEolService` intentionally completes only the frontend flow.

This implementation does not establish or change SH Canonical semantics.
