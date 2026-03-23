# SQL Component Patterns for Interactive Report Engine

## Problem

The interactive report engine handles triage and review workflows well (compliance reviews, operations dashboards, planning decisions). It does not have patterns for SQL-centric content: query walkthroughs, join strategy comparisons, or data model explanations.

A previous one-off explainer (`~/.agent/diagrams/drla-price-reject-joins.html`) demonstrated the value of visual SQL explanation but had three friction points:

1. **Pointing.** No way to click on a specific SQL clause to give feedback. The reviewer had to describe locations in words ("the second join in Option B").
2. **Decision capture.** No structured way to select a preferred query approach and annotate why.
3. **Comprehension.** SQL as code blocks with prose is adequate but not optimal. Table relationships and data flow are easier to understand visually.

## Solution

Four composable SQL component patterns that Claude selects and combines based on the situation, plus freedom to create custom visualizations as content decisions. All patterns integrate with the engine's existing feedback loop (annotations, decision groups, notes, row flagging). No new JavaScript state mechanisms are required.

### Deliverables

1. **`examples/sql-query-review.html`** — Reference example using the DRLA price-reject joins scenario. Demonstrates all four patterns working together.
2. **Skill reference doc** (`references/sql-component-patterns.md` in the action-report skill directory) — Guidance for when and how to use each pattern, following the layered freedom model.
3. **CSS additions** — Generated inline by Claude during report creation. The engine template remains unchanged. The skill reference doc provides canonical CSS definitions for each pattern. This keeps SQL-specific styles out of the domain-agnostic engine.

## Component Patterns

### Pattern 1: Annotatable SQL Blocks

Syntax-highlighted SQL where each clause (SELECT, JOIN, WHERE, GROUP BY) is a discrete clickable annotation target.

**Structural contract:**
- Each clause span gets `data-annotation-id` with a descriptive slug (e.g., `cte1-join`, `where-date-filter`).
- The body-level `data-annotatable` flag must be set.
- SQL syntax highlighting uses CSS classes: `.sql-kw` (keywords), `.sql-str` (strings), `.sql-fn` (functions), `.sql-tbl` (table/alias names), `.sql-comment` (comments).

**Feedback export:**
```markdown
### Annotations
- [cte1-join] "ON a.app_id = c.app_id AND a.campaign_id = c.campaign_id": "Correct for price-reject. Verify this handles direct buys too."
```

**When to use:** Any time SQL is shown and the reviewer might want to comment on specific clauses.

### Pattern 2: Literate SQL Sections

Two-column layout: prose explanation on the left, syntax-highlighted code on the right. Each row covers one logical step (a CTE, a join, a filter).

**Structural contract:**
- Container: `.lit-section` (CSS grid, two columns).
- Left column: `.lit-prose` with a `.step-num` badge for sequencing.
- Right column: `.lit-code` with syntax-highlighted SQL.
- Each section can include clause-level annotations within the code column (via `data-annotation-id`).
- Literate sections are not alert cards. Feedback from literate sections uses the annotation mechanism, not the notes mechanism.

**Feedback export:** Uses the annotation mechanism:
```markdown
### Annotations
- [step2-groupby] "GROUP BY parent_campaign_id": "Should we filter out test campaigns before aggregation?"
```

**When to use:** Single complex query that needs explanation. Data model walkthroughs. Any scenario where "what does this SQL do?" is the question.

### Pattern 3: Query Comparison Cards

Side-by-side panels showing alternative query strategies with structural diff highlighting.

**Structural contract:**
- Wrapped in a `.decision-group` container (existing pattern).
- Each variant is a `.diff-panel` with a `.diff-header` containing a radio/checkbox selection and a `.diff-body` containing the SQL.
- Diff lines use classes: `.diff-add` (green, new in this variant), `.diff-del` (red, removed), `.diff-same` (dimmed, shared).
- Each variant is a standard alert card within the decision group, using `data-alert-id` and quick-action pills with `data-action`. No new attributes needed.

**Feedback export:** Uses the existing `### Actions Selected` section:
```markdown
### Actions Selected
- Join Strategy — Option B (campaign_id match): "Use precise attribution via campaign_id"
```

**When to use:** Comparing two or more query approaches. Strategy selection. The DRLA scenario's three join strategies are the canonical example.

### Pattern 4: Sample Data Tables

Show what data looks like at each stage of the query. Color-coded cells highlight matches, mismatches, and key values.

**Structural contract:**
- Uses existing table component with `data-table-id` and `data-row-id`.
- Cell highlighting classes: `.cell-match` (green, match/success), `.cell-miss` (red, mismatch/failure), `.cell-neutral` (dimmed). Namespaced to avoid collision with existing engine CSS.
- Tables sit inside literate sections or beneath query comparison cards.

**Feedback export:** Uses existing row flagging:
```markdown
### Flagged Items
- att_503 (C_150, negotiable): "This is the only row that should match. Confirmed."
```

**When to use:** Any time concrete data makes the SQL behavior clearer. Join comparisons benefit the most (show which rows match under each strategy).

## Composition Guidance

These are defaults, not rules. Claude adapts based on the scenario.

| Scenario | Recommended patterns | Rationale |
|----------|---------------------|-----------|
| Single complex query | Literate + annotations + sample data | Walk through step by step, let reviewer annotate specific clauses |
| Strategy comparison | Comparison cards + sample data | Show alternatives, let reviewer pick, show data behavior per option |
| Data model explanation | Literate + sample data | Walk through tables and relationships with concrete examples |
| Full query review | All four | Literate sections for shared context, comparison cards for the decision, sample data throughout |

## Reference Example: DRLA Price-Reject Joins

The example file (`examples/sql-query-review.html`) rebuilds the DRLA price-reject joins scenario using these patterns. It demonstrates:

1. Literate SQL sections walking through the data model with prose explanations and sample data tables.
2. A query comparison decision group for the three join strategies (broken, Option A, Option B), each with structural diff highlighting.
3. Sample data tables (the 3-attempt, 1-conversion scenario) embedded within the comparison cards, showing which rows match under each strategy.
4. Annotatable SQL throughout, so a reviewer can click any clause and leave feedback.

The scenario naturally exercises all four patterns and all three use cases (single query comprehension, strategy comparison, data model explanation).

## Feedback Loop Integration

All five patterns map to existing engine state mechanisms:

| Pattern | State mechanism | Summary section |
|---------|----------------|-----------------|
| Clause annotations | `annotations` | `### Annotations` |
| Decision group selections | `actions` (via decision groups) | `### Actions Selected` |
| Literate section annotations | `annotations` | `### Annotations` |
| Sample data row flags | `flaggedRows` / `rowNotes` | `### Flagged Items` |
| Custom visualization annotations | `annotations` | `### Annotations` |

No new state keys. No JavaScript changes to the engine. The `copySummary()` function reads the same state shape it always has. The structured markdown output is parseable by Claude for follow-up actions.

## Skill Reference: Layered Freedom Model

The skill reference doc follows the three-layer framework from `docs/skill-design-guide.md`.

**Layer 1 (Structural Contracts):** The data attributes, CSS classes, and HTML structure conventions listed above. These are exact. Deviating from them breaks annotation, feedback export, or visual rendering.

**Layer 2 (Component Patterns):** The four patterns and the composition table. These are defaults with extension rules. Claude can create new SQL-specific components (e.g., an explain plan tree, a column lineage view) as long as they satisfy the same requirements as any custom component: animation system, color system, keyboard navigation, responsive layout, and feedback loop integration.

**Layer 3 (Content):** Prose explanation style, number of literate sections per query, and custom visualizations (diagrams, flow charts, relationship maps). Claude can create any visual element that helps comprehension, provided interactive elements participate in feedback collection via `data-annotation-id`. The reference doc provides examples as starting points and does not close the set.

## Non-Goals

- **SQL parsing at runtime.** The SQL is not parsed in the browser. Claude does the clause boundary identification during generation (Layer 1). This keeps the HTML zero-dependency.
- **Query execution.** The report does not run queries. It displays and explains SQL that has already been written.
- **New engine template.** This is not a second template. These are component patterns that Claude composes within generated HTML files, using the engine's existing CSS/JS infrastructure where applicable.
- **Exhaustive SQL coverage.** The patterns cover the common cases (CTEs, JOINs, aggregations, comparisons). Claude can extend to window functions, recursive CTEs, or vendor-specific syntax without additional guidance.
