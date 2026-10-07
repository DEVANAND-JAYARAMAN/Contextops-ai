# ContextOps — Architecture Document

## Overview

ContextOps is a graph-powered AI incident response system. It uses a multi-agent architecture where specialized AI agents traverse a FalkorDB knowledge graph to investigate incidents, retrieve historical context, and recommend resolutions with full explainability.

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      User Interface                      │
│                    (React + TypeScript)                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  Incident     │  │  Graph       │  │  History      │  │
│  │  Dashboard    │  │  Visualizer  │  │  Explorer     │  │
│  └──────────────┘  └──────────────┘  └───────────────┘  │
│                                                          │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP / WebSocket
┌──────────────────────┴──────────────────────────────────┐
│                     FastAPI Backend                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │              API Layer (REST endpoints)            │   │
│  │  POST /incidents    GET /incidents/{id}            │   │
│  │  POST /investigate  GET /graph/explore             │   │
│  │  GET /recommendations/{id}                         │   │
│  └────────────────────┬─────────────────────────────┘   │
│                       │                                   │
│  ┌────────────────────┴─────────────────────────────┐   │
│  │            Agent Orchestrator                      │   │
│  │  Coordinates agent execution, manages state,       │   │
│  │  merges results, handles agent communication       │   │
│  └──┬──────────────┬──────────────┬─────────────────┘   │
│     │              │              │                       │
│  ┌──┴───────┐  ┌──┴───────┐  ┌──┴───────────┐          │
│  │Investigator│ │ Memory   │  │  Resolution  │          │
│  │  Agent    │  │  Agent   │  │    Agent     │          │
│  └──┬───────┘  └──┬───────┘  └──┬───────────┘          │
│     │              │              │                       │
│  ┌──┴──────────────┴──────────────┴─────────────────┐   │
│  │              Graph Service Layer                    │   │
│  │  FalkorDB client, Cypher query builder,             │   │
│  │  connection pooling, result parsing                  │   │
│  └────────────────────┬─────────────────────────────┘   │
│                       │                                   │
└──────────────────────┬──────────────────────────────────┘
                       │ Redis protocol
┌──────────────────────┴──────────────────────────────────┐
│                      FalkorDB                            │
│              (Graph Database Engine)                      │
│                                                          │
│  Nodes: Incident, Service, Dependency, Deployment,       │
│         Change, Engineer, Project, RootCause,            │
│         Resolution, Investigation, Decision              │
│                                                          │
│  Relationships: AFFECTS, DEPENDS_ON, CAUSED_BY,         │
│                 RESOLVED_BY, SIMILAR_TO, ...             │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### 1. React Frontend

**Purpose:** Provide the user interface for submitting incidents, viewing investigations, and exploring the graph.

**Key Views:**
- **Incident Dashboard** — Submit new incidents, view active/resolved incidents
- **Investigation View** — Real-time display of agent investigation progress, findings, and recommendations
- **Graph Visualizer** — Interactive visualization of the graph path behind a recommendation ("Show me why")
- **History Explorer** — Browse past incidents and their resolutions

**Communication:**
- REST API calls to the backend for CRUD operations
- Optional WebSocket for real-time investigation progress updates

### 2. FastAPI Backend

**Purpose:** Serve the REST API, orchestrate agents, and manage FalkorDB interactions.

**Layers:**
- **API Layer** — Route handlers, request validation, response serialization
- **Agent Orchestrator** — Coordinates multi-agent workflow, manages execution order and data passing
- **Agent Layer** — Individual agent implementations with specific investigation roles
- **Graph Service** — FalkorDB client wrapper, Cypher query execution, connection management
- **Models** — Pydantic schemas for data validation and serialization

### 3. Agent Orchestrator

**Purpose:** Coordinate the multi-agent investigation workflow.

**Workflow:**

```
Incident Submitted
       │
       ▼
┌──────────────┐
│ Investigator  │  1. Identify affected services
│    Agent      │  2. Traverse dependencies
│               │  3. Find potential root causes
└──────┬───────┘
       │ findings
       ▼
┌──────────────┐
│   Memory      │  4. Search for similar past incidents
│    Agent      │  5. Retrieve past resolutions
│               │  6. Identify patterns
└──────┬───────┘
       │ historical context
       ▼
┌──────────────┐
│  Resolution   │  7. Synthesize all findings
│    Agent      │  8. Rank recommendations
│               │  9. Build explainability paths
└──────┬───────┘
       │
       ▼
  Recommendation
  with graph path
```

**State Sharing:** Agents share context through a structured investigation state object that accumulates findings as each agent completes its phase. This avoids tight coupling between agents while still allowing downstream agents to build on upstream results.

### 4. FalkorDB

**Purpose:** Store and query the connected knowledge graph.

**Why FalkorDB:**
- Native graph database with Cypher support
- Redis-compatible protocol (familiar tooling)
- Fast subgraph traversal for real-time agent queries
- Lightweight enough for local development

**Usage Principles:**
- FalkorDB is the primary data store, not a secondary visualization layer
- All relationship traversal happens in Cypher, not in application code
- Complex multi-hop queries (e.g., "find similar incidents through shared root causes") are expressed as graph queries

## Data Flow: Incident Investigation

```
1. User submits incident → POST /incidents
2. Backend creates Incident node in FalkorDB
3. Backend triggers Agent Orchestrator
4. Investigator Agent:
   - Queries: affected services, dependencies
   - Queries: recent deployments to those services
   - Queries: recent changes that touch those services
   - Returns: list of suspects (services, changes, deployments)
5. Memory Agent:
   - Queries: past incidents with similar symptoms or affected services
   - Queries: how those incidents were resolved
   - Returns: historical context and pattern matches
6. Resolution Agent:
   - Receives findings from both agents
   - Uses LLM to synthesize a recommendation
   - Builds graph path for each recommendation (explainability)
   - Returns: ranked recommendations with "why" paths
7. Backend stores Investigation, Decision nodes in FalkorDB
8. Backend returns results to frontend
9. Frontend displays recommendation + "Show me why" graph path
```

## API Endpoints (Planned)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/incidents` | Submit a new incident |
| GET | `/api/v1/incidents` | List all incidents |
| GET | `/api/v1/incidents/{id}` | Get incident details |
| POST | `/api/v1/incidents/{id}/investigate` | Trigger investigation |
| GET | `/api/v1/incidents/{id}/investigation` | Get investigation results |
| GET | `/api/v1/incidents/{id}/recommendations` | Get recommendations with graph paths |
| GET | `/api/v1/graph/explore` | Explore graph around a node |
| GET | `/api/v1/graph/path` | Get specific graph path |
| GET | `/api/v1/health` | Health check |

## Scalability Considerations

This is a hackathon project optimized for clarity and demonstration, not production scale. However, the architecture supports future scaling:

- **Agent parallelism:** Investigator and Memory agents could run concurrently
- **Graph partitioning:** FalkorDB supports multiple named graphs
- **Caching:** Frequent graph traversals could be cached at the service layer
- **Streaming:** WebSocket support enables real-time investigation progress

## Security Notes

- No authentication in the hackathon version (would be added for production)
- LLM API keys stored in environment variables, never committed
- FalkorDB password optional for local development
