# Config Chooser Prompt Template

Generate a standalone HTML config chooser when the user needs to make a visual configuration choice. This is a variant of the 3-layer feedback pattern that produces structured code instead of markdown.

## When to Generate a Config Chooser

All four conditions must be true:

1. The user needs to make a subjective choice from a large option space.
2. The options require visual evaluation (cannot be assessed as text alone).
3. The result must return to Claude as structured data (code snippet, JSON, config value).
4. There are too many valid options to present as a numbered list in the terminal.

**Examples:** color palettes, font pairings, chart types for a dataset, icon sets, animation curves, responsive breakpoints, theme variants, spacing scales.

**Non-examples:** choosing between 2-3 architecture approaches (use the planning dashboard with decision groups instead), triaging alerts (use the report engine template), binary yes/no decisions (just ask in the terminal).

## How to Generate

1. **Identify the option space.** What is being chosen? How many valid options exist? Can they be grouped into categories?
2. **Design the picker UI.** Claude has full creative freedom here. Swatch grids, sliders, dropdown menus, drag-and-drop, before/after comparisons, live previews, whatever fits the domain. Do not force a specific layout.
3. **Include a live preview.** Show the user how their choice will look in context. A color picker should show the color applied to the actual UI element. A font picker should show text rendered in the font. The preview should update instantly on selection.
4. **Include a copy button.** The button must emit structured data in the format the codebase expects. Python dicts, JSON objects, CSS variables, YAML fragments, TypeScript interfaces, shell variables. Claude should know the target format from the codebase context.
5. **Write to `/tmp/` and open.** Same as the report engine: write to `/tmp/{domain-slug}-chooser.html`, copy to `~/.agent/diagrams/`, open with `wslview`.

## Output Format Guidance

The copy button replaces the report engine's "Copy Review Summary" button. Instead of markdown, it emits code.

The output must be in the exact format the codebase expects so Claude can paste and apply without transformation. If the target is a Python dict, emit a Python dict. If the target is a JSON config file, emit JSON. If the target is CSS custom properties, emit CSS. One copy button, one format. Claude Code can work with any structured format equally well, so multiple format buttons add no value.

## What Not to Prescribe

The config chooser is a high-freedom component. Do not prescribe:

- **The UI layout.** Swatch grids, sliders, range inputs, drag handles, color wheels, dropdown selectors are all valid. Claude should design what fits the domain.
- **The preview mechanism.** Live mockups, side-by-side comparisons, before/after toggles, inline previews are all valid. Choose based on what helps the user evaluate the choice.
- **The styling.** The chooser does not need to match the report engine's dark theme or typography. It should match the context of what is being configured.
- **The number of options.** 10 swatches or 100 swatches, categorized or flat, with or without custom input. Scale to the option space.

## Relationship to the Report Engine

The config chooser and the report engine are both renderings of the 3-layer pattern:

```
Layer 1 (Prompt)     →  describes what to generate
Layer 2 (HTML)       →  visual artifact the human interacts with
Layer 3 (Feedback)   →  structured output that returns to Claude
```

The report engine handles triage and planning. The config chooser handles visual configuration. Both follow the same pattern but produce different artifacts with different feedback formats.
