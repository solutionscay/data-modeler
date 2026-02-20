# Data Modeler

A Claude Code skill that designs database schemas through natural conversation. Instead of jumping straight to tables and columns, it interviews you about your business first — then builds a precise data model from what it learned.

## What it does

- Asks about your business, one question at a time, like a good analyst would
- Identifies the things your system needs to track and how they connect
- Produces a complete SQL schema and Mermaid ERD when it has enough understanding
- Targets Postgres, MySQL, SQLite, or whatever you're using

## Install

Copy the `data-modeler` folder into your Claude Code skills directory:

```
~/.claude/skills/data-modeler/
```

Then tell Claude you need help with a database, or just say `/data-modeler`.

## Files

- `SKILL.md` — the skill definition (interview process, schema rules, tone)
- `domain-patterns.md` — reference patterns for common domains (e-commerce, SaaS, healthcare, legal, scheduling, CRM, inventory)
