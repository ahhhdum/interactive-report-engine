# Anniversary Trip Planning Dashboard: Design Spec

## Overview

A planning dashboard example for the interactive report engine. The scenario is a fictional but realistic EPCVIP company anniversary trip for 70 people (employees, spouses, kids). Claude researched 4 Southern California venue options and presents them alongside logistics alerts for structured human review.

This example serves as the showcase for the engine's planning use case, demonstrating every feature: severity-based filtering, multi-action pills, collapsible detail tables, standalone tables with row flagging, inline annotations, keyboard navigation, Copy Decision Summary, and Share State.

## File

`examples/anniversary-trip-planner.html`

Copies CSS and JS verbatim from `interactive-report-engine.html`. Only the HTML content zone differs.

## Body Attributes

```html
<body data-multiaction data-annotatable data-report-title="Decision" data-report-date="2026-03-21">
```

- `data-multiaction`: Venue cards support selecting multiple actions simultaneously (e.g., "Request quote" + "Build itinerary").
- `data-annotatable`: KPI values and specific claims in descriptions can be annotated inline.
- `data-report-title="Decision"`: The engine appends " Review" automatically, producing the heading "Decision Review — 2026-03-21". Setting the title to "Decision" reads naturally in the output.
- `data-report-date="2026-03-21"`: Date stamp for the summary output.
- No `data-no-persist`: localStorage persistence is on. The reviewer can close the tab and return later.

## Hero Section

- **Eyebrow:** Planning Dashboard
- **Title:** EPCVIP Anniversary Trip 2026
- **Subtitle:** Review venue options, flag concerns, and build a structured decision for the team.
- **Meta:** March 21, 2026 | 70 guests | 4 venues researched | 4-5 days

## KPI Cards (4)

| # | Value | Label | Color Class | Annotation ID | Why Annotatable |
|---|-------|-------|-------------|---------------|-----------------|
| 1 | 70 | Total Guests | `kpi-card--accent` | `kpi-guests` | Reviewer might note "includes 12 kids under 10" |
| 2 | 4 | Venues Researched | `kpi-card--green` | none | Static count, no annotation needed |
| 3 | $69K-$99K | Est. Budget Range | `kpi-card--amber` | `kpi-budget` | Reviewer might note "board approved up to $95K" |
| 4 | Jun 15-19 | Proposed Dates | `kpi-card--red` | `kpi-dates` | Reviewer might note "conflicts with Q2 close" |

## Pipeline

**Planning Pipeline** with 5 steps:

| Step | Label | State |
|------|-------|-------|
| 01 | Research | `pipe-step--done` |
| 02 | Shortlist | `pipe-step--done` |
| 03 | Review | `pipe-step--active` |
| 04 | Book | `pipe-step--pending` |
| 05 | Confirm | `pipe-step--pending` |

## Severity Types and Filter Bar

| Severity | CSS Class | Color | Used By |
|----------|-----------|-------|---------|
| recommended | `severity-recommended` | green | Omni La Costa |
| option | `severity-option` | blue | Terranea, Coronado |
| concern | `severity-concern` | amber | JW Marriott Desert Springs |
| action | `severity-action` | red | Room block deadline |
| review | `severity-review` | amber | Heat advisory, kids program gap |

The engine's CSS defines `severity-action`, `severity-review`, `severity-routine`, and `severity-anomaly`. The `data-severity` attribute values must match these existing CSS classes. No new CSS needed.

Severity mapping:

| Venue/Alert | data-severity | CSS class used | Color |
|-------------|---------------|----------------|-------|
| Omni La Costa | `routine` | `severity-routine` | green |
| Terranea | `anomaly` | `severity-anomaly` | blue |
| Hotel del Coronado | `anomaly` | `severity-anomaly` | blue |
| JW Marriott | `review` | `severity-review` | amber |
| Room block deadline | `action` | `severity-action` | red |
| Heat advisory | `review` | `severity-review` | amber |
| Kids program gap | `review` | `severity-review` | amber |

Filter buttons (using engine terms, but with planning-friendly labels):

```html
<button class="filter-btn active" onclick="filterCards('all')">All <span class="count"></span></button>
<button class="filter-btn" onclick="filterCards('routine')">Recommended <span class="count"></span></button>
<button class="filter-btn" onclick="filterCards('anomaly')">Options <span class="count"></span></button>
<button class="filter-btn" onclick="filterCards('review')">Needs Review <span class="count"></span></button>
<button class="filter-btn" onclick="filterCards('action')">Action Required <span class="count"></span></button>
```

## Alert Cards (7)

### Card 1: Omni La Costa Resort, Carlsbad

- **alert-id:** `venue-la-costa`
- **severity:** `routine` (green)
- **Badges:** `$289/night` (green), `4.3 stars` (muted), `12 min from office` (green), `Kids club 4-12` (green)
- **Description:** Full-service resort with golf, spa, pools, and kids camp. Similar vibe to last year's La Quinta. Known quantity for the team. Group rate confirmed for 35+ rooms. Two 18-hole golf courses on property. The most logistically simple option since most employees are local to North County.
- **Quick actions:**
  1. "Request group rate quote from Omni La Costa for 35 rooms, June 15-19"
  2. "Build a detailed 5-day itinerary around La Costa with golf, spa, and kids camp"
  3. "Draft announcement email to team with La Costa as the selected venue"
- **Collapsible table:** "Room Options (4 types)"

  | Room Type | Nightly Rate | Sleeps | Available |
  |-----------|-------------|--------|-----------|
  | Standard King | $289 | 2 | 40 |
  | Resort Suite | $419 | 4 | 12 |
  | Family Suite | $489 | 6 | 8 |
  | Villa | $629 | 8 | 4 |

### Card 2: Terranea Resort, Rancho Palos Verdes

- **alert-id:** `venue-terranea`
- **severity:** `anomaly` (blue)
- **Badges:** `$399/night` (amber), `4.6 stars` (green), `90 min from office` (amber), `Ocean cliffs` (muted)
- **Description:** Oceanfront cliffside resort on the Palos Verdes peninsula. The most visually striking venue. Spa is top-rated in LA County. Fine dining, tide pools, archery, falconry. Kids program exists but is seasonal. Need to confirm June availability. The 90-minute drive from the office means some employees may want to carpool or take a shuttle.
- **Quick actions:**
  1. "Request group rate quote from Terranea for 35 rooms, June 15-19"
  2. "Confirm Terranea kids program availability for June 15-19"
  3. "Too expensive, remove from consideration"
- **Collapsible table:** "Room Options (3 types)"

  | Room Type | Nightly Rate | Sleeps | Available |
  |-----------|-------------|--------|-----------|
  | Ocean View | $399 | 2 | 35 |
  | Casita | $529 | 4 | 10 |
  | Bungalow | $689 | 6 | 6 |

### Card 3: JW Marriott Desert Springs, Palm Desert

- **alert-id:** `venue-desert-springs`
- **severity:** `review` (amber)
- **Badges:** `$249/night` (green), `4.1 stars` (muted), `2.5 hrs from office` (amber), `Gondola rides` (muted), `105 deg F in June` (red)
- **Description:** Largest property at 450 acres with indoor gondola waterways, five pools, lazy river, and two golf courses. Best value per night across all options. The major concern is June heat in the desert: average high of 105 deg F limits outdoor activities to early morning and evening. The 2.5-hour drive also means a full travel day on arrival and departure. Some team members flagged desert heat as a dealbreaker when it came up last year.
- **Quick actions:**
  1. "Request group rate quote from JW Marriott for 35 rooms, June 15-19"
  2. "Research indoor and evening activity options for extreme heat days"
  3. "Too hot in June, remove from consideration"
- **Collapsible table:** "Room Options (4 types)"

  | Room Type | Nightly Rate | Sleeps | Available |
  |-----------|-------------|--------|-----------|
  | Resort View | $249 | 2 | 50 |
  | Pool View | $289 | 3 | 20 |
  | Suite | $379 | 4 | 10 |
  | Presidential | $599 | 6 | 3 |

### Card 4: Hotel del Coronado, Coronado Island

- **alert-id:** `venue-coronado`
- **severity:** `anomaly` (blue)
- **Badges:** `$349/night` (amber), `4.4 stars` (green), `25 min from office` (green), `Beach access` (green), `Historic landmark` (muted)
- **Description:** Iconic beachfront hotel built in 1888. Walking distance to shops and restaurants on Orange Avenue. Beach bonfires available for private group events. The concern is that Coronado is 25 minutes from the office, so it may not feel like a "getaway" for local employees. The flip side: zero travel logistics, no flight costs, and anyone can drive home if they need to. The beach and historic setting are genuinely memorable.
- **Quick actions:**
  1. "Request group rate quote from Hotel del Coronado for 35 rooms, June 15-19"
  2. "Build a detailed 5-day itinerary around Coronado with beach and downtown activities"
  3. "Too close to home, remove from consideration"
- **Collapsible table:** "Room Options (4 types)"

  | Room Type | Nightly Rate | Sleeps | Available |
  |-----------|-------------|--------|-----------|
  | Victorian Room | $349 | 2 | 30 |
  | Ocean View | $429 | 2 | 15 |
  | Cabana Suite | $549 | 4 | 8 |
  | Cottage | $729 | 6 | 4 |

### Card 5: Room Block Deadline: April 16

- **alert-id:** `alert-room-block`
- **severity:** `action` (red)
- **Badges:** `26 days away` (red), `35 rooms needed` (amber)
- **Description:** Group rates at all four venues require a signed room block contract 60 days before arrival. For a June 15 arrival, the deadline is April 16. Missing this deadline means paying rack rates, which adds $15K-$22K to the total budget depending on the venue. The recommendation is to place holds at the top 2 venues now, then release the one not selected.
- **Quick actions:**
  1. "Draft room block hold requests for top 2 venues"
  2. "Extend deadline negotiation with preferred venue"

### Card 6: June Heat Advisory for Desert Venues

- **alert-id:** `alert-heat`
- **severity:** `review` (amber)
- **Badges:** `Avg high 105 deg F` (red), `Palm Desert only` (muted)
- **Description:** Average high temperature in Palm Desert in mid-June is 105 deg F. Outdoor activities like golf, pool parties, and group dinners on the terrace are comfortable only before 10am and after 7pm. This applies to JW Marriott Desert Springs only. The three coastal venues (Carlsbad, Palos Verdes, Coronado) average 72-76 deg F in June.
- **Quick actions:**
  1. "Add heat mitigation plan to JW Marriott itinerary"
  2. "Dismiss, already factored into venue evaluation"

### Card 7: Kids Program Coverage Gap

- **alert-id:** `alert-kids`
- **severity:** `review` (amber)
- **Badges:** `12 kids expected` (amber), `Ages 2-14` (muted)
- **Description:** Omni La Costa and Hotel del Coronado have confirmed year-round kids programs covering ages 4-12. Terranea's kids program is seasonal and not yet confirmed for June. JW Marriott has a kids club that closes at 2pm daily. For evening group events (welcome dinner, awards dinner), three of four venues need supplemental childcare arrangements. The youngest child in the group is 2, which is below most hotel program minimums.
- **Quick actions:**
  1. "Get childcare vendor quotes for evening coverage at all venues"
  2. "Confirm Terranea June kids program availability"
  3. "Dismiss, parents will self-organize childcare"

## Standalone Tables

### Activity Comparison

- **Section label:** "Activity Comparison Across Venues"
- **data-table-id:** `activities`
- All rows are flaggable with `data-row-id`

| data-row-id | Activity | La Costa | Terranea | Desert Springs | Coronado | Est. Cost |
|-------------|----------|----------|----------|----------------|----------|-----------|
| `act-welcome` | Welcome dinner | Courtyard terrace | Ocean terrace | Lakeside pavilion | Beach bonfire | $4,200-$6,800 |
| `act-golf` | Golf tournament | On-site (36 holes) | Nearby (Trump Nat'l) | On-site (36 holes) | Nearby (Coronado GC) | $3,500-$5,200 |
| `act-spa` | Spa half-day | On-site | On-site (top rated) | On-site | On-site | $2,800-$4,100 |
| `act-pool` | Pool party | 3 pools | 1 pool + ocean | 5 pools + lazy river | 2 pools + beach | $1,200-$2,400 |
| `act-kids` | Kids day camp | On-site (ages 4-12) | Seasonal (TBD) | On-site (closes 2pm) | On-site (ages 4-12) | $800-$1,200 |
| `act-team` | Team building | Escape room pkg | Kayak + paddleboard | Desert jeep tour | Sailing charter | $2,400-$3,600 |
| `act-awards` | Awards dinner | Grand ballroom | Catalina room | Desert ballroom | Crown room | $5,800-$8,200 |
| `act-free` | Free day options | Beach, shops, Legoland | Tide pools, hiking | Outlet mall, Indian Wells | Beach, Gaslamp, zoo | $0 (self-directed) |

### Budget Breakdown

- **Section label:** "Budget Breakdown by Venue"
- **data-table-id:** `budget`
- All rows are flaggable with `data-row-id`

| data-row-id | Line Item | La Costa | Terranea | Desert Springs | Coronado |
|-------------|-----------|----------|----------|----------------|----------|
| `bud-rooms` | Rooms (35 rooms x 4 nights) | $40,460 | $55,860 | $34,860 | $48,860 |
| `bud-welcome` | Welcome dinner | $4,200 | $5,800 | $4,400 | $6,800 |
| `bud-golf` | Golf tournament | $3,500 | $5,200 | $3,800 | $4,200 |
| `bud-spa` | Spa package | $2,800 | $4,100 | $2,800 | $3,200 |
| `bud-pool` | Pool party + activities | $3,600 | $3,400 | $3,200 | $3,600 |
| `bud-team` | Team building event | $2,400 | $3,600 | $2,800 | $3,400 |
| `bud-awards` | Awards dinner | $5,800 | $7,200 | $5,600 | $8,200 |
| `bud-kids` | Kids program | $800 | $1,200 | $900 | $800 |
| `bud-transport` | Transportation/shuttles | $1,200 | $3,800 | $4,200 | $1,400 |
| `bud-contingency` | Contingency (10%) | $6,476 | $9,016 | $6,256 | $8,046 |
| `bud-total` | **Total** | **$71,236** | **$99,176** | **$68,816** | **$88,506** |

## Footer

"Generated by Claude Code on March 21, 2026. Data sourced from venue websites, Google Reviews, and historical weather averages."

## Copy Decision Summary Output

When the user clicks "Copy Review Summary," the engine produces structured markdown. With `data-report-title="Decision"`, the heading is `## Decision Review — 2026-03-21`. Example output from a plausible review session:

```markdown
## Decision Review — 2026-03-21

### Actions Selected
- Omni La Costa Resort, Carlsbad: "Request group rate quote from Omni La Costa for 35 rooms, June 15-19"
- Omni La Costa Resort, Carlsbad: "Build a detailed 5-day itinerary around La Costa with golf, spa, and kids camp"
- Room Block Deadline: April 16: "Draft room block hold requests for top 2 venues"

### Dismissed (Reviewed)
- [x] JW Marriott Desert Springs, Palm Desert (review) — too hot in June
- [x] June Heat Advisory for Desert Venues (review)

### Notes
- Terranea Resort, Rancho Palos Verdes: "Beautiful venue but $99K total is over the $95K board cap. Could work if we cut golf tournament."

### Flagged Items
- Awards dinner (act-awards): "Crown room at Coronado is $8,200, nearly double La Costa's $5,800"
- Rooms (bud-rooms): "Terranea rooms alone are $55K, that is 56% of $95K budget"

### Annotations
- [kpi-budget] "$69K-$99K": "Board approved up to $95K. Terranea is over."
- [kpi-dates] "Jun 15-19": "Confirm no conflict with Q2 close week."

### Still Open
- [ ] Terranea Resort, Rancho Palos Verdes (anomaly)
- [ ] Hotel del Coronado, Coronado Island (anomaly)
- [ ] Kids Program Coverage Gap (review)
```

This output is deterministic and machine-parseable. Claude can read it back and execute: request the quotes, build the itinerary, draft the hold requests, and flag the open items for follow-up.

## Engine Feature Coverage

| Feature | How Exercised |
|---------|--------------|
| Severity filtering | 4 types across 7 cards: routine (green), anomaly (blue), review (amber), action (red) |
| Multi-action pills | Venue cards support selecting 2+ actions simultaneously |
| Collapsible detail tables | Room type breakdowns inside each of 4 venue cards |
| Standalone tables | Activity comparison (8 rows) + budget breakdown (11 rows) |
| Row flagging | Flag specific activities or budget line items across 19 flaggable rows |
| Inline notes | Free-text per card for reviewer commentary |
| Annotations | 3 annotatable KPI values (guests, budget, dates) |
| Pipeline | 5-step planning workflow with step 3 active |
| Keyboard navigation | j/k through 7 cards, x to dismiss, number keys for actions, n for note |
| Copy summary | "Decision Review" heading with all 6 structured sections |
| Share State | URL hash encoding for sharing with co-planners |
| localStorage | Persistent state across tab close/reopen |
| Dynamic filter counts | Filter buttons show live counts (feature from PR #1) |

## Implementation Notes

- **Page title:** `<title>EPCVIP Anniversary Trip 2026 — Planning Dashboard</title>`
- Copy CSS and JS from `interactive-report-engine.html` verbatim. No modifications.
- Use existing severity CSS classes (`severity-routine`, `severity-anomaly`, `severity-review`, `severity-action`). No new CSS needed.
- Filter button labels can differ from severity values. The `onclick="filterCards('routine')"` matches the `data-severity` attribute, while the button text says "Recommended."
- Dollar amounts in tables use the `.num` class for right-alignment.
- Collapsible room tables inside venue cards are display-only. They do not need `data-table-id` or `data-row-id` attributes and are not flaggable. The standalone activity and budget tables are the flaggable ones.
- Badge colors not explicitly specified default to muted (no color class). Specified colors: green for positive attributes, amber for moderate concerns, red for significant concerns.
- The example prompt template (`examples/anniversary-trip-prompt.md`) is out of scope for this spec. It can be added later to show how Claude would generate this dashboard from a natural language request.
