---
inclusion: always
---

# ContextOps — Hackathon Rules (Critical)

## Timing constraint

Substantive coding and design implementation must begin AFTER:
2026-10-15, 12:01 AM IST

Before that date, only preparation is allowed:
- Architecture planning, graph modeling, documentation, notes, diagrams
- Repository setup, research, development environment preparation

Do NOT implement the actual hackathon solution (agent logic, graph client code, API handlers, working frontend) before the event begins. Scaffolding, schemas, docs, and seed data are preparation and are allowed.

## Coding principles (when implementation begins)

1. FalkorDB must perform meaningful work.
2. Prefer graph traversal over unnecessary duplication into another database.
3. Keep the architecture understandable.
4. Avoid unnecessary microservices.
5. Keep the number of agents small and purposeful.
6. Every important Cypher query must be documented.
7. Every major technical decision must be explainable by the project author.
8. Do not blindly generate code with AI.
9. Verify all generated code.
10. Keep the final project easy to run locally.

## AI assistant usage

AI coding assistance is allowed but must be disclosed. Any AI-generated code must be reviewed, tested, understood, and modified by the author. Never claim understanding of code that has not been verified.

## Git identity

Use the repository's local Git config. Do NOT change global Git identity or credentials.

Expected identity:
- Name: Dev Anand J
- Email: devanand3254@gmail.com

Always push to a branch and open a PR; never force-push or push directly to main unless explicitly asked.
