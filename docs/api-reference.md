# ContextOps — API Reference

## Overview

The ContextOps backend exposes a REST API built with FastAPI. All endpoints are prefixed with `/api/v1`.

Base URL: `http://localhost:8000/api/v1`

Interactive docs: `http://localhost:8000/docs` (Swagger UI)

---

## Incidents

### Create Incident

`POST /api/v1/incidents`

Submit a new incident for tracking and investigation.

**Request Body:**
```json
{
  "title": "Payment processing failures",
  "description": "Users reporting failed payments since 14:30 UTC. Error rate on payment-api spiked to 15%.",
  "severity": "critical",
  "symptoms": "HTTP 500 errors, increased latency, timeout errors in payment flow"
}
```

**Response (201):**
```json
{
  "id": "INC-042",
  "title": "Payment processing failures",
  "description": "Users reporting failed payments since 14:30 UTC...",
  "severity": "critical",
  "status": "open",
  "symptoms": "HTTP 500 errors, increased latency...",
  "created_at": "2026-10-16T14:35:00Z",
  "resolved_at": null
}
```

---

### List Incidents

`GET /api/v1/incidents`

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| status | string | null | Filter by status: `open`, `investigating`, `resolved`, `closed` |
| severity | string | null | Filter by severity: `critical`, `high`, `medium`, `low` |
| limit | int | 20 | Max results |
| offset | int | 0 | Pagination offset |

**Response (200):**
```json
{
  "incidents": [
    {
      "id": "INC-042",
      "title": "Payment processing failures",
      "severity": "critical",
      "status": "open",
      "created_at": "2026-10-16T14:35:00Z"
    }
  ],
  "total": 42,
  "limit": 20,
  "offset": 0
}
```

---

### Get Incident

`GET /api/v1/incidents/{incident_id}`

**Response (200):**
```json
{
  "id": "INC-042",
  "title": "Payment processing failures",
  "description": "Users reporting failed payments since 14:30 UTC...",
  "severity": "critical",
  "status": "investigating",
  "symptoms": "HTTP 500 errors, increased latency...",
  "created_at": "2026-10-16T14:35:00Z",
  "resolved_at": null,
  "affected_services": [
    {"id": "svc-001", "name": "payment-api", "tier": "critical"}
  ]
}
```

---

## Investigation

### Trigger Investigation

`POST /api/v1/incidents/{incident_id}/investigate`

Trigger the multi-agent investigation workflow for an incident.

**Response (202):**
```json
{
  "investigation_id": "INV-042-001",
  "incident_id": "INC-042",
  "status": "in_progress",
  "started_at": "2026-10-16T14:36:00Z"
}
```

---

### Get Investigation Results

`GET /api/v1/incidents/{incident_id}/investigation`

Retrieve the results of the most recent investigation for an incident.

**Response (200):**
```json
{
  "investigation_id": "INV-042-001",
  "incident_id": "INC-042",
  "status": "completed",
  "started_at": "2026-10-16T14:36:00Z",
  "completed_at": "2026-10-16T14:36:45Z",
  "summary": "Investigation identified Redis connection pool exhaustion as the likely root cause...",
  "findings": {
    "affected_services": [
      {"name": "payment-api", "tier": "critical"},
      {"name": "checkout-service", "tier": "critical"}
    ],
    "dependency_chains": [
      ["payment-api", "redis-primary", "redis-sentinel"]
    ],
    "recent_deployments": [
      {
        "service": "payment-api",
        "version": "v2.14.3",
        "deployed_at": "2026-10-16T13:00:00Z",
        "deployed_by": "alice"
      }
    ],
    "suspect_changes": [
      {
        "description": "Updated Redis connection pool settings",
        "author": "alice",
        "type": "config",
        "deployment_version": "v2.14.3"
      }
    ],
    "similar_incidents": [
      {
        "id": "INC-021",
        "title": "Redis connection timeouts affecting payments",
        "shared_services": ["payment-api"],
        "resolution": "Increased Redis connection pool max size from 10 to 50"
      }
    ]
  }
}
```

---

### Get Recommendations

`GET /api/v1/incidents/{incident_id}/recommendations`

Get the agent's ranked recommendations with explainability paths.

**Response (200):**
```json
{
  "incident_id": "INC-042",
  "recommendations": [
    {
      "rank": 1,
      "recommendation": "Roll back payment-api to v2.14.2 and investigate the Redis connection pool configuration change",
      "confidence": 0.87,
      "reasoning": "A configuration change to Redis connection pool settings was deployed to payment-api 90 minutes before the incident. A similar incident (INC-021) involving Redis connection issues on the same service was resolved by adjusting pool settings.",
      "graph_path": [
        {"node": "INC-042", "type": "Incident"},
        {"rel": "AFFECTS"},
        {"node": "payment-api", "type": "Service"},
        {"rel": "DEPLOYED_TO (incoming)"},
        {"node": "v2.14.3", "type": "Deployment"},
        {"rel": "INCLUDED_IN (incoming)"},
        {"node": "Redis pool config change", "type": "Change"}
      ]
    },
    {
      "rank": 2,
      "recommendation": "Contact Alice (alice@company.com) who authored the change and resolved INC-021",
      "confidence": 0.72,
      "reasoning": "Alice authored the suspect change and previously resolved a similar Redis-related incident on the same service.",
      "graph_path": [
        {"node": "INC-042", "type": "Incident"},
        {"rel": "AFFECTS"},
        {"node": "payment-api", "type": "Service"},
        {"rel": "AFFECTS (incoming from INC-021)"},
        {"node": "INC-021", "type": "Incident"},
        {"rel": "RESOLVED (incoming)"},
        {"node": "Alice", "type": "Engineer"}
      ]
    }
  ]
}
```

---

## Graph Exploration

### Explore Graph

`GET /api/v1/graph/explore`

Explore the graph around a specific node. Used by the frontend graph visualizer.

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| node_id | string | required | ID of the center node |
| node_type | string | required | Node label (e.g., `Incident`, `Service`) |
| depth | int | 1 | How many hops to traverse |
| limit | int | 50 | Max nodes to return |

**Response (200):**
```json
{
  "nodes": [
    {"id": "INC-042", "type": "Incident", "properties": {"title": "Payment failures", "severity": "critical"}},
    {"id": "svc-001", "type": "Service", "properties": {"name": "payment-api", "tier": "critical"}},
    {"id": "dep-redis", "type": "Dependency", "properties": {"name": "redis-primary", "type": "cache"}}
  ],
  "edges": [
    {"source": "INC-042", "target": "svc-001", "type": "AFFECTS"},
    {"source": "svc-001", "target": "dep-redis", "type": "DEPENDS_ON"}
  ]
}
```

---

### Get Graph Path

`GET /api/v1/graph/path`

Get a specific graph path (used for "Show me why" explainability).

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| start_id | string | Starting node ID |
| start_type | string | Starting node label |
| end_id | string | Ending node ID |
| end_type | string | Ending node label |
| max_depth | int | Maximum path length (default: 6) |

**Response (200):**
```json
{
  "path": [
    {"node": {"id": "INC-042", "type": "Incident", "properties": {...}}},
    {"relationship": "AFFECTS"},
    {"node": {"id": "svc-001", "type": "Service", "properties": {...}}},
    {"relationship": "DEPENDS_ON"},
    {"node": {"id": "dep-redis", "type": "Dependency", "properties": {...}}}
  ],
  "length": 2
}
```

---

## Health

### Health Check

`GET /api/v1/health`

**Response (200):**
```json
{
  "status": "healthy",
  "falkordb": "connected",
  "graph_nodes": 156,
  "graph_edges": 423,
  "version": "0.1.0"
}
```

---

## Error Responses

All endpoints return errors in a consistent format:

```json
{
  "detail": "Incident INC-999 not found"
}
```

| Status | Meaning |
|--------|---------|
| 400 | Bad request (invalid parameters) |
| 404 | Resource not found |
| 422 | Validation error (malformed request body) |
| 500 | Internal server error |
| 503 | FalkorDB unavailable |
