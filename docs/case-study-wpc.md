# Case Study: WPC Permit Case Engine

Built entirely with Kleiber agent orchestration — harness engineering in production.

## The Platform

A B2B compliance engine for digitizing Belgian Single Permit applications. Construction companies onboard employers, upload 8 critical documents, and track worker clearance through a traffic light dashboard.

## The Harness in Action

This project demonstrates all six pillars of harness engineering through Kleiber:

| Pillar | WPC Implementation |
|--------|--------------------|
| Tool integration | KBO API, Cloud Vision OCR, Firestore, Firebase Auth |
| Memory and state | Scribe maintained ERD docs, API reference, permission matrix across sessions |
| Context curation | Opus for ERD/RBAC design, Sonnet for portal + API, Haiku for validation |
| Planning and decomposition | Architect decomposed PRD into 12 tasks across 4 agents |
| Verification and guardrails | Validator caught 3 permission leaks; Hard Gate enforced server-side |
| Modularity | Each agent scoped to its domain — no cross-contamination |

## What Kleiber Built

### ERD & Data Model (Architect → Opus)
- 7 canonical Firestore collections mapped from the regulatory ERD
- Relationship rules enforcing referential integrity across employers, workers, employment records, and permit cases
- Hard Gate constraint: case cannot be submitted to DVZ unless all 8 documents are VERIFIED and payment is PAID

### Employer Portal (Engineer-Frontend → Sonnet)
- KBO/CBE auto-lookup: employer enters VAT number, system fetches company data from Belgian business register
- Drag-and-drop document upload hub with file type validation
- Traffic light dashboard: GREEN (verified), ORANGE (expiring/pending), RED (blocked with reason code)
- Role-aware UI rendering different actions per user type

### Compliance Backend (Engineer-Backend → Sonnet)
- Document Rules Engine with OCR-assisted validation (keyword detection, expiry checks, file type enforcement)
- Firestore security rules enforcing RBAC at the database level
- Audit logging middleware: every mutation records actor, role, timestamp, resource, before/after state
- Hard Gate enforced server-side — architectural constraint, not a UI checkbox

### Quality Verification (Validator → Haiku)
- Type checks after every edit
- RBAC boundary tests for all 8 roles
- Caught 3 permission leaks where Employer Users could access Worker passport data
- All fixed at the security rule level before production

### Documentation (Scribe → Haiku)
- `docs/erd-source-of-truth.md`
- `docs/api-reference.md`
- `docs/role-permission-matrix.md`
- Deployment runbook

## PRIOR FIRE WIN Results

| Phase | Count | Detail |
|-------|-------|--------|
| PRIOR | All components | Risk-classified before development. EU AI Act tier assessed for OCR. GDPR data categories mapped. |
| FIRE | 3 events | Permission leaks caught by Validator. Suspended, evidence preserved, routed to Architect. Fixed at security rule level. |
| WIN | 12 tasks | All quality gates passed. Every component attributable, auditable, reversible. |

## RBAC Model

| Role | Visibility |
|------|------------|
| WPC Super Admin | All settings, billing, users, cases, documents, audit evidence |
| WPC Case Manager | Assigned cases, documents, actions, SLA, compliance evidence |
| WPC Intake Admin | Intake, employer basics, worker basics, document gaps |
| Employer Admin | Own company, own cases, own upload tasks, allowed status views |
| Employer User | Only assigned employer tasks, requested documents, limited status |
| Worker | Own documents, signatures, personal details only |
| Finance | Invoices, billing status, payment windows, payment tasks |
| Read-only Auditor | Audit trail, case history, compliance evidence only |

## Deployment

- Frontend: Vercel
- Backend: Firebase (Firestore + Cloud Functions)
- OCR: Cloud Vision API
- Auth: Firebase Auth with custom claims for RBAC

## DevGap Takeaway

One developer ran `/kleiber` with the PRD. The harness handled role assignment, model routing, quality gates, and governance. The developer reviewed Architect designs, approved FIRE resolutions, and shipped. That's harness engineering.
