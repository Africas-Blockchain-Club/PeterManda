# Build Standards

**Universal build standard for Claude and any AI coding agent. Applies to every project I run.**

Companion to `cant_prompt_blindly.md`. That file governs what to confirm before building. This file governs how to build anything that depends on something I do not control: an AI model, a payment provider, an auth service, a data API, a host. One rule, applied to every external dependency.

---

## The Principle

> Build as if the AI dies tomorrow and we all put our coding caps back on.
> Build as if I am never coming back to fix it.

Two single points of failure sit in most systems: the model, and the author. Neither is under my control at run time. A model can be throttled or pulled by a government, a lab, or a billing limit, for reasons that have nothing to do with me. The author (me, or whoever prompted the build) will not always be there to patch it when it breaks.

A system that stops working when its model goes away was never finished. The model is an accelerator bolted on top. It is not the engine. If you cannot unbolt it and still run, the build is not done.

This is stronger than "wire in a second model." A second model is a convenience for the common case. It is not the standard. The standard is that the core purpose survives with no AI at all.

---

## The Two Cases

Not every dependency can be removed. Separate them at the start of the build, not after one breaks.

**Case 1: AI model dependencies. These must be removable.** Whatever goal the system reaches through a model, there must be a path to that goal with the model switched off entirely. Usually that path already exists in the old way of doing the work: a rule, a template, a lookup, a human in a queue. AI makes it faster or cleaner. AI does not make it possible. If the goal is impossible without AI, then AI is load-bearing, and that is a risk to name out loud before building, not a default to accept.

**Case 2: Other critical third-party dependencies (payment, auth, data, hosting, messaging). These must be portable and degradable.** Some cannot be removed; you cannot take a card payment with no payment provider at all. So the rule here is not "run without it"; it is "do not be locked to one, and define what happens when it is down." Abstract it, make it swappable, and degrade loudly rather than silently.

---

## The Build Standard

Apply to every build that calls a model or a critical third party.

**1. One boundary per dependency.** Every external dependency sits behind a single adapter or interface. No provider SDK sprayed across the codebase. Swapping or removing a provider should touch one file, not forty.

**2. Configuration, not hard-coding.** Provider choice, model names, endpoints, and keys live in config or environment. Changing a provider, or turning AI off, is a config change, not a code change.

**3. A defined off state.** For every AI call, write down what the system does when no model answers: deterministic logic, cached or last-known-good results, a template, or a human handoff. The off state is a designed feature, not an exception you find in production.

**4. Fail loud, never silent.** When a dependency is down or a model is gone, the system says so: a clear error, a logged event, a visible degraded mode. It never returns a quiet wrong answer and presents it as real.

**5. Do not trust a swapped model.** Fallback is not clean. Models reason differently and use tools differently. So:
- Validate output shape independently of the model. Parse and check against a schema; do not assume the reply is well formed because the last model formed it well.
- Keep prompts and tool contracts portable. No reliance on one provider's quirks.
- Exercise the critical path on each wired model, not only the primary. A path you have not run is a path you cannot count on.

**6. Trace which provider served the call.** Log the model or provider behind every critical action. When behaviour drifts after a swap, you need to see which one did it.

**7. Provider redundancy is the first tier, not the safety net.** A second model from a different provider is worth having; it covers the common outage cheaply. It is the first line. The safety net is Case 1: the system still reaches its purpose with all AI off.

---

## The Universal Build Prompt

Drop this block into any AI build session. It encodes the standard above so the building agent applies it without being re-taught. This is the "build as if I will never use it again" artefact.

```
Build this so it survives losing what it depends on.

Rules:
1. Any AI model is an accelerator, not the engine. The core purpose must
   still be reachable with all AI switched off, through deterministic logic,
   cached results, a template, or a human handoff. If the goal is impossible
   without AI, stop and tell me; that is a risk I need to decide on, not a
   default for you to accept.
2. Put every external dependency (model, payment, auth, data API, host)
   behind one adapter. Swapping or removing one must touch one file, not the
   whole codebase.
3. Provider choice, model names, endpoints, and keys live in config or env.
   Turning AI off, or changing provider, is a config change, not a code change.
4. Define the off state for every dependency: what runs when the model or
   provider is unavailable. Make it a real, coded path.
5. Fail loud. On any outage or missing model, return a clear error or a
   visible degraded mode. Never a silent wrong answer.
6. Do not assume clean model fallback. Validate output shape against a schema
   independently of the model. Keep prompts and tool contracts portable.
7. Log which model or provider served each critical call.

Done condition: the system has been run once with its primary model disabled,
and it still reached its core purpose in a defined degraded mode. If you
cannot show that, it is not finished.
```

Adjust the dependency list to the build. The rules do not change.

---

## Done Condition

A build that depends on a model or a critical third party is not done until:

- It has been run once with the primary model disabled, and still reached its core purpose in a defined degraded mode.
- Every external dependency sits behind one swappable boundary.
- The off state for each dependency is coded, not theoretical.
- Nothing fails silently.

If any of these is missing, the build is unfinished, whatever the demo shows.

---

## The Golden Rule

> The dependency you do not control is the one that decides whether you have a product.
> Design it out, or design around it. Never build on top of it and hope.
