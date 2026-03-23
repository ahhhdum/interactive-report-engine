# SQL Component Patterns Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reference example and skill guidance for SQL-centric interactive reports with annotatable queries, literate explanations, and strategy comparison.

**Architecture:** The example (`examples/sql-query-review.html`) copies the engine's CSS+JS and adds inline SQL-specific CSS. No engine template changes. A skill reference doc (`~/.claude/skills/action-report/references/sql-component-patterns.md`) provides guidance following the layered freedom model. The DRLA price-reject joins scenario provides real domain content.

**Tech Stack:** HTML, CSS, JS (all inline, zero dependencies). Engine template patterns for state management and feedback export.

**Spec:** `docs/superpowers/specs/2026-03-22-sql-component-patterns-design.md`

**Source material:** `~/.agent/diagrams/drla-price-reject-joins.html` (the original static explainer to rebuild with interactive patterns)

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `examples/sql-query-review.html` | Create | Reference example: DRLA scenario with all 5 SQL patterns |
| `~/.claude/skills/action-report/references/sql-component-patterns.md` | Create | Skill reference: structural contracts, component patterns, composition guidance |
| `~/.claude/skills/action-report/SKILL.md` | Modify | Add row to domain reference table for sql-component-patterns.md |
| `docs/pattern-guide.md` | Modify | Add SQL component patterns to the "Variants Beyond the Engine Template" section |
| `CLAUDE.md` | Modify | Add the new example to the repo structure listing |

---

### Task 1: Scaffold the Example HTML File

**Files:**
- Create: `examples/sql-query-review.html`
- Reference: `interactive-report-engine.html` (copy CSS+JS zones)
- Reference: `~/.agent/diagrams/drla-price-reject-joins.html` (domain content)

This task creates the HTML file with all engine CSS+JS copied in, plus the SQL-specific inline CSS additions, plus the hero section and body attributes. The content zones are empty placeholder comments at this stage.

- [ ] **Step 1: Copy the engine template**

Copy `interactive-report-engine.html` to `examples/sql-query-review.html`.

- [ ] **Step 2: Set body attributes and hero content**

Set these body attributes:
```html
<body data-annotatable data-report-title="DRLA Price Reject Join Review" data-report-date="2026-03-22">
```

Fill in the hero section:
```html
<div class="hero-eyebrow">SQL Query Review</div>
<h1>Price Reject Joins: How Revenue Flows</h1>
<div class="hero-sub">Understanding campaign attribution in DOIS for Dynamic RLA training data.</div>
<div class="hero-meta">DRLA Pipeline | 4 Tables | 3 Join Strategies | Interactive</div>
```

- [ ] **Step 3: Add SQL-specific inline CSS**

Add after the engine CSS block (before `</style>`). These are the five pattern CSS classes from the spec:

```css
/* === SQL-specific custom properties (add to :root block) === */
/* Dark mode (append to existing :root): --purple: #c084fc; --purple-dim: rgba(192,132,252,0.1); */
/* Light mode (append to existing light :root): --purple: #9333ea; --purple-dim: rgba(147,51,234,0.08); */

/* === SQL Component Patterns === */

/* Pattern 1: Annotatable SQL Blocks */
.sql-block { background: var(--bg-subtle); border: 1px solid var(--border); border-radius: 8px; padding: 1rem 1.25rem; margin: 0.75rem 0; font-family: var(--font-mono); font-size: 0.8rem; line-height: 1.7; overflow-x: auto; }
.sql-clause { display: block; padding: 0.3rem 0.5rem; border-radius: 4px; border-left: 3px solid transparent; cursor: pointer; transition: all 0.15s; }
.sql-clause:hover { background: var(--accent-dim); border-left-color: var(--accent); }
.sql-kw { color: var(--blue); font-weight: 600; }
.sql-str { color: var(--green); }
.sql-fn { color: var(--purple); }
.sql-tbl { color: var(--amber); }
.sql-comment { color: var(--text-dim); font-style: italic; }

/* Pattern 2: Literate SQL Sections */
.lit-section { display: grid; grid-template-columns: 1fr 1fr; gap: 0; margin: 0.5rem 0; border-radius: 8px; overflow: hidden; border: 1px solid var(--border); }
.lit-prose { padding: 1rem 1.25rem; font-size: 0.88rem; background: var(--surface); line-height: 1.6; }
.lit-code { padding: 1rem 1.25rem; font-family: var(--font-mono); font-size: 0.8rem; background: var(--bg-subtle); line-height: 1.7; overflow-x: auto; }
.step-num { display: inline-flex; align-items: center; justify-content: center; width: 1.5rem; height: 1.5rem; background: var(--accent-dim); color: var(--accent); border-radius: 50%; font-size: 0.72rem; font-weight: 700; margin-right: 0.5rem; font-family: var(--font-mono); }
@media (max-width: 768px) { .lit-section { grid-template-columns: 1fr; } }

/* Pattern 3: Query Comparison (diff highlighting) */
.diff-add { background: var(--green-dim); }
.diff-del { background: var(--red-dim); text-decoration: line-through; opacity: 0.6; }
.diff-same { opacity: 0.5; }

/* Pattern 4: Data Flow Diagram */
.dag-container { display: flex; flex-direction: column; align-items: center; gap: 0.4rem; padding: 1.25rem; background: var(--surface); border: 1px solid var(--border); border-radius: 10px; margin: 1rem 0; }
.dag-row { display: flex; gap: 1rem; align-items: center; justify-content: center; flex-wrap: wrap; }
.dag-node { padding: 0.5rem 1rem; border-radius: 8px; font-family: var(--font-mono); font-size: 0.8rem; text-align: center; min-width: 120px; cursor: pointer; transition: all 0.15s; border: 1px solid var(--border); background: var(--blue-dim); color: var(--text); }
.dag-node:hover { border-color: var(--accent); }
.dag-node.cte { background: var(--amber-dim); }
.dag-node.output { background: var(--green-dim); }
.dag-arrow { color: var(--text-dim); font-size: 1rem; }
.dag-edge-label { font-size: 0.7rem; color: var(--text-dim); font-family: var(--font-mono); }
@media (max-width: 768px) { .dag-row { flex-direction: column; } }

/* Pattern 5: Sample Data Tables (cell highlighting) */
.cell-match { background: var(--green-dim); font-weight: 600; }
.cell-miss { background: var(--red-dim); color: var(--red); font-weight: 500; }
.cell-neutral { color: var(--text-dim); }

/* Callout boxes (reused from DRLA) */
.callout { background: var(--amber-dim); border-left: 3px solid var(--amber); padding: 0.75rem 1rem; border-radius: 0 6px 6px 0; margin: 1rem 0; font-size: 0.88rem; }
.callout strong { color: var(--amber); }
.callout.callout--blue { background: var(--blue-dim); border-left-color: var(--blue); }
.callout.callout--blue strong { color: var(--blue); }
```

- [ ] **Step 4: Set up KPI cards**

Four KPIs summarizing the scenario:
- "4" / "Tables" (accent)
- "3" / "Join Strategies" (green)
- "1" / "Recommended" (amber)
- "$8.50" / "Test Revenue" (red)

- [ ] **Step 5: Remove placeholder sections not needed**

Remove the pipeline section (not relevant). Remove the filter bar and flat alerts container (this example uses decision groups and literate sections, not triage cards). Keep the action bar, keyboard hint, and footer.

- [ ] **Step 6: Verify the skeleton opens in browser**

Run: `xdg-open examples/sql-query-review.html` or verify manually.
Expected: Page loads with hero, KPIs, action bar. No content sections yet. Dark mode by default with light mode on preference.

- [ ] **Step 7: Commit**

```bash
git add examples/sql-query-review.html
git commit -m "Scaffold SQL query review example with engine CSS/JS and SQL-specific styles"
```

---

### Task 2: Add the Data Flow Diagram (Pattern 4)

**Files:**
- Modify: `examples/sql-query-review.html`

This task adds a data flow diagram at the top of the content showing how the four tables connect through CTEs. Each node is annotatable.

- [ ] **Step 1: Add the diagram section after KPIs**

Place a section label "Data Model" and a `.dag-container` showing:

Row 1 (source tables): `applications`, `attempts`, `conversions`, `tier_campaign_buffer`
Row 2 (edges): labeled with join keys (`application_id`, `campaign_id`, `parent_campaign_id`)
Row 3 (CTE): `attempt_revenue` (amber, CTE class)
Row 4 (edge): `GROUP BY parent_campaign_id`
Row 5 (output): `partner_revenue_summary` (green, output class)

Each `.dag-node` is a `<div>` element with `data-annotation-id` (e.g., `dag-applications`, `dag-attempt-revenue`). Nodes that correspond to later literate sections get an `onclick="document.getElementById('lit-attempt-revenue').scrollIntoView({behavior:'smooth'})"` handler instead of an `<a>` tag, to avoid conflict between annotation clicks and navigation.

- [ ] **Step 2: Add a callout below the diagram**

Use `.callout.callout--blue`:
```
Key question: How should attempt_revenue join conversions to attempts?
The join strategy determines whether revenue is attributed precisely
or spread across all campaigns that touched an application.
```

- [ ] **Step 3: Verify in browser**

Expected: Diagram renders centered, nodes are color-coded (blue for tables, amber for CTEs, green for output). Hovering nodes shows pointer cursor. Clicking a node opens the annotation input (engine's existing annotation JS). Responsive: stacks vertically on narrow viewports.

- [ ] **Step 4: Commit**

```bash
git add examples/sql-query-review.html
git commit -m "Add data flow diagram showing table relationships for DRLA scenario"
```

---

### Task 3: Add Literate SQL Sections (Pattern 2) for the Data Model

**Files:**
- Modify: `examples/sql-query-review.html`

This task adds literate SQL sections explaining the data model: campaign roles, the example application, and the conversion. Content is adapted from sections 01 and 02 of the original DRLA explainer.

- [ ] **Step 1: Add section label "The Data Model"**

- [ ] **Step 2: Add literate section 1: Campaign Roles**

Left (prose): Step number 1. "One application generates multiple attempts (one per campaign pinged). Some campaigns participate in price reject setups where a top-tier campaign places a bid, and a negotiable 'catcher' campaign fulfills it."

Right (code): A sample data table (Pattern 5) showing the Campaign Roles table from the DRLA file. Use `data-table-id="campaign-roles"` and `data-row-id` per row. Use `.cell-match` for the `parent_campaign_id` values that illustrate the self-reference and parent-reference patterns.

- [ ] **Step 3: Add literate section 2: Example Application #1000**

Left (prose): Step number 2. "An application enters the ping tree and gets pinged to ~75 campaigns. Three of them matter for this example: a top-tier (Partner A), another top-tier (Partner B), and a negotiable that catches Partner A's bid."

Right (code): The 3-attempt table from the DRLA file. Use `data-table-id="attempts"` with `data-row-id="att-501"`, `att-502`, `att-503`. Apply `.cell-match` to att_503's approved column.

- [ ] **Step 4: Add literate section 3: The Conversion**

Left (prose): Step number 3. "The conversion records which campaign actually accepted the lead. The campaign_id on the conversion is C_150 (the negotiable), not C_100 (the top-tier that placed the bid). This mismatch is the root of the join problem."

Right (code): The conversion table. Apply `.cell-match` to the `C_150` campaign_id value. Add a `.callout` below emphasizing the mismatch. The join code `ON` clause within the callout uses `data-annotation-id="conversion-campaign-mismatch"`.

- [ ] **Step 5: Verify in browser**

Expected: Three literate sections render in two-column layout. Prose on left, tables on right. Step numbers show as blue circles. Tables are interactive (row flagging works). Annotations on clause IDs work. Responsive: stacks to single column on mobile.

- [ ] **Step 6: Commit**

```bash
git add examples/sql-query-review.html
git commit -m "Add literate SQL sections for data model walkthrough"
```

---

### Task 4: Add Query Comparison Decision Group (Pattern 3)

**Files:**
- Modify: `examples/sql-query-review.html`

This is the core of the example: a decision group with three join strategies (broken, Option A, Option B). Each option is an alert card within a `.decision-group`, with diff highlighting on the SQL and sample data tables showing the results.

- [ ] **Step 1: Add section label "Join Strategy" and decision group wrapper**

```html
<div class="decision-group anim-up" style="--i:N">
  <div class="decision-header">
    <div class="decision-question">How should attempt_revenue join conversions?</div>
    <div class="decision-context">Select an approach and add notes. Each option shows the join SQL with the same 3-attempt scenario.</div>
  </div>
  <div class="decision-options">
    <!-- three option cards go here -->
  </div>
</div>
```

- [ ] **Step 2: Add Option Card 1: Current join (BROKEN)**

Alert card with `data-alert-id="join-broken"` and `data-severity="action"` (red, because it produces wrong results).

Title: "Current: Join on parent_campaign_id"
Badge: `badge--red` "BROKEN"

SQL block with annotatable clauses:
```sql
LEFT JOIN conversion_cte
  ON attempt.application_id = conversion.application_id
  AND attempt.parent_campaign_id = conversion.campaign_id
```

The `AND attempt.parent_campaign_id = conversion.campaign_id` clause gets `data-annotation-id="broken-join-clause"`.

Sample data table (`data-table-id="broken-results"`) showing all three attempts with `.cell-miss` on every Match? and Revenue cell ($0 for all).

Result summary: "ZERO revenue for all attempts."

Quick actions:
- `data-action="Reject: parent_campaign_id never matches negotiable conversion"` label "Reject"

- [ ] **Step 3: Add decision divider**

```html
<div class="decision-divider"><span>or</span></div>
```

- [ ] **Step 4: Add Option Card 2: Option A (application_id only)**

Alert card with `data-alert-id="join-option-a"` and `data-severity="review"` (amber, because it works but overcounts).

Title: "Option A: Join on application_id only"
Badge: `badge--amber` "OVERCOUNTS" and `badge--green` "PRODUCTION ETL"

SQL block:
```sql
LEFT JOIN conversion_cte
  ON attempt.application_id = conversion.application_id
```

Add a phantom line `AND attempt.campaign_id = conversion.campaign_id` with `.diff-del` class (struck-through, dimmed) to show what Option A is missing relative to Option B.

Sample data table (`data-table-id="option-a-results"`) showing all three attempts matching with `.cell-match` on Match? column, $8.50 revenue for all. Add a `.cell-miss` on C_200's revenue to highlight the overcount.

Result summary: "ALL attempts get $8.50. C_200 gets revenue it did not earn."

Quick actions:
- `data-action="Accept Option A: application_id join is simpler, overcount acceptable"` label "Accept (simpler)"
- `data-action="Reject Option A: overcount is not acceptable for DRLA precision"` label "Reject (overcounts)"

- [ ] **Step 5: Add decision divider and Option Card 3: Option B (precise)**

Alert card with `data-alert-id="join-option-b"` and `data-severity="routine"` (green, recommended).

Title: "Option B: Join on (application_id, campaign_id)"
Badges: `badge--green` "Recommended" and `badge--green` "PRECISE"

SQL block:
```sql
LEFT JOIN conversion_cte
  ON attempt.application_id = conversion.application_id
  AND attempt.campaign_id = conversion.campaign_id
```

Use `.diff-add` on the `AND attempt.campaign_id = conversion.campaign_id` line. Give it `data-annotation-id="option-b-campaign-join"`.

Sample data table (`data-table-id="option-b-results"`) showing att_501 and att_502 with `.cell-neutral` (no match, $0) and att_503 with `.cell-match` (C_150 = C_150, $8.50).

Result summary: "Only the negotiable attempt matches. Revenue flows to the correct parent_campaign_id group via Stage 2 aggregation."

Quick actions:
- `data-action="Approve Option B: precise attribution via campaign_id match"` label "Approve (precise)"

- [ ] **Step 6: Add Stage 2 aggregation comparison**

After the decision group, add a literate section (Pattern 2) showing how Stage 2 aggregation differs between options:

Left (prose): "Stage 2 groups by parent_campaign_id. The join strategy determines what revenue each group sees."

Right: A side-by-side comparison using `.comparison-table` (existing engine component) showing:
- Option A: C_100 gets $17.00 (double-counted), C_200 gets $8.50 (unearned)
- Option B: C_100 gets $8.50 (correct), C_200 gets $0 (correct)

Use `.positive` and `.negative` classes on cells.

- [ ] **Step 7: Verify in browser**

Expected: Decision group renders with three option cards. Severity colors work (red, amber, green). Quick action pills are clickable. Diff highlighting shows green/red on SQL lines. Sample data tables have row flagging. Annotation inputs open on annotatable SQL clauses. Dismissing a card collapses it. Copy Review Summary includes Actions Selected, Dismissed, Flagged Items, and Annotations sections.

- [ ] **Step 8: Commit**

```bash
git add examples/sql-query-review.html
git commit -m "Add query comparison decision group with three join strategies"
```

---

### Task 5: Add Direct Buys Section and Summary

**Files:**
- Modify: `examples/sql-query-review.html`

The final content section: a literate explanation of why Option B also handles direct buys, and a summary callout.

- [ ] **Step 1: Add literate section: Direct Buys**

Left (prose): Step number 4. "When a top-tier campaign buys directly (no price reject), campaign_id matches on both sides. Option B handles this correctly."

Right (code): The direct buy attempt and conversion tables from the DRLA file. Apply `.cell-match` to C_100 matching C_100.

Give the join clause `data-annotation-id="direct-buy-match"`.

- [ ] **Step 2: Add summary callout**

A `.callout.callout--blue` with:
- "Recommendation: Option B. Join on (application_id, campaign_id)."
- Bullet points for direct buys, price reject, and unrelated campaigns.
- Final note about production ETL using Option A for simplicity.

- [ ] **Step 3: Verify complete page in browser**

Do a full walkthrough:
1. Page loads, KPIs visible, diagram renders
2. Literate sections explain data model
3. Decision group presents three options with diff highlighting
4. Select Option B's "Approve" pill, dismiss the other two with notes
5. Flag a row in the sample data table
6. Annotate the `option-b-campaign-join` clause
7. Click Copy Review Summary
8. Verify the markdown includes: Actions Selected (Option B), Dismissed (broken + Option A with notes), Flagged Items, Annotations

- [ ] **Step 4: Commit**

```bash
git add examples/sql-query-review.html
git commit -m "Add direct buys section and summary to complete the DRLA example"
```

---

### Task 6: Write the Skill Reference Document

**Files:**
- Create: `~/.claude/skills/action-report/references/sql-component-patterns.md`
- Reference: `docs/superpowers/specs/2026-03-22-sql-component-patterns-design.md` (spec)
- Reference: `~/.claude/skills/action-report/references/planning-decision-patterns.md` (style reference)
- Reference: `~/.claude/skills/action-report/references/sql-driven-patterns.md` (existing SQL reference)

This document provides Claude with guidance on generating SQL-focused interactive reports. It follows the layered freedom model and the same format as existing reference docs.

- [ ] **Step 1: Write the reference document**

Structure:
1. Opening paragraph: when to read this reference (SQL query walkthroughs, join strategy comparisons, data model explanations)
2. **Layer 1: Structural Contracts** — Table of CSS classes and data attributes for each pattern. One short HTML snippet per pattern (5-10 lines). Reference `examples/sql-query-review.html` as the canonical example.
3. **Layer 2: Component Patterns** — The five patterns with "when to use" guidance. The composition table from the spec. Custom component extension rules.
4. **Layer 3: Content** — Examples of prose explanation style, severity assignment for query options, quick action patterns for SQL review.
5. Feature flag recommendations: `data-annotatable` always on, persistence on.

Keep the document under 150 lines. Do not duplicate CSS definitions (reference the example file). Do not duplicate engine structural contracts (reference `references/interactive-report-engine.html`).

- [ ] **Step 2: Update SKILL.md domain reference table**

Read `~/.claude/skills/action-report/SKILL.md` and find the domain reference table (around line 406-411). Add a row for the new file:

| SQL query walkthroughs | `references/sql-component-patterns.md` | Annotatable SQL, literate sections, data flow diagrams, query comparison |

The existing `SQL/data-driven reviews` row pointing to `sql-driven-patterns.md` stays. That file covers mapping query results to dashboard alert cards. The new file covers SQL-as-content patterns (explaining and reviewing the queries themselves). They are complementary.

- [ ] **Step 3: Commit**

```bash
git add ~/.claude/skills/action-report/references/sql-component-patterns.md ~/.claude/skills/action-report/SKILL.md
git commit -m "Add SQL component patterns reference for action-report skill"
```

---

### Task 7: Update Documentation

**Files:**
- Modify: `docs/pattern-guide.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update pattern-guide.md**

In the "Variants Beyond the Engine Template" section (near end of file), add a paragraph about SQL query reviews:

"**SQL query walkthroughs** with annotatable clauses, literate explanations, and strategy comparisons use the engine template's decision group and annotation mechanisms with additional inline CSS for SQL-specific layout (literate sections, data flow diagrams, diff highlighting). See `examples/sql-query-review.html` for a DRLA price-reject joins scenario that demonstrates all five SQL component patterns."

- [ ] **Step 2: Update CLAUDE.md repo structure**

Add `sql-query-review.html` to the examples listing:

```
│   ├── sql-query-review.html           # SQL query walkthrough with annotatable clauses
```

- [ ] **Step 3: Commit**

```bash
git add docs/pattern-guide.md CLAUDE.md
git commit -m "Document SQL query review example in pattern guide and CLAUDE.md"
```

---

### Task 8: Final Verification

- [ ] **Step 1: Open `examples/sql-query-review.html` in browser and complete a full review cycle**

1. Read the data flow diagram and annotate a node
2. Read through literate sections
3. In the decision group, select Option B's "Approve" action
4. Dismiss the broken join with a note
5. Flag a row in one of the sample data tables and add a row note
6. Annotate the `option-b-campaign-join` clause
7. Click Copy Review Summary
8. Paste the markdown and verify all sections are present and correctly formatted

- [ ] **Step 2: Test light mode**

Override `prefers-color-scheme` in browser dev tools. Verify all SQL-specific CSS classes render correctly in light mode (syntax highlighting colors, diff highlighting, diagram node colors).

- [ ] **Step 3: Test responsive layout**

Resize to 375px width. Verify:
- Literate sections stack to single column
- DAG diagram stacks vertically
- Decision group cards remain readable
- Action bar is usable

- [ ] **Step 4: Verify no engine template changes**

Run: `git diff interactive-report-engine.html`
Expected: No changes. The engine template is untouched.

- [ ] **Step 5: Commit if any fixes were needed**

```bash
git add examples/sql-query-review.html
git commit -m "Fix issues found during final verification"
```
