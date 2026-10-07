# ContextOps — Agent Design Document

## Overview

ContextOps uses a small, purposeful set of AI agents to investigate incidents. Each agent has a clear responsibility and communicates through a shared investigation state. The design avoids unnecessary complexity — three agents are enough to demonstrate graph-powered reasoning.

## Design Principles

1. **Small and purposeful** — Three agents, each with a clear role. No agent sprawl.
2. **Graph-first** — Agents reason by querying the graph, not by relying solely on LLM knowledge.
3. **Structured handoff** — Agents pass typed data to each other via a shared investigation state.
4. **Explainable** — Every recommendation must trace back to a graph path.
5. **Sequential by default** — Agents run in sequence for clarity. Parallelism is a future optimization.

## Agent Inventory

| Agent | Input | Output | FalkorDB Usage |
|-------|-------|--------|----------------|
| Investigator | Incident details | Affected services, suspects, dependency chains | Traverses AFFECTS, DEPENDS_ON, DEPLOYED_TO, INCLUDED_IN |
| Memory | Investigation findings | Historical matches, past resolutions, patterns | Traverses SIMILAR_TO, CAUSED_BY, RESOLVED_BY |
| Resolution | Combined findings | Ranked recommendations with graph paths | Reads full paths, writes Investigation and Decision nodes |

## Shared Investigation State

All agents read from and write to a shared investigation state object. This avoids tight coupling while enabling downstream agents to build on upstream work.

```python
@dataclass
class InvestigationState:
    """Shared state passed between agents during investigation."""

    # Input
    incident_id: str
    incident: dict  # Full incident data

    # Investigator Agent output
    affected_services: list[dict]       # Services hit by the incident
    dependency_chains: list[dict]       # Transitive dependency paths
    recent_deployments: list[dict]      # Deployments in the time window
    suspect_changes: list[dict]         # Changes that may have caused it
    potential_root_causes: list[dict]   # Candidate root causes

    # Memory Agent output
    similar_incidents: list[dict]       # Past incidents with shared traits
    past_resolutions: list[dict]        # How similar incidents were resolved
    patterns: list[dict]               # Recurring root cause patterns

    # Resolution Agent output
    recommendations: list[dict]         # Ranked recommendations
    graph_paths: list[dict]            # Explainability paths per recommendation
    investigation_summary: str          # Human-readable summary
```

## Agent Details

### Investigator Agent

**Role:** Analyze the incident, identify affected infrastructure, and gather evidence.

**Workflow:**
1. Receive incident details
2. Query FalkorDB for services affected by the incident
3. Traverse dependency chains (1-3 hops) from affected services
4. Find recent deployments to affected services (within configurable time window)
5. Find changes included in those deployments
6. Identify potential root causes based on graph relationships
7. Write findings to investigation state

**Key Cypher Queries Used:**
- Find affected services
- Traverse transitive dependencies
- Find recent deployments
- Find changes that could have caused the incident

**LLM Usage:**
- Summarize findings into a structured analysis
- Prioritize suspects based on severity and timing

### Memory Agent

**Role:** Search for historical context — similar incidents, past resolutions, and recurring patterns.

**Workflow:**
1. Receive investigation state (with Investigator findings)
2. Use affected services to find past incidents that hit the same services
3. Check for incidents with similar symptoms (if available)
4. Retrieve resolutions for similar past incidents
5. Identify recurring root cause patterns across historical data
6. Write historical context to investigation state

**Key Cypher Queries Used:**
- Find similar past incidents (by shared services)
- Find how similar incidents were resolved
- Find patterns across incidents
- Find the expert for a given service

**LLM Usage:**
- Score similarity between current and past incidents
- Summarize relevant historical context

### Resolution Agent

**Role:** Synthesize all findings into actionable recommendations with graph-backed explanations.

**Workflow:**
1. Receive full investigation state
2. Analyze suspect changes, dependency chains, and historical matches
3. Use LLM to synthesize findings into ranked recommendations
4. For each recommendation, build the graph path that supports it
5. Create Investigation and Decision nodes in FalkorDB
6. Return final recommendations to the user

**Key Cypher Queries Used:**
- Build explainability paths
- Write Investigation node
- Write Decision nodes with graph paths

**LLM Usage:**
- Synthesize multi-source evidence into coherent recommendations
- Rank recommendations by confidence
- Generate human-readable reasoning for each recommendation

## Agent-to-Graph Query Mapping

| Agent | Question | Cypher Pattern |
|-------|----------|---------------|
| Investigator | What services are affected? | `(Incident)-[:AFFECTS]->(Service)` |
| Investigator | What do those services depend on? | `(Service)-[:DEPENDS_ON*1..3]->(dep)` |
| Investigator | What was recently deployed? | `(Service)<-[:DEPLOYED_TO]-(Deployment)` |
| Investigator | What changes went out? | `(Deployment)<-[:INCLUDED_IN]-(Change)` |
| Memory | Have we seen this before? | `(Service)<-[:AFFECTS]-(past:Incident)` |
| Memory | How was it fixed? | `(Incident)-[:RESOLVED_BY]->(Resolution)` |
| Memory | Who knows this service? | `(Engineer)-[:RESOLVED]->(Incident)-[:AFFECTS]->(Service)` |
| Memory | What patterns exist? | `(RootCause)<-[:CAUSED_BY]-(Incident)` |
| Resolution | What's the evidence chain? | Full path traversal from Incident to Change |
| Resolution | Record the investigation | Create Investigation and Decision nodes |

## Orchestration Flow

```
                    ┌─────────────┐
                    │   API Call    │
                    │ POST /investigate
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Create      │
                    │  InvestigationState
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ Investigator │
                    │    Agent     │
                    │              │
                    │ • affected_services
                    │ • dependency_chains
                    │ • recent_deployments
                    │ • suspect_changes
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Memory     │
                    │    Agent     │
                    │              │
                    │ • similar_incidents
                    │ • past_resolutions
                    │ • patterns
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Resolution  │
                    │    Agent     │
                    │              │
                    │ • recommendations
                    │ • graph_paths
                    │ • investigation_summary
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Return      │
                    │  Results     │
                    └─────────────┘
```

## LLM Integration Points

The agent framework and LLM provider will be finalized during implementation. The architecture is designed to be LLM-agnostic:

- Each agent constructs a prompt from its findings
- The prompt includes structured data from graph queries
- The LLM generates analysis, synthesis, or recommendations
- The agent validates LLM output against graph data

**Candidate LLM frameworks:**
- LangChain / LangGraph — mature, extensive tool support
- CrewAI — multi-agent focused, simpler API
- Custom with direct API calls — maximum control, minimal dependencies

**Candidate LLM providers:**
- OpenAI (GPT-4o) — strong reasoning
- Anthropic (Claude) — strong at structured analysis
- Google (Gemini) — good balance of cost and capability
- Local models via Ollama — for privacy-sensitive scenarios

The final choice will balance capability, cost, and hackathon time constraints.

## Error Handling

- If an agent fails, the orchestrator records the failure and continues with available data
- Partial results are still returned (e.g., if Memory Agent fails, Investigator findings are still shown)
- Graph query timeouts are caught and logged
- LLM failures fall back to a "raw findings" presentation without synthesis

## Future Considerations (Post-Hackathon)

- Agent parallelism (Investigator and Memory in parallel)
- Feedback loop (user confirms/rejects recommendations, improving future investigations)
- Streaming investigation progress via WebSocket
- Additional agents (e.g., AlertCorrelationAgent, CommunicationAgent)
