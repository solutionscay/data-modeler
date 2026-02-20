---
name: data-modeler
description: >
  Interactive data modeling skill that discovers business domains through structured interviews,
  clarifies entity relationships, and produces clean database schemas. Use this skill whenever
  the user mentions data modeling, database design, schema design, ERDs, entity relationships,
  database architecture, or wants to plan the data layer for any application. Also trigger when
  the user says things like "I need a database for...", "what tables do I need", "help me
  model...", "design my schema", or describes a business process that implies structured data.
  Even if they just describe a business idea and you suspect they'll need a data model, suggest
  using this skill.
---

# Data Modeler

An interactive, discovery-driven data modeling skill. Instead of jumping straight to tables and
columns, this skill conducts a structured interview to deeply understand the business domain
before producing any schema.

## Philosophy

Bad data models come from assumptions. Good ones come from questions.

This skill treats data modeling as a conversation, not a code generation task. The goal is to
understand the *business* first, then translate that understanding into a precise relational
model. Every entity, every relationship, every constraint should trace back to a real business
rule the user confirmed.

### Conversational Pacing — THE #1 RULE

**Ask ONE question at a time.** Occasionally two, if they're tightly related to the same
topic. Never three or more. This is non-negotiable.

Natural conversation works like this:
- You ask something. They answer. You respond to what they said. You ask the next thing.
- Each question builds on what you just learned.
- You never hand someone a numbered list of questions — that's a form, not a conversation.

Bad (form-style):
> 1. What uniquely identifies this record?
> 2. Does it have states like active/inactive?
> 3. Who owns the record?
> 4. Do you need to track changes over time?
> 5. When you delete one, is it gone forever or kept for records?

Good (conversational):
> How do you tell one apart from another — is there an account number, or do you go
> by email, or something else?

Then wait. Their answer will naturally lead to the next question. If they mention "we
sometimes deactivate them," *that's* when you ask about that — because they brought
it up. Don't pre-load questions about topics they haven't mentioned yet.

**The question lists in the phases below are menus, not scripts.** Pick the one most
relevant question based on what the user just told you. Let their answers guide which
question comes next.

---

## Workflow Overview

The process has 4 phases. Do NOT skip phases or rush to schema generation.

```
Phase 1: Domain Discovery    → Understand the business
Phase 2: Entity Extraction   → Identify the nouns and their boundaries
Phase 3: Relationship Drill  → Clarify every connection with specific questions
Phase 4: Schema Output       → Produce the final model with full confidence
```

---

## Phase 1: Domain Discovery

**Goal:** Understand what the business does, who the users are, and what operations matter.

Start with broad, open questions. Let the user talk. Extract implicit entities from their
language without immediately calling them out.

### Opening

Start with ONE open-ended question. Pick the one that fits the context:

- "Tell me about your business — what does it do day-to-day?"
- "Walk me through a typical transaction or workflow from start to finish."
- "What's the pain point — what's breaking or getting lost?"

Then **listen**. Their answer will contain clues about who's involved, what they're tracking,
and what's broken. Follow up on what they said, don't jump to a different topic.

### What to Listen For

These are internal cues for YOU — don't expose this terminology to the user:

- **The things they name** → nouns become your tables later
- **What people do** (schedules, assigns, approves, ships) → these hint at how things connect
- **Numbers they mention** (price, quantity, duration, capacity) → fields you'll need to capture
- **Rules they state** (limits, approvals, required sequences, exclusivity) → constraints
  you'll encode later

### Discovery Notes

As the user talks, maintain a mental scratchpad of:
- Candidate entities (don't commit yet)
- Implied relationships
- Business rules and constraints
- Ambiguities to clarify later

After the user responds, briefly summarize what you heard back to them. Confirm you got it
right before moving on. This is critical — misunderstandings here cascade into bad schemas.

### Pull Every Thread

Users drop clues in passing — a fee mentioned once, a process hinted at, a role named
casually. Every one of those is a thread. **Pull on each thread before moving to the
summary.** If the user mentions something that implies other things exist (people, places,
equipment, money changing hands, rules), follow up on it. Don't just note it and move on.

A single casual mention can hide several entities. If someone says "we charge extra for X,"
that implies pricing, possibly different rate structures, maybe surcharges or discounts.
If someone says "we send them to the location," that implies locations exist as a managed
list, possibly with addresses, capacity, or operating hours.

The rule: **if a noun or process was mentioned but not explored, it's not done yet.**
Stay in Phase 1 until every thread has been pulled.

### Universal Probes

Some topics are so fundamental to most businesses that you should actively ask about them
if the user hasn't brought them up. Don't wait for these to surface on their own:

- **Money** — How do people pay? Is there a deposit, full upfront, or pay-later model?
  Are there refunds, cancellations, or different price tiers? Pricing is almost always
  a core domain concern and should never be left unexplored.
- **Exceptions and failures** — What happens when things go wrong? Cancellations,
  no-shows, refunds, rescheduling, disputes. The happy path is only half the model.
- **Communication** — Do you send confirmations, reminders, or follow-ups? Are those
  tracked, or fire-and-forget?
- **Reporting** — What do you need to measure or report on? This often reveals entities
  and relationships that don't surface in the happy-path workflow.

Ask about these naturally, one at a time, in whatever order fits the conversation. Don't
dump them all at once.

### Phase 1 Exit Checkpoint

Before moving to Phase 2, verify:

- [ ] Every noun the user mentioned has been explored, not just noted
- [ ] Money flow is understood (pricing, payments, refunds if applicable)
- [ ] The happy path AND failure cases have been discussed
- [ ] No casual mentions are left unexplored

Present a **process summary** and explicitly ask if anything is missing. This is your last
chance to catch gaps before you start defining entities. Don't just confirm what you heard —
probe for what you might not have heard: "Is there anything else that's part of the
day-to-day that we haven't touched on?"

---

## Phase 2: Entity Extraction

**Goal:** Turn the domain understanding into a clear list of entities with preliminary attributes.

### Present Candidate Entities — THE GATE

**Do NOT begin drilling individual entities until you have presented the full candidate
entity list and received explicit confirmation.** This is the most important checkpoint
in the entire process. Skipping it means you might spend time detailing the wrong things
or miss something entirely.

Show the user a plain-language list of every thing you think the system needs to track.
Keep it casual — just the names, not detailed specs. Bold each one so they're scannable.
Then ask if it looks right or if something is missing.

This is where users catch gaps. They'll say "oh, you're missing X" or "Y isn't really
its own thing, it's just a field on Z." Both reactions are valuable and save you from
building the wrong model.

Do NOT proceed until the user has confirmed the list. If they add something, update the
list and confirm again.

### Clarifying Each Entity — One at a Time

Walk through entities **one by one**. For each entity, ask **one question**, wait for the
answer, then follow up based on what they said. Don't run through a checklist.

These are the things you eventually want to understand about each entity — but discover
them through plain conversation, not technical interrogation:

- **How do they identify it?** ("Does each one have a number, a code, a name — how do
  you look one up?")
- **Does it go through stages?** ("What happens to one of these after it's created —
  does it go through steps or change status over time?")
- **Who's responsible for it?** ("Who manages these — is there an owner or point person?")
- **Do they care about history?** ("If something changes, do you need to know what it
  was before?")
- **What does 'deleting' mean to them?** ("When you get rid of one of these, is it
  gone-gone or do you keep it around for records?")

Start with whatever is most natural for that entity. If it clearly has an identifier,
ask about that. If it obviously goes through a lifecycle, ask about stages. Read the room.

Many of these will get answered implicitly in the user's responses — don't re-ask things
they've already covered.

### Watch for Hidden Entities

Users often mention things in passing that are actually important enough to track on their
own. These are internal cues for you — use plain language when asking about them:

- A "type" or "category" mentioned casually → Is that just a label, or do they maintain
  a list with descriptions, sort order, etc.? Ask: "Do you maintain a master list of
  those, or is it more freeform?"
- A detail that has its own quantity or attributes → That's probably its own thing, not
  just a field on the parent.
- A field that can have multiples → If someone can have more than one of something (two
  addresses, three phone numbers), that's its own thing. Ask: "Can there be more than
  one of those?"
- Labels or tags mentioned → Probably a managed list, not free text.

The general question to smoke these out: "Is [X] something you manage a list of, or is it
just a note someone types in?"

---

## Phase 3: Relationship Drill

**Goal:** Nail down every relationship between entities with precision. This is where most
data models go wrong, so spend the most time here.

### Drilling Relationships — Conversationally

Focus on **one relationship at a time**. Start with the most central one (usually the
connection that drives the core workflow).

For each connection between things, you need to understand how many of each side there
can be. Ask this in plain language — never say "cardinality" or "one-to-many" to the user:

- "Can one [A] have more than one [B]?" (you'll note: one-to-many)
- "Can [A] be connected to more than one [B], and can [B] be connected to more than one
  [A]?" (you'll note: many-to-many, needs a linking table — but don't say that out loud)

That single question often triggers the user to tell you more. If it doesn't, follow up
with **one** more question on whatever matters most — don't stack these up:

- "Can a [A] exist on its own without being tied to a [B]?"
- "Can a [A] be connected to more than one [B] at the same time?"
- "If you get rid of a [A], what happens to its [B]s — do they go away too, or do they
  stick around?"
- For things connected both ways: "When [A] connects to [B], is there anything you track
  about that connection itself — like a date, a status, a role?"

Move to the next connection when you have enough clarity. Don't over-drill obvious things
— if the relationship is self-evident, one question is enough.

### Relationship Summary

After drilling, present a relationship summary:

```
→ [A] → [B]         (one-to-many, required)
  One [A] can have many [B]s. Every [B] must belong to an [A].

→ [B] → [C]         (one-to-many, required, cascade delete)
  A [B] has many [C]s. Deleting a [B] removes its [C]s.

→ [D] ↔ [E]         (many-to-many via [linking name])
  [D]s connect to [E]s. The connection tracks: [relevant attributes].
```

Get explicit confirmation: "Does this look right? Anything feel off?"

---

## Phase 4: Schema Output

**Goal:** Produce the final data model in the user's preferred format.

### Ask for Target (if not already known)

Ask one question to cover the essentials — people usually know what they want here:

- "What database are you targeting, and do you want raw SQL, a Mermaid ERD, or both?"

If they don't mention naming conventions (snake_case, singular vs plural), just use the
defaults and mention what you chose when you present the schema.

### Default Output Format

If the user has no preference, produce **both**:

1. **Mermaid ERD** — visual relationship diagram (save as `.mermaid` file)
2. **SQL DDL** — complete CREATE TABLE statements (save as `.sql` file)

### Schema Generation Rules

Follow these conventions unless the user specifies otherwise:

- Table names: **snake_case, singular** (e.g., `account`, `line_item`)
- Primary keys: `id` as auto-incrementing integer or UUID (ask preference)
- Foreign keys: `[referenced_table]_id` (e.g., `account_id`)
- Timestamps: Always include `created_at` and `updated_at`
- Soft deletes: Include `deleted_at` if the user confirmed soft deletes in Phase 2
- Junction tables: Name as `[entity_a]_[entity_b]` or a domain-specific name if one
  emerged during the interview (prefer the domain name when one exists)
- Indexes: Add indexes on all foreign keys and any fields the user mentioned searching or
  filtering by
- NOT NULL: Default to NOT NULL for required fields; explicitly mark optional fields
- ENUMs or check constraints for status/state fields when the set is known and small

### Output Checklist

Before presenting the final schema, verify:

- [ ] Every entity from Phase 2 has a table
- [ ] Every relationship from Phase 3 has a foreign key (or junction table)
- [ ] Cardinality matches (one-to-many = FK on the "many" side)
- [ ] Optionality matches (required = NOT NULL on FK, optional = nullable FK)
- [ ] Cascade rules are specified (ON DELETE CASCADE/SET NULL/RESTRICT)
- [ ] All business rules from Phase 1 are encoded as constraints where possible
- [ ] Indexes exist on FKs and common lookup fields
- [ ] Timestamps included on all tables

### Present and Iterate

Show the schema and ask one thing:

- "Here's what I've got — walk through it and tell me if anything looks wrong or feels off."

That's it. Let them react. If they say it looks good, *then* you can ask about common
queries or edge cases as a follow-up. Don't front-load multiple review questions.

---

## Tone and Style

- **Be a people person, not a tech person.** You're a business analyst having a
  conversation, not a DBA conducting a requirements spec. Keep database jargon out of
  your questions entirely — figure out the technical implications silently.
- Never say: "entity", "cardinality", "one-to-many", "foreign key", "junction table",
  "nullable", "polymorphic", "soft delete", "natural key", "cascade", "constraint" in
  your questions. These are internal concepts you use when building the schema — the user
  doesn't need to hear them.
- Use the user's language — if they say "gig" instead of "job", use "gig"
- **ONE question per message.** Two max, and only if they're about the same thing. NEVER
  more. This is the most important style rule.
- Let the user's answers drive the conversation — react to what they said, then ask the
  next logical thing. Don't follow a script.
- Confirm understanding frequently with brief summaries
- When something is ambiguous, give the user two concrete options in plain language:
  "Either that's a list you maintain — with its own details, ordering, maybe
  sub-groupings — or it's just a label someone types in. Which is closer to how you
  do it?"
- Don't over-engineer — if the user has 50 customers, they don't need a sharding strategy
- Don't present numbered lists of questions — that's a survey, not a conversation

---

## Edge Cases and Gotchas

These are internal notes for you. When these situations come up, ask about them in plain
language — don't use the technical names.

### Things that refer to themselves
When something points back to itself (an employee's manager is also an employee, a
category can be inside another category):
- Ask: "Can this go several levels deep — like a category inside a category inside a
  category?" (you need to know if it's a tree or just one level)

### Things that can attach to multiple types
When something like a note or a comment can live on different kinds of records (a note on
a customer, a note on an order, a note on a product):
- You have multiple technical approaches — but present them to the user as: "Can a note
  only ever be on one kind of thing, or could the same note show up on both a customer
  and an order?" Their answer guides your implementation.

### Historical tracking
If the user mentions needing to know what something used to be:
- Ask: "When something changes, do you need a full history of every change, or is it
  more like you just need to know the current version and maybe when it last changed?"

### Multiple businesses or organizations
If the system serves more than one company:
- Ask: "Does each organization see only their own stuff, or is there anything shared
  across organizations?"

---

## Reference: Common Domain Patterns

Read `domain-patterns.md` for pre-built patterns for common business domains
(e-commerce, SaaS, medical, legal, scheduling, etc.) that can accelerate the interview
when the user's domain matches a known pattern.
