# Interactive Report Engine

A single-file HTML template for building interactive review dashboards that connect AI code assistants to human decision-making. The engine sits between terminal-only output and full web applications: it has no backend, no build step, no dependencies beyond a browser, and no deployment infrastructure beyond a static file host. It provides visual triage, structured annotation, and clipboard-based feedback that an AI can parse without ambiguity.

## Quick Start

1. Copy `interactive-report-engine.html` to a new file for your domain (e.g., `my-review-dashboard.html`).
2. Replace the placeholder comments in the HTML section (`<!-- REPORT_TITLE -->`, `<!-- HERO_STATS -->`, `<!-- ALERTS -->`, `<!-- TABLE_DATA -->`) with your domain-specific content.
3. The CSS and JavaScript sections require no changes. They work for any domain.
4. Open the file in a browser. Review the dashboard, dismiss items, select actions, and add notes.
5. Click "Copy Review Summary" to export your decisions as structured markdown.
6. Paste the markdown back into your AI code assistant. The AI parses the deterministic sections and executes the requested actions.

## Repository Structure

```
interactive-report-engine/
├── README.md                               # This file
├── CLAUDE.md                               # Claude Code project instructions
├── LICENSE                                 # MIT
├── interactive-report-engine.html          # The engine template (copy and fill in)
├── interactive-report-engine.publish.yaml  # Publishing sidecar
├── interactive-report-engine.publish.md    # Publishing description
├── docs/
│   ├── pattern-guide.md                    # Detailed 3-layer pattern documentation
│   ├── architecture.md                     # Concise architecture overview
│   └── skill-design-guide.md              # Layered freedom model for skill authoring
├── examples/
│   ├── operations-dashboard.html           # Triage workflow example
│   ├── operations-dashboard-prompt.md      # Prompt template for the example
│   ├── anniversary-trip-planner.html       # Planning dashboard with venue options
│   ├── dois-2587-technical-review.html     # Technical ticket review with decision groups
│   ├── config-chooser.html                 # Visual config picker (standalone variant)
│   └── config-chooser-prompt.md            # Prompt template for config choosers
└── .gitignore
```

## The Gap Between Terminal and Full Application

People building AI-assisted workflows hit the same fork. They can stay in the terminal, where the AI generates text and the human reviews text. Or they can build a web application with a backend, a database, authentication, and deployment infrastructure.

Terminal-only workflows are fast to build but poor for review. Scanning 13 items in monospaced output is slow. There is no way to flag 3 of 13 items without typing free-form instructions that the AI must interpret. There is no artifact to share with a colleague.

Full web applications solve the review problem but introduce a different cost. A Flask or Express server, a PostgreSQL or DynamoDB backend, OAuth, a deployment pipeline, and ongoing maintenance are reasonable for a product. They are not reasonable for a compliance review that runs once a day and involves one person.

The interactive feedback report is a single HTML file that sits between these two. It has no backend, no build step, no dependencies beyond a browser, and no deployment infrastructure beyond a static file host. It provides visual triage, structured annotation, and clipboard-based feedback that the AI can parse without ambiguity.

## The 3-Layer Architecture

The pattern has three layers. Each layer is a separate file type with a single responsibility.

**Layer 1: Prompt template (Markdown).** The prompt tells the AI how to gather data, classify items by severity, and populate the HTML template. It contains domain-specific queries, classification rules, and instructions for where to insert data. It does not contain CSS, JavaScript, or HTML markup.

**Layer 2: HTML template (Single file).** The template contains approximately 200 lines of CSS, an HTML skeleton with placeholder comments, and approximately 500 lines of JavaScript. The CSS and JavaScript are domain-agnostic. The AI reads this file, replaces the placeholders with domain data, and saves the result as a standalone HTML file.

**Layer 3: Feedback loop (Clipboard markdown).** After the user reviews the report in a browser, they click a "Copy Review Summary" button. The JavaScript builds a structured markdown document from the user's interactions (which items they dismissed, which actions they selected, what notes they wrote) and copies it to the clipboard. The user pastes this markdown back into the AI. The AI parses the deterministic sections and executes the requested actions.

```
Prompt template  -->  generates HTML  -->  user reviews in browser
                                                    |
                                                    v
                                           Copy Review Summary
                                                    |
                                                    v
                                     Paste back into AI  -->  AI executes
```

One review cycle takes 2 to 5 minutes. No server is running. No database is involved. The HTML file can live on the local filesystem, on a static host, or as a file:// URL.

## Why Structured Feedback Beats Free-Form Chat

When a reviewer looks at 13 items and decides that 3 need action, 8 are routine (dismiss), and 2 need investigation, they need to communicate those decisions back to the AI. In a chat-based workflow, this looks like:

> "The first three are fine, skip them. The one about the Florida consumer needs partner emails. The duplicates need to be merged. Oh, and flag that one partner with the high post count."

The AI must now figure out which "first three" means (by position? by ID?), what "partner emails" entails, what "merged" means for duplicates, and which partner had the high post count. Ambiguity compounds. The AI asks clarifying questions. The human repeats context.

Structured feedback eliminates this. Each interaction maps to a deterministic output format:

```markdown
### Actions Selected
- Request #24124 (M.S., FL): "Draft notification emails for 40 partners"
- Request #24120 (J.R., TX): "Process standard deletion"

### Dismissed (Reviewed)
- [x] Request #24121 (A.K., CA) (routine)
- [x] Request #24122 (T.M., NY) (routine)

### Flagged Items
- Partner ABC (ID 1234): "Post count of 87 seems high. Verify delivery rule."

### Still Open
- [ ] Request #24118 (P.G., WA) (duplicate)
```

Each quick-action pill in the HTML has a `data-action` attribute containing the literal instruction. When the user clicks "Draft notification emails for 40 partners," that exact string appears in the summary. The AI does not need to interpret intent. It reads a string and executes it.

The sections are deterministic:

| Section | Content | AI Parsing |
|---------|---------|-----------|
| Actions Selected | Alert title + literal instruction string | Route to execution handler by keyword match |
| Dismissed | Checkbox items with severity | Acknowledge, mark complete |
| Notes | Free text per item | Store as context, optionally trigger follow-up |
| Flagged Items | Table rows with optional notes | Investigation or escalation |
| Annotations | Inline notes on any element | Contextual metadata |
| Still Open | Unchecked items | Carry forward to next run |

## The Interaction Engine

The JavaScript portion of the template is a single IIFE (immediately invoked function expression) with no external dependencies. It provides:

- **Dismiss toggle.** Checkbox click collapses the alert card with an animation and adds the item ID to the dismissed list.
- **Quick-action selection.** Clicking a pill selects it (blue highlight) and copies the action text to the clipboard. In single-select mode, clicking a different pill on the same card deselects the previous one. In multi-select mode, pills toggle independently.
- **Inline notes.** A "+ Add note" toggle reveals a textarea below each alert card.
- **Table row flagging.** Clicking a row in any data table highlights it and inserts an inline text input for a note explaining why the row was flagged.
- **Inline annotations.** When the annotation feature flag is enabled on the page, elements marked with `data-annotation-id` become clickable. Clicking opens a textarea for annotation text. This allows reviewers to annotate KPI values, badge labels, or any other element. The feature is off by default and controlled by a single attribute on the page container.
- **Keyboard navigation.** `j`/`k` move focus between cards, `x` dismisses the focused card, `1` through `5` select quick actions, `n` opens the note field, `Escape` exits the focused note or annotation field, `c` copies the review summary, `s` copies a shareable URL.
- **Filter bar.** Buttons that show/hide alert cards by severity type.

The CSS portion is approximately 200 lines. It provides a dark-mode design system with automatic light-mode support via `prefers-color-scheme`. Severity levels map to border colors: red for action items, amber for items needing review, blue for anomalies or informational items, green for routine items. All colors use CSS custom properties that adapt to the color scheme.

Feature flags control behavior via `data-*` attributes on the `<body>` element:

| Flag | Effect | Default |
|------|--------|---------|
| `data-multiaction` | Allow multiple action pills selected per card | Off (single-select) |
| `data-annotatable` | Enable click-to-annotate on marked elements | Off |
| `data-no-persist` | Disable localStorage state saving | Off (persistence enabled) |

The engine works for compliance reviews, operations dashboards, financial reconciliation, engineering triage, and any other domain where a human reviews a list of items and makes per-item decisions.

## Sharing Without Infrastructure

The generated report is a single HTML file. It contains all CSS and JavaScript inline. It loads one external font (Google Fonts) with a graceful fallback to system fonts.

To share a report:

1. **Local file.** Open the HTML file directly in a browser with `file://`. This works for solo use.
2. **Static host.** Upload the file to any static hosting provider (GitHub Pages, Netlify, Cloudflare Pages, S3 + CloudFront, or a company intranet). No server-side processing is required.
3. **Shareable URL with state.** The Share State button serializes the reviewer's current progress (dismissed items, selected actions, notes, flagged rows, annotations) as a JSON object, base64-encodes it, and appends it to the URL as a hash fragment (`#state=eyJ...`). Because hash fragments are not sent to the server, the review state stays client-side. A reviewer can share their in-progress review by sending the URL to a colleague.
4. **localStorage persistence.** By default, the engine saves all state to `localStorage` keyed by page pathname. Closing and reopening the tab restores the prior review state. The Clear Review button removes all persisted state.

No authentication system is needed for the report itself. Access control, if required, comes from the hosting layer (network restrictions, signed URLs, or HTTP basic auth on the static host).

## Comparison to Existing Approaches

Several tools address the gap between terminal output and full applications. Each has a different trade-off.

**Claude Code plan mode.** Claude Code offers a built-in plan mode with three options: approve, reject, or edit. This is adequate for code changes. It does not support per-item triage of a list, visual severity coding, annotations, or structured action selection. The interactive report pattern is not a replacement for plan mode. It addresses a different category of work: review workflows with multiple items that require per-item decisions.

**Claude Artifacts.** Claude.ai can generate interactive HTML in the artifact panel. Artifacts support rich visual output but do not have a structured feedback capture mechanism. The user must describe their decisions in the chat. The interactive report pattern adds the structured feedback layer: the Copy Review Summary button produces parseable markdown from the user's interactions.

**Visual companion tools (localhost).** Some AI coding tools provide a localhost web server for visual output. These work for solo development but do not produce shareable artifacts. The interactive report pattern produces a static file that can be hosted anywhere.

**Streamlit, Gradio, or LangGraph dashboards.** These frameworks build interactive dashboards with Python backends. They require a running server, a deployment target, and often a separate tech stack from the AI coding tool. They are appropriate when the dashboard is a product. They are not appropriate when the dashboard is a review step in a larger AI workflow.

**Custom chat UIs.** Tools like Open WebUI or LibreChat provide chat interfaces with plugin systems. They operate at the conversation level, not the review-item level. Per-item triage with structured output is not part of their interaction model.

The interactive feedback report pattern is the only approach that combines: (a) visual review with severity coding and filtering, (b) per-item structured action selection, (c) clipboard-based structured feedback that an AI can parse deterministically, and (d) zero-infrastructure sharing as a single HTML file.

## Three Real Examples (Generalized)

### Example 1: Compliance Review Workflow

A data privacy team processes deletion requests under consumer protection regulations. Each request requires verifying the consumer's identity, discovering which partners received the consumer's data, checking for duplicate submissions, and classifying the request by complexity.

The prompt template runs 4 database queries: pending requests, consumer verification, partner discovery (joined by email across two separate systems), and existing opt-out status. Classification rules assign severity: requests involving fewer than 20 partners are routine (green), 20 or more partners trigger review (amber), identical email and phone in the same batch flag as duplicates (blue), and 50 or more partners escalate (red).

The generated dashboard shows 13 request cards. One request involves 40 partners across 469 data deliveries over 2 years, classified as "needs review." A pair of requests share the same email and phone, submitted 6 minutes apart, classified as "duplicate." The remaining 10 are routine.

Quick actions include: draft notification emails (grouped by partner), add to opt-out list, escalate, process standard deletion, mark as duplicate, and mark reviewed. The partner table inside the high-volume request card supports row flagging: the reviewer can flag specific partners with notes like "post count of 87 seems high" or "last activity 18 months ago, may be inactive."

After review, the structured summary routes to execution: email drafts go to the email client, opt-out records are prepared as SQL statements (shown for confirmation, not auto-executed), and escalations generate tickets in the project tracker.

### Example 2: Operations Dashboard

A marketplace platform generates a daily health report covering partner performance, campaign ROI, and system alerts. The prompt template pulls data from monitoring APIs and analytics tables.

Alert cards represent anomalies detected in the previous 24 hours: a partner's bid volume dropped 40% compared to the 7-day average, an acceptance rate fell below the contractual threshold, error rates spiked for a specific integration endpoint. Each alert has severity based on business impact (revenue at risk, contractual SLA, or informational).

Quick actions include: contact partner, create incident ticket, disable integration, adjust bid floor, and acknowledge (no action needed). The ROI table shows campaigns ranked by return, with row flagging for campaigns below the break-even threshold.

The feedback summary returns to the AI for routing: partner contacts generate email drafts, incident tickets route to the project tracker, configuration changes produce API calls or SQL statements for confirmation.

### Example 3: Experiment Triage

A product team runs 6 to 12 concurrent A/B tests. Weekly triage reviews each experiment's status: sample size progress, statistical significance, metric trends, and time elapsed.

Alert cards use severity based on experiment status: red for experiments showing statistically significant negative results on the primary metric, amber for experiments approaching planned duration without significance, green for experiments on track, and gray for recently launched experiments with insufficient data.

Quick actions include: extend duration by one week, stop experiment (negative result), graduate winner, request additional power analysis, and defer to next review. Collapsible detail tables show per-variant metrics (lift, p-value, sample size, confidence interval).

This example has not been built as a working dashboard. It is included to illustrate how the pattern generalizes to a third domain.

### Example 4: Planning Dashboard

A company plans an anniversary trip for 70 people across 4 venue options. Claude researches venues, pricing, activities, and logistics, then generates a planning dashboard for structured human review.

Alert cards represent venue options (4) and logistics alerts (3). Venue cards use severity to signal the recommendation: routine (green) for the recommended venue, anomaly (blue) for viable alternatives, and review (amber) for options with concerns. Logistics cards flag time-sensitive deadlines (action, red) and risks that affect specific venues (review, amber).

Quick actions are executable Claude instructions: "Request group rate quote from Omni La Costa for 35 rooms, June 15-19," "Build a detailed 5-day itinerary around La Costa with golf, spa, and kids camp." Dismissing a venue uses the checkbox with an inline note explaining the rejection, keeping the action pills clean for executable work.

Two standalone tables compare activities and budgets across all venues with row flagging. The reviewer flags specific line items ("Awards dinner at Coronado is $8,200 vs La Costa's $5,800") and annotates KPI values ("Board approved up to $95K"). The decision summary feeds back into Claude for execution: request quotes, build itineraries, draft hold requests.

This example exercises every engine feature: multi-action pills, inline annotations, collapsible detail tables, standalone tables with row flagging, severity filtering across 4 types, pipeline visualization, keyboard navigation, Share State for co-planners, and localStorage persistence.

## How to Build Your Own

Building a new interactive feedback report takes five steps. The first report in a new domain typically takes 30 to 60 minutes. Subsequent reports in the same domain reuse the prompt template and take 5 to 10 minutes.

### Step 1: Pick the Domain and Define the Item List

Identify what the human is reviewing. Each "item" becomes one alert card. Good candidates are:

- A list of requests, tickets, or incidents that need per-item decisions.
- A batch of records that need classification and triage.
- A set of metrics or entities that need anomaly review.

The item list should have 5 to 50 items. Fewer than 5 items do not justify the pattern (use plain text). More than 50 items need pagination or pre-filtering before the human sees them.

### Step 2: Define Alert Types and Severity Mapping

Map each item to a severity level. The engine template supports these built-in severity classes:

| Severity | Color | Use When |
|----------|-------|----------|
| `action` or `escalate` | Red | Requires immediate human action |
| `review` or `todo` | Amber | Needs investigation or decision |
| `anomaly` or `duplicate` | Blue | Informational, unusual pattern |
| `routine` or `ok` | Green | Standard processing, low risk |
| `info` | Gray | Context only, no action needed |

Define the classification rules in the prompt template. Rules should be deterministic: "fewer than 20 partners and no duplicates" maps to "routine." Avoid subjective criteria that the AI would need to interpret.

### Step 3: Design the Data Tables

If any alert card needs a detail table (a list of sub-items, a breakdown by category, historical records), define the table columns. Each table needs a `data-table-id` and each row needs a `data-row-id` for the flagging system to work.

Tables are optional. Many reports use alert cards without embedded tables.

### Step 4: Write the Quick Actions

Quick actions are the most important design decision. Each action pill contains a literal instruction string in its `data-action` attribute. This string appears verbatim in the review summary and is what the AI reads to determine what to execute.

Good quick actions are specific and unambiguous:

- "Draft notification emails for 40 partners" (specific count, specific verb)
- "Create incident ticket with P2 severity" (specific system, specific priority)
- "Extend experiment duration by 7 days" (specific parameter)

Bad quick actions are vague:

- "Handle this" (handle how?)
- "Follow up" (with whom, about what?)
- "Review later" (when? what specifically to review?)

Design 2 to 4 quick actions per alert type. The actions should cover the common decisions for that severity level.

### Step 5: Write the Prompt Template

The prompt template is a markdown file that tells the AI how to:

1. Gather the data (queries, API calls, file reads).
2. Classify each item by severity using the rules from Step 2.
3. Read the engine template file.
4. Replace the HTML placeholders with the classified items, KPI counts, and quick actions.
5. Save the generated HTML and open it in the browser.
6. (Optional) Process the pasted review summary by routing each section to an execution handler.

The prompt template references the engine template by file path. The engine template does not change between domains. Only the HTML content zone (alert cards, KPIs, tables) changes.

Wrap the prompt template in a skill file (for Claude Code) or a project instruction file (for Claude Desktop) to make it invocable by name.

## License

MIT
