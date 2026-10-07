# Contributing to ContextOps

ContextOps is a hackathon project built for Graph Hacks 2026. This guide covers local setup and development conventions.

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Python 3.11+
- Node.js 20+

### Running Locally

```bash
# Start FalkorDB only (for backend development)
docker-compose up falkordb

# Backend (in a separate terminal)
cd backend
python -m venv venv
venv\Scripts\activate       # Windows
# source venv/bin/activate  # macOS/Linux
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Frontend (in a separate terminal)
cd frontend
npm install
npm run dev
```

### Loading Graph Data

```bash
# Once FalkorDB is running, load the schema and seed data.
# (The exact loader command will be documented when the graph client is implemented.)
# Schema:    graph/schema.cypher
# Seed data: graph/seed_data.cypher
```

## Code Conventions

### Backend (Python)

- Follow PEP 8
- Use type hints everywhere
- Use Pydantic models for all API request/response bodies
- Keep Cypher queries documented in `docs/cypher-queries.md`
- Every graph query should have a clear purpose and comment

### Frontend (TypeScript/React)

- Use functional components with hooks
- Keep API types in `src/types`
- Keep API calls in `src/services`

### Cypher

- Document every significant query in `docs/cypher-queries.md`
- Use parameterized queries (never string interpolation of user input)
- Bound variable-length path traversals (e.g., `*1..3`, not `*`)

## Git Workflow

- Branch from `main`
- Use descriptive branch names (e.g., `feature/investigator-agent`)
- Keep commits focused and well-described
- Open a pull request for review

## Hackathon Rules Reminder

- Substantive coding begins after 2026-10-15 00:01 IST
- AI assistance is allowed but must be disclosed
- All AI-generated code must be reviewed, tested, and understood by the author
- FalkorDB must perform meaningful work — prefer graph traversal over data duplication

## Core Principles

1. FalkorDB performs meaningful work.
2. Prefer graph traversal over duplication into another database.
3. Keep the architecture understandable.
4. Avoid unnecessary microservices.
5. Keep the number of agents small and purposeful.
6. Document every important Cypher query.
7. Every major technical decision must be explainable.
8. Do not blindly generate code with AI.
9. Verify all generated code.
10. Keep the final project easy to run locally.
