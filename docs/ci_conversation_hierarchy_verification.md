# Conversation Hierarchy — CI Verification

CI verification target for the current DEV integration:

- Project is an optional grouping layer above Conversation in the sidebar.
- Conversation is a chat container.
- Message is the persisted chat unit.
- Conversation may remain standalone without a Project.
- Journey receives Message selectively; Conversation is not automatically promoted to Journey.
- Local conversation persistence remains in place.
- Lifecycle policy is unchanged.
