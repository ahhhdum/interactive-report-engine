# Action Dashboard — Prompt Template

Generate a daily action dashboard for marketplace operations using mock data.

---

## 1. Setup

This is a demo — no analytics queries, API calls, or authentication needed. All data is hardcoded below.

Read the HTML template file at `training-program/assets/action-dashboard-template.html`.

## 2. Mock Data

Use these 4 data objects as if they were analytics query results or API responses.

### Partner Performance

```json
{
  "partners": [
    {"name": "CreditServe", "status": "declining", "leads_sold": 2840, "epl": 28.20, "epl_prior": 42.80, "revenue": 80088, "revenue_share_pct": 18},
    {"name": "NorthBridge Financial", "status": "active", "leads_sold": 1420, "epl": 44.60, "epl_prior": 43.90, "revenue": 63332, "revenue_share_pct": 14},
    {"name": "QuickFund Direct", "status": "active", "leads_sold": 1180, "epl": 38.90, "epl_prior": 39.10, "revenue": 45902, "revenue_share_pct": 10},
    {"name": "PeakLend Solutions", "status": "active", "leads_sold": 890, "epl": 34.50, "epl_prior": 33.80, "revenue": 30705, "revenue_share_pct": 7},
    {"name": "MeridianCap", "status": "active", "leads_sold": 510, "epl": 32.10, "epl_prior": 31.50, "revenue": 16371, "revenue_share_pct": 4}
  ]
}
```

### Traffic Sources

```json
{
  "traffic": [
    {"type": "Internal Media Buy", "source": null, "clicks": 84200, "epc": 1.52, "margin_pct": 38.2},
    {"type": "External Media Buy", "source": null, "clicks": 46100, "epc": 1.34, "margin_pct": 31.7},
    {"type": "SMS", "source": "PulseMedia", "clicks": 12400, "epc": 1.38, "margin_pct": 44.1, "weekly_avg_clicks": 5200},
    {"type": "Email", "source": null, "clicks": 18600, "epc": 1.18, "margin_pct": 28.9},
    {"type": "Push", "source": null, "clicks": 9200, "epc": 0.94, "margin_pct": 22.4},
    {"type": "Affiliate", "source": "TrafficMax", "clicks": 22800, "epc": 1.61, "margin_pct": 41.3},
    {"type": "Marketplace", "source": null, "clicks": 8900, "epc": 1.08, "margin_pct": 19.6}
  ]
}
```

### Active Experiments

```json
{
  "experiments": [
    {"name": "RLA-ReAsk-v2", "area": "Monetization", "days": 18, "sample": 48000, "lift": 8.2, "metric": "EPL", "p_value": 0.003, "significant": true},
    {"name": "SoftTimeout-300ms", "area": "Monetization", "days": 12, "sample": 31200, "lift": 3.1, "metric": "sell rate", "p_value": 0.042, "significant": true},
    {"name": "ProcessingScreen-v4", "area": "Application", "days": 9, "sample": 18400, "lift": 0.0, "metric": "EPL", "p_value": null, "significant": false},
    {"name": "MobileForm-2Step", "area": "Application", "days": 6, "sample": 12800, "lift": 5.7, "metric": "completion", "p_value": 0.018, "significant": true},
    {"name": "EngageTier-Rebalance", "area": "Router", "days": 21, "sample": 62000, "lift": -1.4, "metric": "EPC", "p_value": 0.091, "significant": false},
    {"name": "EmailSubject-Urgency", "area": "Email", "days": 4, "sample": 8200, "lift": 1.2, "metric": "CTR", "p_value": 0.340, "significant": false},
    {"name": "PushTiming-Evening", "area": "Push", "days": 7, "sample": 6400, "lift": 4.8, "metric": "CTR", "p_value": 0.025, "significant": true},
    {"name": "AffiliateLP-Redesign", "area": "Application", "days": 14, "sample": 22600, "lift": 6.3, "metric": "app rate", "p_value": 0.008, "significant": true},
    {"name": "DynamicRLA-Caps", "area": "Monetization", "days": 3, "sample": 4800, "lift": null, "metric": "EPL", "p_value": null, "significant": false}
  ]
}
```

### Anomaly Detection Results

```json
{
  "anomalies": [
    {"type": "epl_drop", "partner": "CreditServe", "metric": "EPL $42.80 → $28.20", "comparison": "34% decline day-over-day", "revenue_share": "18% of total", "possible_cause": "Buyer-side cap hit, campaign paused, or quality filtering tightened"},
    {"type": "volume_spike", "source": "SMS", "affiliate": "PulseMedia", "metric": "12,400 clicks vs 5,200 avg", "comparison": "2.4x weekly average", "possible_cause": "New SMS campaign SpringCash-03 launched Monday"},
    {"type": "funnel_dropout", "step": "3→4", "metric": "62% → 55.2%", "comparison": "11% decline since Tuesday", "possible_cause": "Lookup service latency, validation change, or mobile rendering issue"},
    {"type": "pipeline_stale", "pipeline": "partner_revenue_rollup", "last_refresh": "4:12 AM", "expected_interval": "hourly", "stale_duration": "4 hours"}
  ]
}
```

## 3. Calculations

### Hero Stats

- **Yesterday Revenue**: Sum all `partner.revenue` → $287,430
- **Blended EPC**: Weighted average across traffic types by click volume → $1.42
- **Sell Rate**: Total leads sold / total leads entered ping tree → 68.4%
- **Active Experiments**: Count experiments → 9

### Anomaly Detection

For each partner, compare today's EPL against prior day:
- Flag if EPL drops >15% for any partner contributing >10% of revenue → CreditServe (34% drop, 18% share)

For each traffic source, compare click volume against weekly average:
- Flag if volume >2x weekly average → SMS (2.4x)

For application funnel, compare step conversion against 7-day baseline:
- Flag if any step conversion drops >5% → Step 3→4 (11% drop)

For data pipelines, compare refresh age against expected interval:
- Flag if age >2x expected → partner_revenue_rollup (4h vs 1h expected)

### Severity Assignment

- **Red**: Revenue impact >$10K/day (CreditServe EPL drop = ~$41K/day impact)
- **Blue**: Statistical anomalies worth investigating (SMS volume, funnel dropout)
- **Amber**: Operational items needing decision (experiment ready, pipeline stale)
- **Gray**: Administrative items (contract renewals, weekly scorecard)
- **Green**: System confirmations (ping trees active, lead flow normal)

## 4. Generate HTML

Read the HTML template. Replace each placeholder comment with generated content.

For every dynamic string (partner names, experiment names, metric values), HTML-escape before insertion: replace `&` with `&amp;`, `<` with `&lt;`, `>` with `&gt;`, `"` with `&quot;`.

### Alert Card Structure

Each alert uses this HTML pattern:

```html
<div class="alert-card severity-{level}" data-alert-id="alert-{N}">
  <label class="alert-checkbox">
    <input type="checkbox" onchange="toggleDismiss('alert-{N}')">
  </label>
  <div class="alert-content">
    <div class="alert-title">{Title}</div>
    {Description — natural language, contextual analysis}
    <div class="alert-actions">
      <span class="quick-action" data-action="{Full Claude instruction}" onclick="selectAction(this)">{Short label}</span>
    </div>
    <div class="alert-note-toggle" onclick="toggleNote('alert-{N}')">+ Add note</div>
    <div id="note-alert-{N}" style="display:none">
      <textarea class="alert-note" data-id="alert-{N}" placeholder="Notes for Claude..."></textarea>
    </div>
  </div>
</div>
```

### Quick Action Design

Each alert gets 2-3 contextual action chips. The `data-action` attribute contains the **full instruction you'd paste into Claude Code or Claude Desktop**. This is the key innovation — each pill is a ready-to-use AI prompt:

- **Revenue/EPL alerts**: "Query analytics: [specific metric] for [partner] for [timeframe]", "Draft Slack for #[channel]", "Create a ticket: [specific description]"
- **Volume anomalies**: "Expected — [reason]", "Query analytics: [quality metrics]", "Pull [affiliate] scorecard"
- **Funnel anomalies**: "Query [service] response times", "Create a ticket", "Query analytics: [metric] by [dimension]"
- **Experiments**: "Draft Slack for #experimentation: [ship recommendation]", "Extend [days]", "Run /experiment-report"
- **Pipeline issues**: "Check [job] status, restart if stuck", "Expected — known behavior"
- **Contract renewals**: "Query analytics: [metrics] for [partners]", "Draft Slack for #client-relations", "Generate renewal briefs"
- **Scorecard**: "Run /weekly-scorecard for [scope]"
- **System health**: "Looks good — dismiss"

### Table Row Flagging

Every `<tr>` in data tables gets a `data-account="{name}"` attribute. Clicking a row flags it (blue highlight + note input). Works identically across all three tables.

## 5. Write Output

Save the final HTML to `/tmp/action-dashboard-YYYY-MM-DD.html`.

Print to terminal:
```
/tmp/action-dashboard-2026-03-20.html

Revenue: $287,430 | EPC: $1.42 | Sell Rate: 68.4% | Experiments: 9
1 critical alert | 2 anomalies | 1 stale pipeline | 1 experiment ready
```

## 6. Wait for Feedback

Print:
```
Open the dashboard in your browser. Review alerts, dismiss items, add notes.
When done, click "Copy Review Summary" and paste it here.
```

When the user pastes the review summary, parse the structured markdown:

- **Quick Actions** with analytics queries → execute the query
- **Quick Actions** with Slack drafts → draft and preview the message
- **Quick Actions** with tickets → create the ticket
- **Quick Actions** with slash commands → run the command
- **Dismissed** → mark as reviewed, no action needed
- **Notes** → store as context for follow-up
- **Flagged Items** → investigate or escalate as described
- **Still Open** → carry forward to next review

---

## Adapting This Template

To build your own action dashboard for a different domain:

1. **Replace the mock data** with your own data sources (analytics queries, API calls, database reads)
2. **Define your alert types** — what conditions map to red/blue/amber/gray/green?
3. **Design your tables** — what entities would users flag or annotate?
4. **Write quick actions as AI prompts** — what would you literally paste into Claude Code to take action?
5. **Keep the CSS and JS unchanged** — they're domain-agnostic

The feedback loop (dismiss → note → action → copy → paste) works for any domain. The quick actions are the key — make each one a specific, actionable instruction for Claude, not a vague "investigate" button.
