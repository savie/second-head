# SECOND HEAD — Future Concept: Inter-SH Communication

**Status:** REFERENCE / FUTURE CONCEPT  
**Authority:** Non-Canonical  
**Branch:** dev_old  
**Purpose:** Capture an architectural idea discovered during frontend development. This document does not change Canon, implementation scope, or current product behavior.

---

## 1. Concept

SECOND HEAD (SH) is currently designed around a single-user model: a user has their own SH and its accumulated Journey, Memory, Knowledge, and Experience.

A future direction could extend Conversation into communication between **SH accounts**, where a user does not necessarily communicate directly with another human in real time. Instead, the communicating endpoint can be the other person's SH.

Conceptually:

```
USER A
  ↓
SH A  ↔  SH B
            ↑
          USER B
```

The important distinction is that the responding entity is **SH B**, not a human pretending to respond.

---

## 2. Relationship Model

A future SH network could treat a relationship as a relationship between SH accounts.

Potential flow:

```
SH A
  ↓
Relationship request
  ↓
SH B
  ↓
Accept / Reject
  ↓
Authorized relationship
  ↓
SH A ↔ SH B
```

This aligns conceptually with the direction already explored for **Integrations**:

- Pending
  - Accept / Reject
  - Waiting for approval
- Authorized
  - Connected
  - Revoke

This document does not redefine the current Integrations implementation. It records a possible future use of that authorization layer.

---

## 3. SH as the Communication Endpoint

If SH B has sufficient persistent information accumulated through:

- Journey
- Memory
- Knowledge
- Experience

then SH B could potentially participate in a conversation with SH A.

The future experience could therefore resemble a communication application while retaining a fundamental SH distinction:

```
Traditional communication

USER A ↔ USER B

Potential SH communication

USER A ↔ SH B
```

The latter should remain explicitly identifiable as communication with **SH B**.

This concept must not be interpreted as SH impersonating USER B.

---

## 4. Authorization and Access Boundaries

A relationship between SH accounts must **not** imply unrestricted access to the other SH.

For example:

```
SH B
├── Private
├── Authorized / relationship-specific
├── Public
└── Other policy-controlled content
```

The exact visibility and access combinations are intentionally undefined here.

The existing concept of **Policy** remains the natural place to govern access to individual objects/content. A future inter-SH relationship should therefore not bypass or replace object-level policy.

---

## 5. Connection to Existing SH Concepts

This future direction gives additional potential meaning to several areas:

### Conversation
Could evolve from conversation with one's own SH into communication involving another SH.

### Integrations
Could become an authorization/approval gateway for SH-to-SH relationships.

### Policy
Could determine what another SH is permitted to access or use.

### Journey / Memory / Knowledge / Experience
Could provide the persistent context from which an SH operates.

### Inheritance / Succession / Legacy
Could eventually create additional relationship types between SH accounts.

These connections are conceptual only. They do not establish new Canon or implementation requirements.

---

## 6. Offline Possibility

A particularly interesting future property is that the human owner of SH B does not necessarily need to be actively online for SH B to participate.

Conceptually:

```
USER B offline
      ↓
SH B remains available
      ↓
SH A ↔ SH B
```

Whether this should be allowed, under what permissions, and with what limitations is intentionally unresolved.

---

## 7. What This Is Not

This concept does **not** currently define:

- a social network;
- a friend/contact system;
- a public SH directory;
- automatic access to another user's Journey;
- automatic access to another user's Memory, Knowledge, or Experience;
- impersonation of a human user;
- a new database schema;
- a new Supabase migration;
- a current Conversation backend requirement;
- a change to the current single-user implementation.

---

## 8. Current Status

**Do not implement from this document.**

This is a future-reference document intended to prevent the current frontend architecture from accidentally assuming that SH will always remain strictly single-user.

If the concept is later adopted, it should first be converted into explicit architecture, authorization, data, privacy, policy, and lifecycle decisions before implementation.

---

## 9. Core Idea

> **Future SH communication may be communication between SH accounts, where each SH can represent and operate from the persistent context accumulated by its owner, subject to explicit authorization and policy boundaries.**

This is a new concept captured for future exploration, not Canon.
