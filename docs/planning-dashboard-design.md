# Planning Dashboard: Design Notes

Status: grooming. Not yet built. Captured from March 20, 2026 conversation.

## What This Is

A new example of the interactive report engine applied to planning and decision-making. Not a separate product. Same CSS, JS, and feedback loop. Different card content, different action verbs, different summary heading.

## Why It Matters

Every existing AI planning tool has the same bottleneck: the human's evaluation goes back as unstructured text.

| Tool | How decisions are captured |
|------|--------------------------|
| Claude Code Plan Mode | User types "approve", "reject", or free text in terminal |
| Superpowers Brainstorming | User types approval in terminal. Visual companion shows mockups but decisions are text. |
| Claude Artifacts | User comments in chat. Free-form. |
| AskUserQuestion | 3 preset options + free text field |
| Miro/FigJam | Sticky notes and votes, but no AI loop to execute against |

The planning dashboard makes evaluations structured: click "Prefer" (not type it), annotate specific claims inline (not describe them in chat), and copy a machine-parseable decision summary that Claude can execute against.

## Design Decisions (Agreed)

1. **Same engine, new example.** No new JS features. The existing alert cards, action pills, notes, annotations, row flagging, and copy summary work for planning without modification.

2. **Action verbs are domain-specific, not prescribed.** The skill gives examples and guidance but does not enforce a fixed set. Claude is better at adapting verbs dynamically to the user's context than following a rigid taxonomy. Examples across domains:
   - Architecture: "Proceed with this approach" / "Viable but not preferred" / "Has blocking concerns" / "Reject"
   - Prioritization: "Do this first" / "Do this later" / "Defer to next quarter" / "Cut"
   - Design: "Ship this direction" / "Needs iteration" / "Explore further" / "Wrong direction"

3. **Options can be complementary or competing.** If someone selects "Prefer" on all three options, that is valid (they might want elements of each). If options are mutually exclusive and all are preferred, the summary captures that tension for Claude to surface. No rigid enforcement.

4. **No decision matrix / scoring rubric.** Over-engineering. The note and annotation features already let users explain their reasoning per option. Structured scoring across dimensions (complexity, risk, timeline) adds complexity without proportional value for most planning decisions.

5. **Audience is both solo and collaborative.** A developer reviewing Claude's approaches before implementation, and a team lead sharing options with stakeholders for input. Share State URL handles the collaborative case. No real-time collaboration needed.

## What the Example Should Demonstrate

A real planning scenario meaty enough that people immediately see how it maps to their work. Not a toy "pick A, B, or C" but a multi-dimensional decision with trade-offs.

Candidate domains:
- **Product redesign** ("How should we redesign our onboarding flow?" with 3 approaches)
- **Technical migration** ("How should we move from monolith to services?" with trade-offs)
- **Feature prioritization** ("Which of these 5 features should we build in Q2?")

Each option card should have:
- A clear title and description
- Badges showing key attributes (timeline, risk, effort)
- Specific quick actions that are literal Claude instructions
- A collapsible detail section with supporting data
- Room for inline annotation on specific claims

The summary should be titled "Decision Summary" and include a clear "Preferred" section, not just "Actions Selected."

## What the Skill Guidance Should Say

High-level: "Make the action pills specific and actionable for the user's context. Each pill text becomes a literal instruction in the decision summary. Prefer concrete verbs over vague labels."

Examples, not prescriptions. Show 3-4 domains with different action verb sets so the user understands the principle, then let Claude adapt dynamically.

## Comparison to Superpowers Brainstorming

Superpowers brainstorming and the planning dashboard serve different stages:

- **Brainstorming** helps you go from "I have an idea" to "here are 2-3 approaches with trade-offs." It is a conversation in the terminal.
- **Planning dashboard** helps you go from "here are the approaches" to "here is my structured decision with rationale." It is a visual review with structured feedback.

They are complementary. Brainstorming produces the options. The dashboard structures the evaluation. The decision summary feeds back into Claude for execution.

## Next Steps

1. Build the planning example HTML (using the engine template from this repo)
2. Test all interactions: prefer/reject options, annotate specific claims, copy decision summary
3. Update the /action-report skill to mention planning as a use case with examples
4. Publish as the showcase example on docs.epcvip.vip by Monday
5. Update the README with the planning use case alongside operations and compliance
