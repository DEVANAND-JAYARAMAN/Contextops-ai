# ContextOps — Graph-Powered AI Incident Response

[![Graph Hacks Hackathon](https://img.shields.io/badge/Graph%20Hacks-2026-blue)](https://github.com/DEVANAND-JAYARAMAN/contextops-ai)
[![FalkorDB](https://img.shields.io/badge/Powered%20by-FalkorDB-orange)](https://www.falkordb.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**ContextOps** is an AI-powered incident response system that investigates engineering incidents by reasoning over connected data stored in [FalkorDB](https://www.falkordb.com/). Instead of treating incidents as isolated events, ContextOps traverses a knowledge graph of services, dependencies, deployments, engineers, and historical incidents to deliver context-rich recommendations with full explainability.

Built for the [Graph Hacks: Context for AI Agents](https://hashnode.com/hackathons/graphhacks) hackathon by WeMakeDevs and FalkorDB.

**Primary Track:** Agents That Act on Connected Data
**Secondary Track:** Agent Memory and Coordination

---

## Why ContextOps?

When an incident happens, engineers waste valuable time:
- Searching Slack for past incidents
- Asking "who fixed this last time?"
- Manually tracing service dependencies
- Guessing at root causes

ContextOps solves this by encoding organizational knowledge into a graph and letting AI agents traverse it. Every recommendation comes with a "Show me why" explanation rooted in actual graph relationships.

### Questions ContextOps Can Answer

- What services are affected by this incident?
- What dependencies could explain the failure?
- Have we seen a similar incident before?
- Who previously resolved a similar incident?
- What deployment or configuration change may have caused this?
- What should the engineering team investigate next?

---

## Architecture

```
                    User
                     |
                     v
               React Frontend
                     |
                     v
                FastAPI API
                     |
                     v
              Agent Orchestrator
                     |
          +----------+----------+
          |          |          |
          v          v          v
   Investigator   Memory    Resolution
      Agent       Agent       Agent
          |          |          |
          +----------+----------+
                     |
                     v
                 FalkorDB
                     |
                     v
              Connected Context
```

### Agent Roles

| Agent | Responsibility |
|-------|---------------|
| **Investigator Agent** | Analyzes incidents, traverses the graph to identify affected services, dependencies, and potential root causes |
| **Memory Agent** | Retrieves historical incidents, past resolutions, and pattern matches from the graph |
| **Resolution Agent** | Synthesizes findings from other agents and recommends actionable resolution steps with graph-backed explanations |

### Explainability

Every recommendation is traceable through the graph:

```
Payment API → DEPENDS_ON → Redis → AFFECTED_BY → Incident #21 → RESOLVED_BY → Engineer
```

The UI provides a "Show me why" experience that exposes the relevant graph path behind each recommendation.

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend API | Python, FastAPI |
| Frontend | React, TypeScript |
| Graph Database | FalkorDB (Redis-compatible) |
| Query Language | Cypher |
| Containerization | Docker, Docker Compose |
| LLM Integration | TBD (evaluated during implementation) |
| Agent Framework | TBD (evaluated during implementation) |

---

## Project Structure

```
contextops-ai/
├── backend/                  # FastAPI application
│   ├── app/
│   │   ├── api/              # API route handlers
│   │   ├── agents/           # AI agent implementations
│   │   ├── core/             # Configuration, settings
│   │   ├── graph/            # FalkorDB client, Cypher queries
│   │   ├── models/           # Pydantic data models
│   │   ├── services/         # Business logic
│   │   └── main.py           # FastAPI entry point
│   ├── tests/
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                 # React application
│   ├── src/
│   │   ├── components/       # UI components
│   │   ├── pages/            # Page-level views
│   │   ├── services/         # API client
│   │   ├── types/            # TypeScript types
│   │   └── App.tsx
│   ├── package.json
│   └── Dockerfile
├── graph/                    # Graph schema and seed data
│   ├── schema.cypher         # Graph schema definition
│   └── seed_data.cypher      # Synthetic incident data
├── docs/                     # Documentation
│   ├── architecture.md
│   ├── graph-model.md
│   ├── api-reference.md
│   ├── agent-design.md
│   └── cypher-queries.md
├── docker-compose.yml        # Full stack orchestration
├── .env.example              # Environment variable template
├── .gitignore
├── LICENSE
└── README.md
```

---

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Python 3.11+](https://www.python.org/) (for local backend dev)
- [Node.js 20+](https://nodejs.org/) (for local frontend dev)

### Run with Docker

```bash
# Clone the repository
git clone https://github.com/DEVANAND-JAYARAMAN/contextops-ai.git
cd contextops-ai

# Copy environment variables
cp .env.example .env

# Start all services
docker-compose up --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8000 |
| API Docs | http://localhost:8000/docs |
| FalkorDB | localhost:6379 |

### Local Development

```bash
# Backend
cd backend
python -m venv venv
venv\Scripts\activate       # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Frontend
cd frontend
npm install
npm run dev
```

---

## Graph Schema

See [docs/graph-model.md](docs/graph-model.md) for the full graph data model.

### Node Types

`Incident`, `Service`, `Dependency`, `Deployment`, `Change`, `Engineer`, `Project`, `RootCause`, `Resolution`, `Investigation`, `Decision`

### Key Relationships

`AFFECTS`, `DEPENDS_ON`, `DEPLOYED_TO`, `CAUSED_BY`, `RESOLVED_BY`, `INVESTIGATED_BY`, `SIMILAR_TO`, `PART_OF`, `INTRODUCED_BY`, `LED_TO`

---

## Hackathon Disclosure

This project was built for Graph Hacks 2026. AI coding assistance (Kiro) was used during development. All AI-generated code was reviewed, tested, understood, and modified by the project author.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## Author

**Dev Anand J**
- GitHub: [@DEVANAND-JAYARAMAN](https://github.com/DEVANAND-JAYARAMAN)
- Email: devanand3254@gmail.com
