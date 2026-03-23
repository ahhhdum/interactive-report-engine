# Skill Design Guide: Layered Freedom Model

Research-backed guidelines for improving the `action-report` skill and the interactive-report-engine template. Based on an audit of Anthropic's official skill documentation (March 2026), the ai-dev-templates skill creation framework, capture-workbench research, and the current state of this repo.

## Core Principle

The skill operates at three distinct freedom levels. Each layer has different rules about how prescriptive the instructions should be. Do not flatten these into a single level.

## Layer 1: Structural Contracts (Low Freedom, Exact Code)

These are the API contracts between generated HTML and the engine's JavaScript and CSS. If any of these are wrong, features silently break.

**What belongs here:**
- Data attribute names and formats (`data-alert-id`, `data-severity`, `data-action`, `data-table-id`, `data-row-id`, `data-annotation-id`)
- Severity-to-CSS-class mapping (`severity-action`, `severity-review`, `severity-anomaly`, `severity-routine`, `severity-ok`, `severity-info`)
- JavaScript function call signatures (`toggleDismiss()`, `selectAction()`, `toggleNote()`)
- Body-level feature flags (`data-multiaction`, `data-annotatable`, `data-no-persist`)
- Feedback markdown section headers and line formats
- State object shape (`dismissed`, `notes`, `actions`, `flaggedRows`, `rowNotes`, `annotations`)

**How to encode these in the skill:** Provide a compact contract table, not full HTML blocks. The skill already instructs Claude to read the template file. Trust that instruction. The contract table serves as a checklist, not a replacement for reading the template.

**Why this matters:** The engine's JS reads `data-alert-id` by exact string. A typo like `data-alertId` or `data-id` produces no error and no functionality. Severity classes map to CSS border colors. An invented class like `severity-critical` renders with no color. The feedback markdown parser splits on `### Actions Selected` exactly. A heading like `### Selected Actions` produces an unparseable summary.

## Layer 2: Component Patterns (Medium Freedom, Defaults with Extension Rules)

These are the building blocks Claude composes into dashboards. The current set covers approximately 80% of use cases. The remaining 20% requires new component types that do not yet have guidance.

**Current components:** hero section, KPI cards, alert cards, filter bar, pipeline steps, collapsible detail tables, standalone tables, inline annotations.

**The gap:** There is no framework for creating components outside this set. When a domain needs image comparisons, timeline views, spatial layouts, interactive controls (color pickers, sliders, rating widgets), or other novel presentation types, Claude defaults to forcing the content into alert cards. This produces technically functional but conceptually wrong output.

**Improvement: Add a custom component contract.** Any new component Claude creates must satisfy these requirements:

1. Use the animation system: `class="anim-up" style="--i:{N}"` for entrance animations.
2. Use the color system: reference existing CSS custom properties and severity color classes. Do not introduce new color values outside the existing palette.
3. Be keyboard-navigable: all focusable elements need `tabindex`, and must respond to Enter and Space. Follow the existing j/k card navigation pattern where applicable.
4. Be responsive: use the existing grid and flex patterns. Content must be usable at 375px viewport width.
5. Preserve the feedback loop: interactive elements must write to the state object via existing functions, or document a new state key that the `buildSummary()` function can read. The copied markdown must include the user's interaction with the custom component.

**How to encode this in the skill:** State the five requirements as a numbered list. Provide one short example of a custom component (such as an image comparison card or a rating widget) that satisfies all five. Do not provide an exhaustive catalog. Claude can invent novel components as long as they satisfy the contract.

## Layer 3: Content and Presentation (High Freedom, Examples Only)

This is where Claude should have full creative latitude. The skill should provide 3 to 5 examples per category and explicitly state they are starting points.

**What belongs here:**
- Domain adaptation (which components to use, how many KPIs, whether to include a pipeline section)
- Action verb text (the literal strings in `data-action` attributes)
- Severity assignment (which alerts are red vs. amber vs. green)
- Badge text and formatting
- Card ordering and grouping
- Visual hierarchy choices
- Filter button labels (can use domain-friendly text like "Recommended" instead of "routine")

**How to encode this in the skill:** The current "Quick Action Patterns by Domain" section handles this correctly. Keep the same pattern: show examples, state they are starting points, do not close the set.

## Decision Framework

For any element in the skill, apply these questions in order:

1. Does the engine's JS or CSS break if this is wrong? If yes: **prescriptive, exact code.**
2. Does inconsistency here break the feedback loop? If yes: **prescriptive, with a "why" explanation.**
3. Are there fewer than 3 valid approaches? If yes: **provide the default with an escape hatch.**
4. Is this a matter of domain knowledge, taste, or creative judgment? If yes: **provide 3-5 examples, state they are starting points.**
5. Does Claude already know how to do this? If yes: **omit it entirely.** Do not explain standard HTML, CSS, or JavaScript patterns.

## Specific Improvements to Make

### 1. Add a Domain Adaptation section to Mode A

Place it after the Discovery Questions (Step 1), before reading the template (Step 2). This section should state:

- The default component library handles most domains.
- When the item being reviewed has a visual or interactive nature that alert cards cannot represent, Claude should create custom components using the Layer 2 contract.
- Provide the decision heuristic: "Does the standard alert card adequately represent this item, or does the item's nature require a different interaction model?"

### 2. Replace inline HTML snippets with a contract table

The current skill contains approximately 200 lines of HTML that duplicate the template. Replace these with a compact table listing each component, its required data attributes, and the JS functions it calls. Keep one short HTML example per component (5-10 lines) rather than the full structure. Claude reads the template file in Step 2 and should use it as the canonical source.

This reduces the skill body from approximately 460 lines to 250-300 lines. It also eliminates the risk of the skill diverging from the template as the template evolves.

If cross-model reliability is a concern (Haiku may need more explicit structure than Opus), move the full HTML examples to a `references/html-patterns.md` file that Claude reads on demand.

### 3. Add "why" explanations to non-obvious constraints

For each constraint that is not self-evident, add a one-line explanation. Examples:

- Slugified filenames: the filename is used as the localStorage key and in URL hash fragments for state sharing.
- Save to `~/.agent/diagrams/`: `/tmp/` is cleared on reboot; the persistent copy lets the user reopen reports in future sessions.
- Filter buttons only for present severity types: empty filters confuse users who expect clicking them to reveal hidden content.
- Action text starts with a verb: the Mode B routing table matches on the leading verb keyword. "Partner volume query" would not route correctly; "Query partner volume" would.

### 4. Add a Custom Components section

Place it after the existing component documentation, before Step 4 (Feature Flags). Include:

- The five requirements from Layer 2 above.
- One worked example of a custom component (such as a comparison card with image thumbnails, or a rating widget with star/slider input).
- A note that the component catalog is extensible. Claude should not force content into alert cards when a different component type would better serve the domain.

### 5. Soften trigger language in the skill description

Anthropic's March 2026 guidance for Claude 4.5/4.6 models: these models respond well to normal prompting and may overtrigger on aggressive language like "CRITICAL: You MUST use this tool when..." Use plain language: "Use this skill when..." and "Do not use for..." The current description is already reasonable but should be checked against this standard.

## Validation

After implementing changes, test with three scenarios:

1. **Standard domain (compliance review):** Should produce a conventional card-based dashboard. Verify all data attributes, keyboard navigation, and feedback markdown work correctly.
2. **Novel domain (design mockup review with color palettes):** Should produce at least one custom component. Verify it satisfies the Layer 2 contract (animation, color system, keyboard nav, responsive, feedback loop).
3. **Repeat test 1 three times:** Outputs should be structurally consistent (same data attributes, same section order) while allowing variation in content (different badge text, different card ordering is acceptable).
