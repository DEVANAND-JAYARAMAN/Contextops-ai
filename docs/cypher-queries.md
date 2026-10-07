# ContextOps — Cypher Query Reference

## Overview

This document catalogs every significant Cypher query used by ContextOps. Each query is documented with its purpose, which agent uses it, expected parameters, and example results.

All queries run against FalkorDB using the `contextops` graph.

---

## Schema Setup

### Create indexes for performance

```cypher
// Node indexes for fast lookups
CREATE INDEX FOR (i:Incident) ON (i.id)
CREATE INDEX FOR (s:Service) ON (s.id)
CREATE INDEX FOR (s:Service) ON (s.name)
CREATE INDEX FOR (d:Dependency) ON (d.id)
CREATE INDEX FOR (dep:Deployment) ON (dep.id)
CREATE INDEX FOR (c:Change) ON (c.id)
CREATE INDEX FOR (e:Engineer) ON (e.id)
CREATE INDEX FOR (e:Engineer) ON (e.email)
CREATE INDEX FOR (p:Project) ON (p.id)
CREATE INDEX FOR (rc:RootCause) ON (rc.id)
CREATE INDEX FOR (r:Resolution) ON (r.id)
CREATE INDEX FOR (inv:Investigation) ON (inv.id)
CREATE INDEX FOR (d:Decision) ON (d.id)
```

---

## Investigator Agent Queries

### Q1: Find services affected by an incident

**Purpose:** First step in any investigation — identify what services are impacted.

**Parameters:** `$incident_id` — the incident identifier

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)
RETURN s.id, s.name, s.tier, s.team
```

**Example result:**
| s.id | s.name | s.tier | s.team |
|------|--------|--------|--------|
| svc-001 | payment-api | critical | payments |
| svc-003 | checkout-service | critical | commerce |

---

### Q2: Find transitive dependencies of affected services

**Purpose:** Discover the full blast radius by traversing dependency chains up to 3 hops deep.

**Parameters:** `$incident_id`

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)
MATCH (s)-[:DEPENDS_ON*1..3]->(dep)
RETURN s.name AS source_service,
       [n IN nodes(path) | n.name] AS dependency_chain,
       dep.name AS terminal_dependency,
       labels(dep)[0] AS dependency_type
```

**Note:** The variable-length pattern `*1..3` is a key FalkorDB feature — this multi-hop traversal would require multiple queries or recursive code in a relational database.

---

### Q3: Find recent deployments to affected services

**Purpose:** Identify deployments that happened close to the incident start time.

**Parameters:** `$incident_id`, `$since` (ISO 8601 timestamp, typically incident time minus a configurable window)

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)<-[:DEPLOYED_TO]-(d:Deployment)
WHERE d.deployed_at > $since
RETURN s.name AS service,
       d.id AS deployment_id,
       d.version,
       d.deployed_at,
       d.deployed_by,
       d.status
ORDER BY d.deployed_at DESC
```

---

### Q4: Find changes included in suspect deployments

**Purpose:** Trace from incident through service to deployment to the actual code/config changes.

**Parameters:** `$incident_id`, `$since`

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)
      <-[:DEPLOYED_TO]-(dep:Deployment)<-[:INCLUDED_IN]-(c:Change)
WHERE dep.deployed_at > $since
RETURN s.name AS service,
       dep.version AS deployment_version,
       c.id AS change_id,
       c.type AS change_type,
       c.description,
       c.author,
       c.files_changed
ORDER BY dep.deployed_at DESC
```

**Why this matters:** This is a 4-hop traversal (Incident → Service → Deployment → Change) that would require multiple JOINs and manual assembly in SQL. In Cypher, it's one readable query.

---

### Q5: Find potential root causes from the dependency graph

**Purpose:** Check if any dependencies of affected services have known issues.

**Parameters:** `$incident_id`

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)-[:DEPENDS_ON]->(dep)
OPTIONAL MATCH (dep)<-[:AFFECTS]-(other:Incident)
WHERE other.status IN ['open', 'investigating'] AND other.id <> $incident_id
RETURN dep.name AS dependency,
       labels(dep)[0] AS type,
       collect(DISTINCT {id: other.id, title: other.title, severity: other.severity}) AS active_incidents
```

---

## Memory Agent Queries

### Q6: Find similar past incidents by shared affected services

**Purpose:** Core similarity search — find resolved incidents that affected the same services.

**Parameters:** `$incident_id`

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)<-[:AFFECTS]-(past:Incident)
WHERE past.id <> i.id AND past.status = 'resolved'
WITH past, collect(s.name) AS shared_services, count(s) AS overlap
RETURN past.id, past.title, past.severity, past.resolved_at,
       shared_services, overlap
ORDER BY overlap DESC, past.resolved_at DESC
LIMIT 10
```

---

### Q7: Find how a past incident was resolved

**Purpose:** Retrieve the resolution and root cause for a similar past incident.

**Parameters:** `$past_incident_id`

```cypher
MATCH (past:Incident {id: $past_incident_id})
OPTIONAL MATCH (past)-[:RESOLVED_BY]->(r:Resolution)
OPTIONAL MATCH (past)-[:CAUSED_BY]->(rc:RootCause)
OPTIONAL MATCH (e:Engineer)-[:RESOLVED]->(past)
RETURN past.title,
       r.action AS resolution_action,
       r.type AS resolution_type,
       r.duration_minutes,
       rc.category AS root_cause_category,
       rc.description AS root_cause_description,
       e.name AS resolved_by,
       e.email AS resolver_email
```

---

### Q8: Find the domain expert for a service

**Purpose:** Identify engineers who have successfully resolved incidents affecting a given service.

**Parameters:** `$service_name`

```cypher
MATCH (e:Engineer)-[:RESOLVED]->(i:Incident)-[:AFFECTS]->(s:Service {name: $service_name})
WHERE i.status = 'resolved'
RETURN e.name, e.email, e.team, e.expertise,
       count(i) AS incidents_resolved,
       max(i.resolved_at) AS last_resolved
ORDER BY incidents_resolved DESC
LIMIT 5
```

---

### Q9: Find recurring root cause patterns

**Purpose:** Identify which root cause categories appear most often and which services they affect.

```cypher
MATCH (rc:RootCause)<-[:CAUSED_BY]-(i:Incident)-[:AFFECTS]->(s:Service)
RETURN rc.category,
       count(DISTINCT i) AS incident_count,
       collect(DISTINCT s.name) AS affected_services,
       avg(rc.confidence) AS avg_confidence
ORDER BY incident_count DESC
```

---

### Q10: Find incidents similar by root cause category

**Purpose:** Beyond shared services, find incidents that share the same type of root cause.

**Parameters:** `$incident_id`

```cypher
MATCH (i:Incident {id: $incident_id})-[:CAUSED_BY]->(rc:RootCause)
MATCH (other:Incident)-[:CAUSED_BY]->(orc:RootCause)
WHERE other.id <> i.id AND orc.category = rc.category AND other.status = 'resolved'
OPTIONAL MATCH (other)-[:RESOLVED_BY]->(r:Resolution)
RETURN other.id, other.title, orc.category,
       r.action AS resolution_action, r.type AS resolution_type
ORDER BY other.resolved_at DESC
LIMIT 5
```

---

## Resolution Agent Queries

### Q11: Build the full explainability path

**Purpose:** Trace the complete graph path from incident to suspected root cause, used for the "Show me why" feature.

**Parameters:** `$incident_id`, `$since`

```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)
      -[:DEPENDS_ON*0..2]->(dep)<-[:DEPLOYED_TO]-(d:Deployment)
      <-[:INCLUDED_IN]-(c:Change)
WHERE d.deployed_at > $since
RETURN i.id AS incident,
       s.name AS affected_service,
       dep.name AS dependency,
       d.version AS deployment_version,
       d.deployed_at,
       c.description AS change_description,
       c.author AS change_author
```

---

### Q12: Create an Investigation node

**Purpose:** Record the investigation in the graph for future reference.

**Parameters:** `$investigation_id`, `$incident_id`, `$summary`

```cypher
CREATE (inv:Investigation {
  id: $investigation_id,
  started_at: datetime(),
  status: 'completed',
  summary: $summary
})
WITH inv
MATCH (i:Incident {id: $incident_id})
CREATE (inv)-[:INVESTIGATES]->(i)
RETURN inv.id
```

---

### Q13: Create a Decision node with graph path

**Purpose:** Record each recommendation and its supporting evidence.

**Parameters:** `$decision_id`, `$investigation_id`, `$recommendation`, `$confidence`, `$reasoning`, `$graph_path`

```cypher
MATCH (inv:Investigation {id: $investigation_id})
CREATE (d:Decision {
  id: $decision_id,
  recommendation: $recommendation,
  confidence: $confidence,
  reasoning: $reasoning,
  graph_path: $graph_path
})
CREATE (inv)-[:LED_TO]->(d)
RETURN d.id
```

---

### Q14: Link decision to referenced services

**Purpose:** Create REFERENCES edges from a decision to the services it discusses.

**Parameters:** `$decision_id`, `$service_ids` (list)

```cypher
MATCH (d:Decision {id: $decision_id})
UNWIND $service_ids AS sid
MATCH (s:Service {id: sid})
CREATE (d)-[:REFERENCES]->(s)
```

---

## Utility Queries

### Q15: Health check — verify graph connectivity

```cypher
MATCH (n)
RETURN labels(n)[0] AS node_type, count(n) AS count
ORDER BY count DESC
```

### Q16: Get full graph stats

```cypher
MATCH ()-[r]->()
RETURN type(r) AS relationship, count(r) AS count
ORDER BY count DESC
```

### Q17: Get incident with full context

**Parameters:** `$incident_id`

```cypher
MATCH (i:Incident {id: $incident_id})
OPTIONAL MATCH (i)-[:AFFECTS]->(s:Service)
OPTIONAL MATCH (i)-[:CAUSED_BY]->(rc:RootCause)
OPTIONAL MATCH (i)-[:RESOLVED_BY]->(r:Resolution)
OPTIONAL MATCH (inv:Investigation)-[:INVESTIGATES]->(i)
OPTIONAL MATCH (inv)-[:LED_TO]->(d:Decision)
RETURN i, collect(DISTINCT s) AS services,
       collect(DISTINCT rc) AS root_causes,
       collect(DISTINCT r) AS resolutions,
       collect(DISTINCT d) AS decisions
```

---

## Query Performance Notes

- All node lookups use indexed properties (id, name, email)
- Variable-length paths (`*1..3`) are bounded to prevent runaway traversals
- LIMIT clauses prevent large result sets
- OPTIONAL MATCH is used where data may not exist yet (e.g., new incidents without resolutions)
- Queries are designed to return structured data that agents can process without further graph calls
