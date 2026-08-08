# SECOND HEAD (SH)

**Status:** Phase 0 — Infrastructure & Development Foundation  
**Repository:** [github.com/savie/second-head](https://github.com/savie/second-head)

## Project Overview
SECOND HEAD (SH) is a persistent personal intelligence system. This repository contains the source code, infrastructure configurations, and technical artifacts required to build, operate, and evolve the SH system.

## Branching Strategy
- **`dev`**: The primary branch for active development, feature integration, and ongoing sprints. All new work, vertical slices, and Phase executions are merged here.
- **`main`**: The stable, final release branch. Represents production-ready, validated, or officially frozen milestones.

*Note: "local" refers strictly to the physical working environment on the developer's device and is not a Git branch.*

## Terminology & Naming Conventions
- The system is universally referred to as **SH** or **Second Head**.
- **Version Control as History**: Git is the single source of truth for all historical changes, revisions, and iterations. Files in this repository **do not** use manual revision suffixes (e.g., `filename_rev1.md`, `filename_v2.md`). Versioning and history are handled entirely through Git commits, tags, and branches.
- **Documentation Authority**: All working documentation, implementation artifacts, and code structures strictly follow the locked Canonical, Frozen Baseline, and Build Scope authorities. 

## Phase 0 Scope
Current focus: Infrastructure & Development Foundation.
- Supabase project configuration, RLS foundation, and audit tables.
- CI/CD pipeline, testing framework, and repository standards.
- Environment configuration, linting, and shared types.

## Constraints & Environment
- **Mobile-First Workflow**: Development, testing, and deployment workflows are optimized for mobile-first execution (e.g., via Termux), with remote/desktop environments used as supplementary tools when necessary.
- **Zero Budget / Zero Hardware**: Core infrastructure relies on free-tier, vendor-agnostic services (e.g., Supabase, GitHub Actions, Groq) without mandatory paid dependencies or hardware purchases.