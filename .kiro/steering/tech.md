# ContextOps — Technology & Conventions

## Stack

- Backend: Python 3.11+, FastAPI, Uvicorn
- Graph DB: FalkorDB (Redis protocol), queried with Cypher
- Frontend: React 18, TypeScript, Vite
- Containerization: Docker, Docker Compose
- LLM/agent framework: finalized during implementation (LLM-agnostic design)

## Project layout

- `backend/app/api` — route handlers
- `backend/app/agents` — Investigator, Memory, Resolution agents + orchestrator
- `backend/app/graph` — FalkorDB client and Cypher queries
- `backend/app/models` — Pydantic schemas
- `backend/app/core` — config/settings
- `frontend/src` — React app (components, pages, services, types)
- `graph/` — schema.cypher and seed_data.cypher
- `docs/` — architecture, graph model, API reference, agent design, Cypher queries, research

## Commands (Windows / PowerShell)

- Backend dev: `uvicorn app.main:app --reload --port 8000` (run from `backend/`, venv active)
- Frontend dev: `npm run dev` (run from `frontend/`)
- Full stack: `docker-compose up --build`
- Separate commands with `;` not `&&`

## Conventions

- Python: PEP 8, type hints everywhere, Pydantic for request/response bodies
- Cypher: parameterized queries only; bound variable-length paths (e.g. `*1..3`, never `*`)
- Document every significant Cypher query in `docs/cypher-queries.md`
- Frontend: functional components with hooks; API types in `src/types`; API calls in `src/services`

## Agents

Keep agents small and purposeful. Three agents only:
- Investigator — identifies affected services, dependencies, suspect changes
- Memory — retrieves similar past incidents, resolutions, patterns
- Resolution — synthesizes findings into ranked, explainable recommendations

They run sequentially and share a typed InvestigationState object.
