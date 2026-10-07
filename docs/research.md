# ContextOps — Research Notes

This document captures research and decisions made during the pre-hackathon preparation phase. All substantive coding happens after the hackathon start date (2026-10-15 00:01 IST).

## FalkorDB

FalkorDB is a graph database that uses the Redis protocol and supports a subset of the Cypher query language.

**Key points relevant to ContextOps:**
- Property graph model (nodes + relationships, both with properties)
- Cypher query support (OpenCypher-compatible subset)
- Runs as a Redis module — fast, in-memory with persistence
- Official Python client available (`falkordb` on PyPI)
- Supports variable-length path traversal (`*1..3`), which is central to our dependency-chain and similarity queries
- Supports indexes on node properties for fast lookups

**Why FalkorDB fits the hackathon:**
The hackathon is specifically about using graph databases for AI agent context. FalkorDB being the sponsor's product and purpose-built for graph traversal makes it the natural fit. Our design keeps all relationship reasoning in Cypher rather than loading data into application memory and traversing manually.

**Verification needed during implementation:**
- Confirm exact Cypher feature support (some OpenCypher features may differ)
- Confirm `datetime()` function behavior for timestamp comparisons
- Confirm variable-length path syntax and performance characteristics
- Test the Python client's result parsing format

> Content was rephrased for compliance with licensing restrictions. Verify all details against the official FalkorDB documentation during implementation.

## Agent Framework Candidates

| Framework | Pros | Cons |
|-----------|------|------|
| LangGraph | Explicit state graph, good for multi-agent orchestration, mature | Steeper learning curve, more dependencies |
| CrewAI | Multi-agent focused, simple role-based API | Less control over fine-grained flow |
| Direct API calls | Full control, minimal dependencies, easy to explain | More boilerplate to write |

**Leaning toward:** Direct API calls or LangGraph. For a hackathon where every technical decision must be explainable, minimal dependencies and clear control flow are valuable. The orchestration in ContextOps is sequential and simple (Investigator → Memory → Resolution), so a heavy framework may be unnecessary.

**Decision deferred to implementation.**

## LLM Provider Candidates

| Provider | Model | Notes |
|----------|-------|-------|
| OpenAI | GPT-4o / GPT-4o-mini | Strong reasoning, good structured output |
| Anthropic | Claude | Strong at structured analysis and long context |
| Google | Gemini | Good cost/capability balance |
| Ollama (local) | Llama / Mistral | No API cost, runs offline, lower capability |

**Consideration:** For a demo, response quality matters. For cost control during development, a smaller/cheaper model or local model may be used. The system is designed to be LLM-agnostic so this can be swapped.

**Decision deferred to implementation.**

## Synthetic Data Strategy

Since real incident data is sensitive and not publicly available in graph form, ContextOps uses synthetic data modeled on realistic engineering scenarios:
- A realistic microservice topology (payment, checkout, order, user, search, etc.)
- Realistic infrastructure dependencies (Redis, Postgres, RabbitMQ, Elasticsearch, external APIs)
- Four historical resolved incidents with full root cause and resolution chains
- A recent deployment designed to create a plausible "new incident" demo scenario

The seed data lives in `graph/seed_data.cypher` and is designed to make the graph traversals produce meaningful, demonstrable results.

## Demo Scenario (Planned)

The seed data sets up a specific demo:

1. A new incident is submitted: "Payment API intermittent failures"
2. The Investigator Agent finds `payment-api` is affected
3. It traverses dependencies and finds `redis-primary`
4. It finds a recent deployment (`v2.14.3`, deploy-005) with a Redis timeout config change (chg-005)
5. The Memory Agent finds INC-021 — a past Redis-related incident on the same service, resolved by Alice
6. The Resolution Agent recommends investigating the Redis timeout change and contacting Alice
7. The "Show me why" view shows: Incident → payment-api → Deployment v2.14.3 → Redis timeout change

This scenario exercises every part of the system and demonstrates graph-powered reasoning end-to-end.

## Open Questions for Implementation

- How to compute incident similarity? (shared services, shared root cause category, symptom text embedding?)
- Should the Memory Agent use vector embeddings for symptom similarity, or rely purely on graph structure?
- How to render the graph path in the frontend? (vis-network, cytoscape, d3-force?)
- How much LLM synthesis vs. deterministic graph results in the final recommendation?
