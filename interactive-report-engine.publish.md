---
title: "Interactive Report Engine: Template"
status: active
created: 2026-03-20
updated: 2026-03-20
category: training
tags: [ai-first-training, training-program, interactive-reports, templates]
---

# Interactive Report Engine

Self-contained HTML template for building interactive review dashboards. The engine provides a 3-layer architecture: a prompt template tells the AI what data to fetch, an HTML template renders the dashboard with placeholder comments, and a JavaScript feedback loop captures your review decisions as structured markdown that the AI can act on.

## How to Use the Template

1. Copy `interactive-report-engine.html` to a new file for your domain.
2. Replace the placeholder comments in the HTML section (`<!-- REPORT_TITLE -->`, `<!-- HERO_STATS -->`, `<!-- ALERTS -->`, `<!-- TABLE_DATA -->`) with your domain-specific content.
3. The CSS and JavaScript sections require no changes. They work for any domain.
4. Open the file in a browser, review the dashboard, and click "Copy Review Summary" to export your decisions as markdown.
5. Paste the markdown back into Claude Code or Claude Desktop. The AI parses the structured output and acts on each item.

## Feature Flags

The template supports four feature flags controlled by `data-*` attributes on the `<body>` element.

| Attribute | Default | Effect |
|-----------|---------|--------|
| `data-multiaction` | Off | Allows selecting multiple action pills per alert card. Without this attribute, selecting one pill deselects any previous selection on the same card. |
| `data-annotatable` | Off | Enables click-to-annotate on any element with a `data-annotation-id` attribute. Clicking the element opens an inline text input for adding a note. |
| `data-no-persist` | Off | Disables localStorage state persistence. By default, the engine saves all review state (dismissed items, selected actions, notes, flagged rows) to localStorage and restores it on reload. |
| (shareable URL) | On | The Share State button encodes review state into the URL hash. Opening a shared URL imports the state once, then strips the hash so subsequent reloads resume from localStorage. |

To enable a flag, add the attribute to the body tag:

```html
<body data-multiaction data-annotatable>
```

## Built-in Interactions

The template includes the following interactions with no additional configuration required:

- **Alert card dismiss**: Checkbox animation marks an alert as reviewed.
- **Action pill selection**: Click a suggested action to copy its text to clipboard.
- **Inline notes**: Textarea on each alert card for free-form commentary.
- **Table row flagging**: Click any table row to flag it and add a note.
- **Keyboard navigation**: `j`/`k` to move between alerts, `x` to dismiss, `1`-`5` to select action pills, `n` to focus the note field, `c` to copy the review summary, `s` to share state URL.
- **Copy Review Summary**: Generates structured markdown from all interactions.

## Generating Reports with /action-report

The `/action-report` skill automates the creation of new reports from this template. It reads your domain configuration, fetches data, populates the template placeholders, and writes the output to `/tmp` for browser review. See the skill documentation for setup instructions.

## Related Resources

- [Interactive Template Pattern](interactive-template-pattern.md) describes the architectural concept behind this engine.
- The pattern guide covers example domains by role (leadership, client relations, product, media buy, engineering, finance).
