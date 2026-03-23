# Interactive Report Engine

## Repository Structure

```
interactive-report-engine/
├── CLAUDE.md                           # This file
├── README.md                           # Pattern documentation and usage guide
├── LICENSE                             # MIT
├── interactive-report-engine.html      # The engine template (copy and fill in)
├── interactive-report-engine.publish.yaml  # internal docs site publishing sidecar
├── interactive-report-engine.publish.md    # internal docs site description
├── docs/
│   ├── pattern-guide.md               # Detailed 3-layer pattern documentation
│   ├── architecture.md                # Concise architecture overview
│   └── skill-design-guide.md          # Layered freedom model for skill authoring
├── examples/
│   ├── operations-dashboard.html      # Triage workflow example
│   ├── operations-dashboard-prompt.md # Prompt template for the example
│   ├── anniversary-trip-planner.html  # Planning dashboard with venue options
│   ├── dois-2587-technical-review.html # Technical ticket review with decision groups
│   ├── config-chooser.html            # Visual config picker (standalone variant)
│   ├── config-chooser-prompt.md       # Prompt template for config choosers
│   └── sql-query-review.html          # SQL query walkthrough with annotatable clauses
└── .gitignore
```

## How This Repo Works

The engine template is a single self-contained HTML file (~1100 lines) with inline CSS and JS. To use it:

1. Copy `interactive-report-engine.html` to a new file
2. Replace the placeholder comments with domain-specific content
3. The CSS and JS require no changes

The template is domain-agnostic. It works for compliance reviews, operations dashboards, experiment triage, or any workflow where a human reviews items and makes per-item decisions.

The 3-layer pattern also supports standalone variants (like `config-chooser.html`) where the engine template's alert-card model does not fit. These share the same generate-review-feedback loop but produce structured code instead of markdown.

## Key Conventions

- All CSS, JS, and HTML live in one file. No build step. No external dependencies.
- Feature flags are `data-*` attributes on the `<body>` element: `data-multiaction`, `data-annotatable`, `data-no-persist`.
- Alert cards use `data-alert-id` and `data-severity` attributes.
- Quick action pills use `data-action` with literal instruction text.
- Table rows use `data-row-id` for flagging.
- The Copy Review Summary output is structured markdown with deterministic sections.

## Related Skills

- `/action-report` skill (at `~/.claude/skills/action-report/`) generates reports from this template
- The template path referenced by skills is `~/repos/interactive-report-engine/interactive-report-engine.html`

## Writing Style

- No em-dashes. Use commas, colons, or periods.
- No sentence fragments. Complete sentences.
- No evaluative language. State facts.
