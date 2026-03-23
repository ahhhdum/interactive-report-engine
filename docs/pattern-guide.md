# Interactive Feedback Reports: A Reusable Pattern for Claude Code

## The Problem

Claude Code runs in a terminal. Terminal output is adequate for code generation, query execution, and file manipulation, but it falls short for three categories of work:

1. **Visual review.** Scanning 13 compliance requests or 40 partner rows in monospaced text is slow and error-prone. Humans triage faster with color-coded severity, collapsible sections, and spatial layout.
2. **Structured annotation.** When a reviewer flags 3 items out of 13, the AI needs to know which 3 and what to do with each. Free-form chat ("fix the ones I mentioned") forces the AI to guess intent. Structured output ("REQUEST-24124: Draft notification emails for 40 partners") is unambiguous.
3. **Shareability.** A terminal session is not a deliverable. Compliance officers, managers, and teammates need a URL they can open, review, and bookmark.

The alternative is building a full web application with a backend, a database, user authentication, and deployment infrastructure. For review workflows that run once per day or once per week, that is overkill.

The interactive feedback report sits between these two extremes. It is a single HTML file with no backend, no build step, and no dependencies beyond a browser.

## The 3-Layer Architecture

```
+---------------------------+
|   Layer 1: Prompt          |
|   Template                 |
|   (queries, classification,|
|    HTML generation)        |
+------------+--------------+
             |
             | generates
             v
+---------------------------+
|   Layer 2: HTML            |
|   Template                 |
|   (interaction engine,     |
|    domain data, feature    |
|    flags)                  |
+------------+--------------+
             |
             | user reviews, clicks
             | "Copy Review Summary"
             v
+---------------------------+
|   Layer 3: Feedback        |
|   Loop                     |
|   (structured markdown,    |
|    paste back into Claude, |
|    Claude executes actions) |
+---------------------------+
```

Data flows in one direction per cycle. The prompt template produces the HTML. The HTML produces the structured markdown. The markdown returns to Claude for execution. One cycle takes 2 to 5 minutes for a typical review.

## Layer 1: Prompt Template

The prompt template is a markdown file that tells Claude Code how to gather data, classify items, and populate the HTML template. It is domain-specific.

A prompt template contains:

- **Data queries.** SQL statements, API calls, or file reads with placeholder variables (`{TODAY}`, `{CONSUMER_EMAIL}`). These run against your data sources.
- **Classification rules.** Deterministic logic that maps data to severity levels. For a compliance review: fewer than 20 partners and no duplicates maps to "routine" (green); 20 or more partners maps to "needs review" (amber); same email and phone in the same batch maps to "duplicate" (blue).
- **HTML generation instructions.** Which template to read, which placeholders to replace, where to save the output, and how to mask PII.
- **Table selection rationale.** Which database tables to use and why, so that a future maintainer understands the join strategy.

The prompt template references the HTML template by file path. It does not contain CSS, JavaScript, or HTML markup.

## Layer 2: HTML Template (The Interaction Engine)

The domain-agnostic interaction engine lives at:

```
interactive-report-engine.html
```

This single file contains three zones in sequence: CSS (approximately 200 lines), HTML with placeholder comments, and JavaScript (approximately 500 lines). The total file size is approximately 1,100 lines.

### CSS Zone (Lines 8 to 274)

The CSS defines a dark-mode-first design system with automatic light mode via `prefers-color-scheme`. It includes:

- A variable-based color palette with semantic names (`--green`, `--amber`, `--red`, `--blue`, `--slate`).
- Component styles for KPI cards, pipeline steps, filter buttons, alert cards, badges, quick-action pills, data tables, and the action bar.
- Severity-based border coloring: `.severity-action` and `.severity-escalate` use red; `.severity-review` and `.severity-todo` use amber; `.severity-anomaly` and `.severity-duplicate` use blue; `.severity-routine` and `.severity-ok` use green.
- A dismiss animation that collapses the card height, fades opacity to zero, and strikes through the title.
- Responsive breakpoints at 768px that switch KPI grids from 4 columns to 2 and hide pipeline arrows.

### HTML Zone (Lines 276 to 434)

The HTML zone uses placeholder comments (`<!-- HERO_TITLE: ... -->`, `<!-- KPI_1_VALUE -->`, `<!-- ALERT_CARDS: ... -->`) where Claude inserts domain data during generation. The structural elements are:

- **Hero section.** Eyebrow label, title, subtitle, and metadata line.
- **KPI row.** Four metric cards with color variants.
- **Pipeline.** Optional horizontal step indicator with done, active, and pending states.
- **Filter bar.** Buttons that filter alert cards by severity type.
- **Alert cards container.** Each card has a dismiss checkbox, title, meta badges, description, quick-action pills, a note toggle, and an optional collapsible detail table.
- **Standalone tables.** For data that does not belong inside an alert card.
- **Action bar.** Fixed to the bottom of the viewport. Shows interaction counts and provides Copy Review Summary, Share State, and Clear Review buttons.
- **Keyboard hint overlay.** Shows shortcut keys on demand.

### Data Attributes on Alert Cards

Each alert card requires two data attributes:

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `data-alert-id` | Unique identifier for the alert. Used in state tracking. | `"request-24124"` |
| `data-severity` | Severity classification string. Must match a CSS class. | `"review"` |

Each quick-action pill requires one:

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `data-action` | The literal instruction that appears in the review summary. | `"Draft notification emails for 40 partners"` |

Table rows use `data-row-id` for flagging. Tables use `data-table-id` to namespace rows.

### JavaScript Zone (Lines 457 to 1112)

The JavaScript is a single IIFE (immediately invoked function expression) with no external dependencies. It manages:

- **State object.** Six arrays and objects: `dismissed`, `notes`, `actions`, `flaggedRows`, `rowNotes`, `annotations`.
- **Dismiss toggle.** Checkbox click adds/removes the card ID from `state.dismissed` and applies the CSS collapse animation.
- **Quick-action selection.** In single-select mode, clicking a pill deselects others on the same card. In multi-select mode (`data-multiaction`), pills toggle independently.
- **Inline notes.** Textarea that appears below the card when the user clicks "+ Add note". Text is stored in `state.notes` by alert ID.
- **Table row flagging.** Clicking a table row toggles a blue highlight and inserts an inline text input for a note.
- **Inline annotations.** When the body-level `data-annotatable` flag is set, elements with `data-annotation-id` show a dashed underline. Clicking them opens a textarea for annotation text.
- **Filter.** Hides cards whose `data-severity` does not match the selected filter button.
- **Keyboard navigation.** `j`/`k` move focus between cards, `x` dismisses, `1` through `5` select quick actions, `n` opens note, `c` copies summary, `s` shares state, `?` toggles the hint.
- **Copy Review Summary.** Builds a markdown document from the current state (see Layer 3).
- **Share State.** Serializes the state object as JSON, base64-encodes it, and appends it to the URL as a hash fragment (`#state=...`). The hash fragment is not sent to the server.
- **localStorage persistence.** On every state change, the full state object is saved to `localStorage` keyed by the page pathname. On load, the engine restores from URL hash first (higher priority), then localStorage.

## Layer 3: Feedback Loop

When the user clicks "Copy Review Summary," the JavaScript builds a markdown document and copies it to the clipboard. The user pastes this markdown back into Claude Code (or Claude Desktop). Claude parses the deterministic sections and executes the requested actions.

### Example Output

```markdown
## Compliance Review, 2026-03-20

### Actions Selected
- REQUEST-24124 (M.S., FL): "Draft notification emails for 40 partners"
- REQUEST-24120 (J.R., TX): "Process standard delete"

### Dismissed (Reviewed)
- [x] REQUEST-24121 (A.K., CA) (routine)
- [x] REQUEST-24122 (T.M., NY) (routine)
- [x] REQUEST-24123 (R.L., OH) (routine), already in optout

### Notes
- REQUEST-24124 (M.S., FL): "40 partners is high. Check if any are inactive."

### Flagged Items
- LendingTree (partner 1234): "Post count of 87 seems high. Verify delivery rule."
- QuoteWizard (partner 5678): "Last post was 18 months ago. May be inactive."

### Annotations
- [kpi-total] "13 total requests": "This is higher than the weekly average of 8."

### Still Open
- [ ] REQUEST-24118 (P.G., WA) (duplicate)
- [ ] REQUEST-24119 (P.G., WA) (duplicate)
```

Each section uses a consistent format:

| Section | Format | AI Can Parse |
|---------|--------|-------------|
| Actions Selected | `- {title}: "{literal instruction}"` | Yes. The instruction is the `data-action` attribute verbatim. |
| Dismissed | `- [x] {title} ({severity})` with optional note after `, ` | Yes. Checkbox format. |
| Notes | `- {title}: "{free text}"` | Yes. May trigger follow-up queries. |
| Flagged Items | `- {label} ({id}): "{free text}"` | Yes. Rows from data tables. |
| Annotations | `- [{id}] "{context}": "{free text}"` | Yes. Inline annotations on any annotatable element. |
| Still Open | `- [ ] {title} ({severity})` | Yes. Unchecked items. |

The AI does not interpret intent from vague language. Each action is a literal instruction copied directly from the `data-action` attribute that the prompt template defined. "Draft notification emails for 40 partners" is unambiguous. "Fix the email thing" is not.

## Feature Flags

Three feature flags are set as `data-*` attributes on the `<body>` element:

### `data-multiaction`

When present, users can select multiple quick-action pills on a single alert card. When absent (the default), selecting a pill deselects any previously selected pill on the same card.

Use `data-multiaction` when a single item can require multiple actions. For example, a compliance request might need both "Draft notification emails" and "Add to suppression list" simultaneously.

### `data-annotatable`

When present on the body, the engine enables click-to-annotate behavior on any element that has a `data-annotation-id` attribute. A dashed underline appears on hover. Clicking opens a textarea for annotation text.

Use `data-annotation-id` on KPI values, badge labels, or any element where the reviewer might want to add context. Annotations appear in their own section of the review summary.

### `data-no-persist`

When present, the engine does not save state to `localStorage`. The page starts fresh on every load.

Use `data-no-persist` for one-time reports where persistence would confuse the user. Omit it (the default) for recurring review workflows where the user might close the tab and return later.

## Capabilities

### localStorage Persistence

By default, every state change (dismiss, select action, add note, flag row, annotate) is saved to `localStorage` under a key derived from the page pathname. When the user reloads the page or reopens the tab, the engine restores all prior state automatically. The Clear Review button in the action bar removes all persisted state.

To disable persistence, add `data-no-persist` to the `<body>` element.

### Shareable URL Hash

The Share State button serializes the full state object as JSON, base64-encodes it, and appends it to the URL as a hash fragment (`#state=eyJ...`). Because hash fragments are not sent to the server, the shared URL works on any static host without exposing state to server logs.

When a user opens a URL with a `#state=` hash, the engine imports the state and immediately strips the hash from the URL. This makes the hash a one-time import: subsequent edits and reloads persist via localStorage, not the original hash. The Clear Review button also strips any active hash.

### Multi-Select Actions

When `data-multiaction` is set on the body, quick-action pills behave as toggleable checkboxes rather than radio buttons. The review summary lists all selected actions for each card as separate lines.

### Inline Annotations

Any HTML element can become annotatable by adding `data-annotation-id="unique-id"` (the body-level `data-annotatable` flag must be set). The CSS adds a dashed underline. Clicking opens a textarea that floats below the element. Annotations are stored by ID and appear in the Annotations section of the review summary.

## Using the `/action-report` Skill

The `/action-report` skill generates a new interactive report for any domain. To use it:

1. Describe the domain and the items to review. For example: "Generate an action report for today's experiment queue. There are 4 experiments pending launch approval and 2 with degraded metrics."
2. Claude reads the engine template from `interactive-report-engine.html`.
3. Claude populates the HTML placeholders with your domain data: alert cards, KPI values, severity classifications, and quick-action pills.
4. The generated file is saved to `/tmp/` and opened in the browser.
5. Review in the browser, click Copy Review Summary, paste back into Claude.

The skill does not run queries automatically. You provide the data context in your description, or you run queries first and then invoke `/action-report` with the results.

## Three Examples

### Example 1: Compliance Review (Production)

This is the original use case, built on March 20, 2026. A skill runs 4 SQL queries against production tables, classifies 13 pending deletion requests by severity, and generates a dashboard with:

- 4 KPI cards (total requests, routine, needs review, duplicates).
- 13 alert cards with severity coloring. One request (REQUEST-24124) had data shared with 40 partners across 469 posts and was classified as "needs review." A pair (REQUEST-24118 and REQUEST-24119) were flagged as duplicates based on identical email and phone submitted 6 minutes apart.
- Collapsible partner tables with row flagging. Reviewing which of 40 partners to notify is the highest-effort part of the workflow. Row flagging with inline notes ("verify delivery rule," "may be inactive") turns that review into structured feedback.
- Quick actions: Draft notification emails, Add to suppression list, Escalate, Process standard delete, Mark as duplicate, Mark reviewed.

After review, the structured summary pastes back into Claude Code. Claude drafts emails, prepares suppression SQL (not executed, shown for confirmation), and creates tickets for escalations.

### Example 2: Operations Dashboard (Demo)

The `examples/operations-dashboard.html` file demonstrates the same pattern for a different domain: daily marketplace health. It includes:

- Partner health alerts (bid volume anomalies, acceptance rate drops, error spikes).
- Campaign ROI table with row flagging for underperforming campaigns.
- Experiment queue with launch/hold/kill quick actions.

The CSS and JavaScript are identical to the engine template. Only the HTML content zone differs. This dashboard was built to demonstrate domain portability.

### Example 3: Experiment Triage (Hypothetical)

An experiment triage dashboard would review in-flight A/B tests. Each alert card would represent one experiment:

- **Severity mapping.** "Action" (red) for experiments with statistically significant negative results. "Review" (amber) for experiments approaching the planned sample size without significance. "Routine" (green) for experiments on track. "Info" (slate) for recently launched experiments with insufficient data.
- **Quick actions.** "Extend by 1 week," "Kill experiment," "Graduate winner," "Request power analysis."
- **Collapsible details.** Metric tables with current lift, p-value, and sample size per variant.
- **Feedback loop.** The pasted summary routes to different execution paths. "Kill experiment" triggers a ticket and a notification. "Graduate winner" triggers a configuration change request.

This example has not been built. It is included to illustrate how the pattern maps to a third domain.

## Variants Beyond the Engine Template

The interactive-report-engine template handles triage and review workflows where the user evaluates multiple items and takes different actions on each. For other use cases, the 3-layer pattern still applies but the rendering is different.

**Configuration choices** (color palettes, font pairings, theme variants) need a visual picker with a live preview and a copy button that emits structured code, not markdown. The engine's alert-card model does not fit this interaction. See `examples/config-chooser.html` for a standalone variant where the user picks a value from a visual option space and the feedback is a Python dict or JSON object rather than a review summary.

**Planning decisions** with connected options use the engine template's decision group component to group alternatives under a question. See `examples/sql-query-review.html` for decision groups that separate strategy choices from independent technical concerns.

**SQL query walkthroughs** with annotatable clauses, literate explanations, and strategy comparisons use the engine template's decision group and annotation mechanisms with additional inline CSS for SQL-specific layout (literate sections, data flow diagrams, diff highlighting). See `examples/sql-query-review.html` for a revenue attribution pipeline scenario that demonstrates all five SQL component patterns.

The 3-layer pattern (prompt generates visual artifact, human interacts, structured feedback returns to the AI) is the reusable abstraction. The engine template is one rendering of it. Other renderings are valid when the domain does not fit the alert-card model.

## File Locations

| File | Path | Purpose |
|------|------|---------|
| Engine template | `interactive-report-engine.html` | Domain-agnostic CSS + JS + placeholder HTML |
| Operations demo | `examples/operations-dashboard.html` | Triage workflow example |
| Anniversary trip | `examples/anniversary-trip-planner.html` | Planning dashboard with venue options |
| Config chooser | `examples/config-chooser.html` | Standalone visual config picker (not engine-based) |
| Config chooser prompt | `examples/config-chooser-prompt.md` | Prompt template for config choosers |
| Pattern guide | `docs/pattern-guide.md` | Comprehensive pattern documentation (this file) |
| Architecture overview | `docs/architecture.md` | Concise architecture overview |
| Skill design guide | `docs/skill-design-guide.md` | Layered freedom model for skill authoring |
