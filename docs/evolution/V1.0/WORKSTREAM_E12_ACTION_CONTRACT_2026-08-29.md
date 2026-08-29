# WORKSTREAM E12 — ACTION CONTRACT
**Status:** BOUNDED DESIGN / NOT IMPLEMENTATION-AUTHORIZED

## Purpose
Freeze the semantic contract of a concrete Action independently of Tool class.

## Minimum semantics
Action identity, Tool identity, Capability relation, operation/effect, input constraints, target/context, expected side-effect class, risk classification, authorization requirements, confirmation requirement, execution/result correlation.

## Rule
Tool-level permission must never imply blanket permission for every Action.

## Action categories
Read, write/state-changing, external-side-effect, and other categories may be introduced when evidence requires them. No universal taxonomy is forced prematurely.

## Boundary
Action definition describes an operation; it does not authorize it.

**Next:** E13 — Authorization/Authority Binding.