# Interactive Template Pattern

AI generates a rich HTML report. You review it in a browser. Your clicks, dismissals, and notes become structured feedback. You paste it back. AI acts on it.

## The 3-Layer Architecture

```
┌─────────────────────────────────────────────────┐
│  Layer 1: Prompt Template                       │
│  Instructions for the AI: what data to fetch,    │
│  what calculations to run, what HTML to produce  │
├─────────────────────────────────────────────────┤
│  Layer 2: HTML Template                         │
│  Pre-built CSS + JS with placeholder comments   │
│  AI fills in data, writes to /tmp, you open it  │
├─────────────────────────────────────────────────┤
│  Layer 3: Feedback Loop                         │
│  JS tracks your interactions → generates         │
│  structured markdown → you paste back into AI   │
└─────────────────────────────────────────────────┘
```

## Layer 1: Prompt Template

A markdown file that tells the AI what to do. Not code, but instructions.

**Structure:**
1. **Setup**, where to get data (API calls, database queries, file reads)
2. **Calculations**, derived metrics, anomaly detection, comparisons
3. **Generate HTML**, read the template file, replace placeholder comments with real content
4. **Write Output**, save to /tmp, print a summary, prompt user to review
5. **Wait for Feedback**, tell user to open browser, review, copy summary, paste back

The prompt template never contains HTML or CSS. It references the HTML template file and describes what to inject at each placeholder.

## Layer 2: HTML Template

A single `.html` file with three zones:

1. **CSS** (~300 lines), dark theme, severity colors, responsive layout. Write once, reuse across every report. The same stylesheet works for marketplace operations, financial data, or any domain.

2. **HTML structure**, placeholder comments (`<!-- ALERTS -->`, `<!-- TABLE_DATA -->`) mark where AI injects content. The template works standalone (shows "no data" placeholders) and fully populated.

3. **JavaScript** (~350 lines), interaction engine. Completely domain-agnostic:
   - Checkbox dismiss with animation
   - Quick action pill selection (copies to clipboard)
   - Inline note textareas on alerts
   - Click-to-flag table rows with note input
   - Keyboard navigation (j/k/x/1-5/n/c/s/?)
   - "Copy Review Summary" produces structured markdown

The JS does not know whether it is tracking partner performance, experiment results, or financial accounts. It tracks `data-alert-id` and `data-account` attributes.

## Layer 3: Feedback Loop

When you click "Copy Review Summary", the JS collects all interactions into markdown:

```markdown
## Action Dashboard Review, 2026-03-20

### Quick Actions
- Partner "CreditServe", EPL Down 34%: "Query CreditServe daily EPL, sell rate, and reject reasons for the last 14 days. Break down by traffic type."
- Experiment "RLA-ReAsk-v2", Reached Significance: "Draft a message recommending ship to 100%."

### Dismissed
- [x] All Ping Trees Active, Lead Flow Normal

### Notes
- Funnel Step 3 to 4 Conversion Down 11%: "Suspect mobile rendering. Engineering team is already looking at this."

### Flagged Items
- CreditServe: "Was fine last week. Likely buyer-side cap hit. Check with account manager."
- EngageTier-Rebalance: "21 days, -1.4% EPC. Kill this experiment."

### Still Open
- [ ] SMS Traffic, Volume 2.4x Weekly Average
- [ ] 3 Partner Contracts Up for Renewal This Month
```

You paste this back into Claude Code or Claude Desktop. The AI parses the structured markdown and acts, running queries, drafting messages, creating tickets, and executing slash commands. Each quick action is a ready-to-use instruction.

## Build Your Own, 5 Steps

1. **Pick your domain.** What data do you review regularly? What decisions do you make?
2. **Define your alert types.** Map them to severity levels (red/blue/amber/gray/green).
3. **Design your tables.** What rows would you flag or annotate?
4. **Write quick actions.** Define 2 to 3 response options per alert type (the most common things you would say).
5. **Write the prompt template.** Write instructions for the AI to fetch data and fill the template.

## Example Domains by Role

| Role | Domain | Hero Stats | Alert Types |
|------|--------|-----------|-------------|
| Owner / Leadership | Revenue Dashboard | Revenue, Margin %, EPC trend, Fraud flags | Revenue drops, margin compression, experiment coverage |
| Client Relations | Partner Health | Partner EPL, Sell rate, Contract status, Quality score | EPL decline, contract renewal, quality threshold breach |
| Product Manager | Experiment and Funnel | Active experiments, Funnel conversion, Feature rollout | Experiment ready for decision, funnel dropout, deployment risk |
| Media Buy | Campaign ROI | Spend, EPC by source, ROAS, Traffic volume | Spend overpace, EPC decline, quality flag on traffic source |
| Engineering | System Health | Uptime, Pipeline freshness, API latency, Error rate | Stale pipeline, partner timeout, deployment failure |
| Finance | Revenue and Billing | Revenue, Partner payables, Margin, Fund rate | Invoice discrepancy, margin anomaly, late payment |

The CSS, JS, and feedback loop are identical across all of these. Only the data and alert definitions change.

## Engine Features

The formalized template (`interactive-report-engine.html`) adds four capabilities beyond the original pattern described above. All four are controlled by `data-*` attributes on the `<body>` element or enabled by default.

### Multi-Select Action Pills

By default, clicking an action pill on an alert card deselects any previous selection on that card. Adding `data-multiaction` to the body element allows selecting multiple pills per card. This is useful when a single alert requires more than one follow-up action.

### Inline Annotations

Adding `data-annotatable` to the body element enables click-to-annotate on any element that carries a `data-annotation-id` attribute. Clicking the element opens an inline text input. The annotation text is included in the exported review summary.

### localStorage Persistence

The engine saves all review state to localStorage by default. Dismissed items, selected actions, notes, and flagged rows survive page reloads and browser restarts. Adding `data-no-persist` to the body element disables this behavior.

### Decision Groups

When a dashboard presents alternatives the reviewer must choose between (Option A vs Option B), wrap those options in a `.decision-group` container instead of listing them as flat alert cards. The decision group frames a question, presents options as standard alert cards, and optionally includes a side-by-side comparison table. The filter bar does not apply to cards inside decision groups. Cards inside decision groups use the same state system as flat cards: dismiss, notes, actions, and keyboard navigation all work identically.

### Shareable URL State

The Share State button encodes review state as a URL hash fragment. Opening a shared URL imports the state on first load, then strips the hash from the URL. Subsequent reloads and edits persist via localStorage.

## Generating Reports

The `/action-report` skill automates the end-to-end flow: it reads a domain configuration, fetches live data, populates the template placeholders, and writes a ready-to-review HTML file to `/tmp`. Running `/action-report` is the recommended way to produce new reports from this template rather than manually copying and editing the HTML.
