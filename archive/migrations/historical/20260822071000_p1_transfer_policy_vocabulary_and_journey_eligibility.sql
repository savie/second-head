-- Reconcile transfer-policy vocabulary and lifecycle-specific Journey eligibility.
-- Live DEV implementation accepts INHERITABLE only as a compatibility alias and normalizes it to INHERITANCE.
-- Inheritance and Succession Journey selections must match the lifecycle transfer policy.
-- Legacy requires a deactivated/EOL source SH.

-- The authoritative live function definitions are represented by this migration checkpoint:
-- runtime_set_record_policy
-- runtime_transfer_selected_journey_events
-- runtime_validate_selected_transfer_scope
-- runtime_preserve_selected_journey_as_legacy
-- runtime_preserve_selected_transfer_as_legacy

-- No data mass-conversion is performed.
