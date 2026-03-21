# Anniversary Trip Planning Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `examples/anniversary-trip-planner.html` as the showcase planning dashboard example for the interactive report engine.

**Architecture:** Single self-contained HTML file. CSS and JS are copied verbatim from the engine template (`interactive-report-engine.html` lines 8-274 for CSS, 458-1173 for JS). Only the HTML content zone (hero, KPIs, pipeline, filter bar, alert cards, standalone tables, footer) is custom. No build step, no dependencies.

**Tech Stack:** HTML, inline CSS, inline JS (all from the engine template)

**Spec:** `docs/superpowers/specs/2026-03-21-anniversary-trip-dashboard-design.md`

---

### Task 1: Scaffold the file with template CSS/JS and body attributes

**Files:**
- Create: `examples/anniversary-trip-planner.html`
- Read: `interactive-report-engine.html` (source for CSS lines 8-274 and JS lines 458-1173)

- [ ] **Step 1: Create the HTML file with head, CSS, body tag, and JS**

Copy the engine template's `<!DOCTYPE>` through `</head>` (lines 1-275), replacing only the `<title>` tag. Then add the `<body>` tag with the spec's data attributes. Then copy the keyboard hint, action bar, and `<script>` block (lines 436-1173) at the bottom. Leave the content zone empty for now.

```html
<title>EPCVIP Anniversary Trip 2026 — Planning Dashboard</title>
```

```html
<body data-multiaction data-annotatable data-report-title="Decision" data-report-date="2026-03-21">
<div class="container">
  <!-- Content goes here in subsequent tasks -->
</div>
<!-- Copy keyboard hint (lines 436-446), action bar (448-456), and script (458-1173) from template -->
</body>
```

- [ ] **Step 2: Verify the file opens in a browser**

Run: `wc -l examples/anniversary-trip-planner.html`
Expected: ~750 lines (CSS + JS + empty content zone)

Open in browser. Should show an empty dark page with the action bar at the bottom.

- [ ] **Step 3: Commit**

```bash
git add examples/anniversary-trip-planner.html
git commit -m "Scaffold anniversary trip planner with engine CSS/JS"
```

---

### Task 2: Add hero section, KPI cards, and pipeline

**Files:**
- Modify: `examples/anniversary-trip-planner.html` (content zone)

- [ ] **Step 1: Add hero section**

Insert after `<div class="container">`:

```html
<header class="hero anim-up" style="--i:0">
  <div class="hero-eyebrow">Planning Dashboard</div>
  <h1>EPCVIP Anniversary Trip 2026</h1>
  <div class="hero-sub">Review venue options, flag concerns, and build a structured decision for the team.</div>
  <div class="hero-meta">March 21, 2026 | 70 guests | 4 venues researched | 4-5 days</div>
</header>
```

- [ ] **Step 2: Add KPI cards**

KPI card 1 uses `kpi-card--accent` with `data-annotation-id="kpi-guests"` on the value div. KPI card 2 uses `kpi-card--green` with no annotation. KPI card 3 uses `kpi-card--amber` with `data-annotation-id="kpi-budget"`. KPI card 4 uses `kpi-card--red` with `data-annotation-id="kpi-dates"`.

```html
<div class="kpi-row">
  <div class="kpi-card kpi-card--accent anim-scale" style="--i:1">
    <div class="kpi-card__value" data-annotation-id="kpi-guests">70</div>
    <div class="kpi-card__label">Total Guests</div>
  </div>
  <div class="kpi-card kpi-card--green anim-scale" style="--i:2">
    <div class="kpi-card__value">4</div>
    <div class="kpi-card__label">Venues Researched</div>
  </div>
  <div class="kpi-card kpi-card--amber anim-scale" style="--i:3">
    <div class="kpi-card__value" data-annotation-id="kpi-budget">$69K-$99K</div>
    <div class="kpi-card__label">Est. Budget Range</div>
  </div>
  <div class="kpi-card kpi-card--red anim-scale" style="--i:4">
    <div class="kpi-card__value" data-annotation-id="kpi-dates">Jun 15-19</div>
    <div class="kpi-card__label">Proposed Dates</div>
  </div>
</div>
```

- [ ] **Step 3: Add pipeline**

```html
<div class="pipeline-section anim-up" style="--i:5">
  <div class="section-label">Planning Pipeline</div>
  <div class="pipeline">
    <div class="pipe-step pipe-step--done"><div class="pipe-step__num">01</div><div class="pipe-step__name">Research</div></div>
    <div class="pipe-arrow">&rarr;</div>
    <div class="pipe-step pipe-step--done"><div class="pipe-step__num">02</div><div class="pipe-step__name">Shortlist</div></div>
    <div class="pipe-arrow">&rarr;</div>
    <div class="pipe-step pipe-step--active"><div class="pipe-step__num">03</div><div class="pipe-step__name">Review</div></div>
    <div class="pipe-arrow">&rarr;</div>
    <div class="pipe-step pipe-step--pending"><div class="pipe-step__num">04</div><div class="pipe-step__name">Book</div></div>
    <div class="pipe-arrow">&rarr;</div>
    <div class="pipe-step pipe-step--pending"><div class="pipe-step__num">05</div><div class="pipe-step__name">Confirm</div></div>
  </div>
</div>
```

- [ ] **Step 4: Verify in browser**

Open the file. Should show: hero with title, 4 colored KPI cards, pipeline with steps 1-2 done, step 3 active, steps 4-5 pending. Click the KPI values for "70", "$69K-$99K", and "Jun 15-19" to confirm annotation textareas appear (dashed underline on hover).

- [ ] **Step 5: Commit**

```bash
git add examples/anniversary-trip-planner.html
git commit -m "Add hero, KPI cards, and pipeline to trip planner"
```

---

### Task 3: Add filter bar and the 4 venue cards

**Files:**
- Modify: `examples/anniversary-trip-planner.html`

- [ ] **Step 1: Add filter bar**

```html
<div class="anim-up" style="--i:6">
  <div class="section-label">Options &amp; Alerts</div>
  <div class="filter-bar">
    <button class="filter-btn active" onclick="filterCards('all')">All</button>
    <button class="filter-btn" onclick="filterCards('routine')">Recommended</button>
    <button class="filter-btn" onclick="filterCards('anomaly')">Options</button>
    <button class="filter-btn" onclick="filterCards('review')">Needs Review</button>
    <button class="filter-btn" onclick="filterCards('action')">Action Required</button>
    <span class="filter-count" id="visible-count"></span>
  </div>
</div>
```

- [ ] **Step 2: Add alerts container and Card 1 (Omni La Costa)**

Open `<div class="alerts-container" id="alerts-container">` and add the first venue card. Key details:
- `data-alert-id="venue-la-costa"` `data-severity="routine"`
- CSS class: `severity-routine`
- 4 badges: `$289/night` (green), `4.3 stars` (muted), `12 min from office` (green), `Kids club 4-12` (green)
- Description includes annotatable span: `<span data-annotation-id="ann-la-costa-group">Group rate confirmed for 35+ rooms</span>`
- 3 quick action pills
- Collapsible room table using plain `<table>` (NOT `.data-table`), no `data-table-id`, no `data-row-id`

- [ ] **Step 3: Add Card 2 (Terranea)**

- `data-alert-id="venue-terranea"` `data-severity="anomaly"`
- CSS class: `severity-anomaly`
- 4 badges: `$399/night` (amber), `4.6 stars` (green), `90 min from office` (amber), `Ocean cliffs` (muted)
- 3 quick action pills
- Collapsible room table (plain `<table>`, 3 rows)

- [ ] **Step 4: Add Card 3 (JW Marriott Desert Springs)**

- `data-alert-id="venue-desert-springs"` `data-severity="review"`
- CSS class: `severity-review`
- 5 badges: `$249/night` (green), `4.1 stars` (muted), `2.5 hrs from office` (amber), `Gondola rides` (muted), `105°F in June` (red)
- Description includes annotatable span: `<span data-annotation-id="ann-desert-heat">average high of 105°F</span>`
- 3 quick action pills
- Collapsible room table (plain `<table>`, 4 rows)

- [ ] **Step 5: Add Card 4 (Hotel del Coronado)**

- `data-alert-id="venue-coronado"` `data-severity="anomaly"`
- CSS class: `severity-anomaly`
- 4 badges: `$349/night` (amber), `4.4 stars` (green), `25 min from office` (green), `Beach access` (green), `Historic landmark` (muted)
- 3 quick action pills
- Collapsible room table (plain `<table>`, 4 rows)

- [ ] **Step 6: Verify in browser**

Open the file. Verify:
1. All 4 venue cards render with correct border colors (green, blue, amber, blue)
2. Filter buttons work: "Recommended" shows only La Costa, "Options" shows Terranea and Coronado, "Needs Review" shows Desert Springs
3. Quick action pills are clickable and multi-select works (can select 2+ on same card)
4. Collapsible room tables expand/collapse but rows are NOT clickable/highlightable
5. The two annotation spans (`ann-la-costa-group`, `ann-desert-heat`) show dashed underlines and open annotation textareas on click
6. Keyboard: j/k navigates between cards, x dismisses, number keys select actions, n opens note

- [ ] **Step 7: Commit**

```bash
git add examples/anniversary-trip-planner.html
git commit -m "Add filter bar and 4 venue cards to trip planner"
```

---

### Task 4: Add the 3 alert cards

**Files:**
- Modify: `examples/anniversary-trip-planner.html`

- [ ] **Step 1: Add Card 5 (Room Block Deadline)**

- `data-alert-id="alert-room-block"` `data-severity="action"`
- CSS class: `severity-action`
- 2 badges: `26 days away` (red), `35 rooms needed` (amber)
- 2 quick action pills
- No collapsible table

- [ ] **Step 2: Add Card 6 (June Heat Advisory)**

- `data-alert-id="alert-heat"` `data-severity="review"`
- CSS class: `severity-review`
- 2 badges: `Avg high 105°F` (red), `Palm Desert only` (muted)
- 2 quick action pills
- No collapsible table

- [ ] **Step 3: Add Card 7 (Kids Program Coverage Gap)**

- `data-alert-id="alert-kids"` `data-severity="review"`
- CSS class: `severity-review`
- 2 badges: `12 kids expected` (amber), `Ages 2-14` (muted)
- 3 quick action pills
- No collapsible table

Close the `</div>` for `alerts-container`.

- [ ] **Step 4: Verify in browser**

Verify:
1. "Action Required" filter shows only Room Block Deadline (red border)
2. "Needs Review" filter shows Desert Springs + Heat Advisory + Kids Program (3 cards, amber)
3. "All" shows all 7 cards
4. Filter counts update correctly
5. Dismiss checkbox works on alert cards

- [ ] **Step 5: Commit**

```bash
git add examples/anniversary-trip-planner.html
git commit -m "Add 3 alert cards (deadline, heat, kids) to trip planner"
```

---

### Task 5: Add standalone tables and footer

**Files:**
- Modify: `examples/anniversary-trip-planner.html`

- [ ] **Step 1: Add Activity Comparison table**

After the `alerts-container` closing div, add the standalone table section. This table uses `.data-table` with `data-table-id="activities"`. Every `<tr>` in `<tbody>` gets a `data-row-id`. The Activity column is a regular `<td>`, all other columns are regular `<td>`, and the Est. Cost column uses `class="num"` for right-alignment.

8 rows: act-welcome, act-golf, act-spa, act-pool, act-kids, act-team, act-awards, act-free.

- [ ] **Step 2: Add Budget Breakdown table**

Same pattern: `.data-table` with `data-table-id="budget"`. All `<tr>` in `<tbody>` get `data-row-id`. All dollar columns use `class="num"`. The total row (`bud-total`) uses `<strong>` tags.

11 rows: bud-rooms, bud-welcome, bud-golf, bud-spa, bud-pool, bud-team, bud-awards, bud-kids, bud-transport, bud-contingency, bud-total.

- [ ] **Step 3: Add footer**

```html
<div class="footer anim-up" style="--i:99">
  Generated by Claude Code on March 21, 2026. Data sourced from venue websites, Google Reviews, and historical weather averages.
  <br>Keyboard shortcuts: press <kbd>?</kbd> for help.
</div>
```

- [ ] **Step 4: Verify in browser**

Verify:
1. Both tables render with correct data from the spec
2. Click any row in the Activity table: blue highlight appears, inline text input for a note shows
3. Click any row in the Budget table: same flagging behavior
4. Flag 2-3 rows, then click "Copy Review Summary": verify the Flagged Items section appears in the copied markdown with the correct row IDs and any notes
5. Room tables inside venue cards do NOT have this click-to-flag behavior

- [ ] **Step 5: Commit**

```bash
git add examples/anniversary-trip-planner.html
git commit -m "Add activity and budget tables plus footer to trip planner"
```

---

### Task 6: End-to-end verification

**Files:**
- Read: `examples/anniversary-trip-planner.html`
- Read: `docs/superpowers/specs/2026-03-21-anniversary-trip-dashboard-design.md`

This task is verification only. No code changes unless a defect is found.

- [ ] **Step 1: Verify body attributes**

Open the file and confirm `<body>` tag has all four attributes: `data-multiaction`, `data-annotatable`, `data-report-title="Decision"`, `data-report-date="2026-03-21"`.

- [ ] **Step 2: Verify all 7 cards filter correctly**

Click each filter button and count visible cards:
- All: 7
- Recommended: 1 (La Costa)
- Options: 2 (Terranea, Coronado)
- Needs Review: 3 (Desert Springs, Heat Advisory, Kids Program)
- Action Required: 1 (Room Block Deadline)

- [ ] **Step 3: Verify only 5 annotation targets are clickable**

Hover over each of these and confirm dashed underline + click opens textarea:
1. KPI "70" (`kpi-guests`)
2. KPI "$69K-$99K" (`kpi-budget`)
3. KPI "Jun 15-19" (`kpi-dates`)
4. "Group rate confirmed for 35+ rooms" in Card 1 (`ann-la-costa-group`)
5. "average high of 105°F" in Card 3 (`ann-desert-heat`)

No other elements should be annotatable.

- [ ] **Step 4: Verify Copy Review Summary output**

Perform a representative review session:
1. Select "Request group rate quote" on La Costa
2. Select "Build a detailed 5-day itinerary" on La Costa
3. Dismiss Desert Springs with note "too hot in June"
4. Add a note on Terranea: "beautiful but over budget"
5. Flag the "Awards dinner" row in the Activity table with note "Coronado is most expensive"
6. Annotate the budget KPI with "board cap is $95K"
7. Click "Copy Review Summary"

Verify the clipboard contains:
- Heading: `## Decision Review — 2026-03-21`
- Actions Selected section with the two La Costa actions (no severity in parens)
- Dismissed section with Desert Springs `(review) — too hot in June`
- Notes section with Terranea note
- Flagged Items section with Awards dinner row
- Annotations section with kpi-budget entry
- Still Open section listing remaining unchecked cards

- [ ] **Step 5: Verify embedded room tables are not flaggable**

Click on a row in any venue card's collapsible room table. Confirm no blue highlight, no inline note input appears.

- [ ] **Step 6: Commit (only if fixes were needed)**

```bash
git add examples/anniversary-trip-planner.html
git commit -m "Fix defects found during end-to-end verification"
```

---

### Task 7: Update README and commit planning dashboard design notes

**Files:**
- Modify: `README.md` (add planning use case mention)
- Stage: `docs/planning-dashboard-design.md` (currently untracked)

- [ ] **Step 1: Add planning example to README**

Find the section that lists examples (or the relevant section describing use cases). Add a brief entry for the anniversary trip planner alongside the existing operations dashboard mention.

- [ ] **Step 2: Stage the planning dashboard design notes**

`docs/planning-dashboard-design.md` has been untracked since last session. Stage and commit it as part of this work.

- [ ] **Step 3: Commit**

```bash
git add README.md docs/planning-dashboard-design.md
git commit -m "Add planning dashboard example to README and stage design notes"
```
