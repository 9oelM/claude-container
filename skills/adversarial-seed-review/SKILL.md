---
name: adversarial-seed-review
description: "Two independent adversarial reviews of an Ouroboros seed YAML to find gaps, contradictions, and implementation blockers before execution"
---

# /adversarial-seed-review

Run two independent adversarial reviews against an Ouroboros seed specification. Each reviewer tries to find issues the other would miss.

## Usage

```
/adversarial-seed-review [seed_file]
```

If no file specified, look for `seed.yaml` or `seed-*.yaml` in the working directory.

## Instructions

### Step 1: Read the seed

Read the seed YAML file completely. Identify:
- The goal
- All acceptance criteria
- All constraints
- Brownfield context references
- Ontology schema

### Step 2: Launch two independent adversarial reviewers in PARALLEL

Use the Agent tool to launch **two agents simultaneously** (single message, two tool calls). Each agent gets a different review focus. They must NOT see each other's results.

**Agent 1: Codebase Verification Reviewer**

Prompt the agent with:
```
You are a hostile code reviewer. Read [seed file]. Then verify EVERY claim against the actual codebase:

1. Every file path in brownfield_context — does it exist? Read each one.
2. Every function/method/type referenced — does it exist with the claimed signature?
3. Every DB column referenced — check the actual migration SQL.
4. Every import path — can it actually be resolved? Any bundling issues?
5. Every "existing pattern" claimed — verify it's really there.
6. Any acceptance criteria that's impossible given the current architecture.
7. Field name mismatches (snake_case vs camelCase, number vs boolean, etc.)
8. Missing dependencies that would need to be installed.

For EACH issue: classify as BLOCKER / WARNING / NITPICK.
If everything checks out, say "CLEAN".
```

**Agent 2: Architecture & Edge Case Reviewer**

Prompt the agent with:
```
You are a senior architect trying to break the spec. Read [seed file]. Find:

1. Contradictions between acceptance criteria (one AC says X, another implies not-X).
2. Race conditions or state management gaps (URL state vs component state vs server state).
3. Security vulnerabilities (XSS from untrusted HTML, injection, CSRF, etc.).
4. Performance traps (N+1 queries, re-fetching large payloads, blocking renders).
5. Edge cases not covered (empty states, error states, expired/deleted data, concurrent users).
6. Missing implementation details that would force the implementer to guess.
7. Accessibility gaps (focus management, screen readers, keyboard navigation).
8. Mobile vs desktop behavioral contradictions.
9. Browser history / URL lifecycle issues (pushState vs replaceState vs goto, back button traps).
10. Data flow gaps (where does data come from at each step? Any missing transformations?).

For EACH issue: classify as BLOCKER / WARNING / NITPICK.
If everything checks out, say "CLEAN".
```

### Step 3: Merge and deduplicate findings

After both agents complete:

1. Collect all findings from both reviewers
2. Deduplicate (same issue found by both = higher confidence)
3. Sort by severity: BLOCKER > WARNING > NITPICK
4. Present a unified table:

```
## Adversarial Seed Review Results

### Seed: [filename]

| # | Issue | Severity | Found by | Description |
|---|-------|----------|----------|-------------|
| 1 | XSS in description_html | BLOCKER | Both | ... |
| 2 | pushState back-button trap | BLOCKER | Arch | ... |
| ...

### Summary
- X BLOCKER(s) — must fix before execution
- Y WARNING(s) — should fix, may cause rework
- Z NITPICK(s) — minor, can fix during implementation

### Verdict
- READY: 0 blockers → "Seed is ready for execution"
- NOT READY: 1+ blockers → "Fix N blockers before running"
```

### Step 4: Offer to fix

If blockers are found, ask:
```
Want me to fix the N blockers in the seed?
```

If the user says yes, apply fixes directly to the seed file and re-run Step 2 to verify the fixes didn't introduce new issues. Maximum 2 fix-and-recheck cycles.

## Design Principles

- **Independence**: The two reviewers must run in parallel with no shared context. This prevents groupthink and ensures diverse failure modes are explored.
- **Codebase-grounded**: Reviewer 1 checks every claim against actual files. No taking the seed's word for it.
- **Adversarial**: Reviewers are trying to BREAK the spec, not validate it. They assume the spec is wrong until proven otherwise.
- **Actionable**: Every finding has a severity and enough detail to fix it.
- **No false confidence**: "CLEAN" from both reviewers means the spec survived two independent hostile reviews — not that it's perfect.
