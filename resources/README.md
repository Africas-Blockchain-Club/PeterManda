# resources/ — the method, not the output

This folder is the operating system behind how every project in this repository gets built with Claude. It is not a place for project documentation; it is a set of standing instructions that travel with the repository and shape every piece of writing or code Claude produces here.

Four files, each answering a different question:

| File | Question it answers |
|------|----------------------|
| `about-me.template.md` | Who are you, and what does your voice sound like? |
| `my_writing_style.template.md` | What is the format, platform, and strategy for your content? |
| `anti-ai-writing-style.template.md` | What does AI-sounding writing look like, so it can be cut? |
| `cant_prompt_blindly.template.md` | What should Claude confirm before producing real output? |

## How to use these templates

1. Copy each `*.template.md` to its real filename — `about-me.template.md` becomes `about-me.md`.
2. Fill in every bracketed placeholder with your own answers. The structure (the section tags, the ordering, the logic) is the part worth keeping. The content inside is entirely yours.
3. The real, filled-in files are gitignored. They stay on your machine and never get committed. [CLAUDE.md](../CLAUDE.md) at the repository root (also gitignored, local-only) is what tells Claude to read these four files before writing anything.
4. Keep your real files as honest as you can stand. A voice file that lists your actual banned words and your actual hard refusals does more work than one that hedges.

## Why this exists

A model writing in your voice is only useful if the rules describing that voice are precise, specific, and enforced. Vague style guides ("be professional, be concise") produce generic output. The templates here show the level of specificity that actually changes what gets written: named examples of good and bad, hard refusals stated as rules with a bad/good pair, a list of words you would never use. Fill yours in at that same resolution.
