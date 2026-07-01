# Can Not Prompt Blindly — Template

**Universal intake protocol for Claude. Applies to every project run in this repository.**

This file is for Claude. It tells Claude what to confirm with you before producing any substantive output. The goal: ask a few good questions upfront so the first draft is right, instead of producing several wrong drafts and burning turns on iteration.

---

## The Principle

> Asking once is cheaper than drafting three times.

[State your own version of this trade-off. Most people would rather spend thirty seconds answering questions than ten minutes correcting a draft built on a wrong assumption — but say it in your own words.]

---

## When To Ask

Run intake before producing output if any of these are true:

- The request has more than one valid interpretation
- The output is substantial (more than 200 words of prose, code with side effects, structured documents, presentations, formal communications)
- The audience or platform is not stated
- The deliverable format is not stated
- Constraints, length, or done condition are not stated
- The request references a project, file, or person not visible in this chat

## When To Proceed Without Asking

Skip intake if any of these are true:

- Direct factual question or lookup
- Continuation or revision of a draft already on the table
- Small targeted edit on a specific identified piece of content
- A complete brief was given that already covers the universal checklist below
- You said "just do it", "best guess", "skip the questions", or similar

In those cases, proceed and note any assumptions inline so they can be corrected on review.

---

## Universal Intake Checklist

Before producing any substantive output, the answers to these five must be known. If any are missing, ask before drafting.

1. **Outcome.** What is the single thing this output must do or achieve?
2. **Audience.** Who is reading, using, or receiving this?
3. **Format.** What is the deliverable shape (file, message, code, slide deck, email)?
4. **Constraints.** Length, tone, things to avoid, hard rules, deadlines, dependencies.
5. **Done condition.** How will you know this is finished and ready?

Ask these as a numbered list in one message. Do not ask one at a time across multiple turns.

---

## Output-Specific Intake

In addition to the universal five, ask these extras based on output type. [Replace or extend these categories to match the kinds of work you actually commission.]

**Content or writing (article, post, essay, newsletter):**
- Which platform?
- Which content category, if more than one exists (see `my_writing_style.md`)?
- Approximate length
- Hook source (origin anchor, observation, real moment)
- Source material to draw from, if any

**Code or scripts:**
- File path and language
- Inputs and expected outputs
- Constraints (do not touch X, preserve Y, must run on Z)
- Test or validation plan
- Branch and merge convention

**Documents or reports:**
- Required sections
- Source material
- Final deliverable or working draft?
- Compliance, branding, template requirements

**Decisions or strategy:**
- The choice space (options under consideration)
- The criteria for choosing
- The constraints (budget, time, skill, risk tolerance)
- Information already available
- Analysis, recommendation, or both?

---

## Good Intake vs Bad Intake

**Good (one message, specific, restates what is already known):**

> Before drafting the [content type] on [topic], I need to confirm:
> 1. Outcome: I understand this is a [category] piece about [specific angle]. Correct?
> 2. Audience: [restate or ask]
> 3. Length: [restate or ask]
> 4. Hook: do you have a specific moment to draw on, or should I propose one?
> 5. Done condition: ready to publish, or a first draft for review?

**Bad (procedural, vague, multi-turn):**

> Should I write this for you?
> What length do you want?
> What tone should I use?
> Do you want bullet points?

---

## The One-Shot Rule

After intake, draft fully. Then:

- Present the draft for review before further iteration
- Do not regenerate the entire output on minor edits
- When asked to revise, change only what was flagged; do not touch the rest
- When in doubt about scope of a revision, ask before rewriting

---

## What Not To Ask

These waste turns. Apply project conventions or sensible defaults instead.

- "Should I use markdown?" Apply project conventions.
- "Should I follow the rules in `my_writing_style.md`?" Always yes.
- "Are you sure you want me to proceed?" If intake is clear, proceed.
- The same question twice in one session
- Permission to use bullets, headers, or basic formatting

---

## Flagging Inconsistencies

If anything in a prompt contradicts `my_writing_style.md`, the project instructions, or an earlier statement in the same chat, flag it before drafting. Do not silently choose one over the other.

If two of your own files contradict each other, flag the contradiction and ask which one wins for this output.

---

## Recovery From Scope Creep

If new requirements appear mid-draft, do not silently expand. Stop, restate the new scope, and confirm before continuing.

---

## Token Discipline

- One task per draft. Bundling tasks inflates context and multiplies error surface.
- Point, do not describe. `server.js:502` beats a paragraph explaining what the function does.
- No full-file pastes for content already shared. Reference by path.
- No re-runs from scratch on a wrong draft. Diagnose what was wrong and send a targeted correction.
- Close the loop. Once a task is done and committed, do not revisit it in the same session unless something is broken.

---

## The Golden Rule

> Discipline is the edge.
> Every prompt is a cost decision. Spend it on outcomes, not exploration.
