# ContextOps — Graph Data Model

## Overview

The ContextOps knowledge graph represents the connected relationships between engineering incidents, services, infrastructure, people, and historical context. FalkorDB stores this graph and agents query it using Cypher.

The graph is the central data store. All meaningful traversal happens in Cypher, not in application code.

## Node Types

### Incident
Represents a production incident or alert.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique incident identifier (e.g., `INC-001`) |
| title | string | Brief incident title |
| description | string | Detailed incident description |
| severity | string | `critical`, `high`, `medium`, `low` |
| status | string | `open`, `investigating`, `resolved`, `closed` |
| created_at | string | ISO 8601 timestamp |
| resolved_at | string | ISO 8601 timestamp (nullable) |
| symptoms | string | Observed symptoms |

### Service
Represents a software service or microservice.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique service identifier |
| name | string | Service name (e.g., `payment-api`) |
| tier | string | `critical`, `standard`, `internal` |
| language | string | Primary programming language |
| team | string | Owning team |
| repository | string | Git repository URL |

### Dependency
Represents an infrastructure dependency (database, cache, queue, etc.).

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique dependency identifier |
| name | string | Dependency name (e.g., `redis-primary`) |
| type | string | `database`, `cache`, `queue`, `external_api`, `storage` |
| version | string | Current version |
| region | string | Deployment region |

### Deployment
Represents a deployment event.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique deployment identifier |
| version | string | Deployed version/tag |
| environment | string | `production`, `staging`, `development` |
| deployed_at | string | ISO 8601 timestamp |
| deployed_by | string | Engineer who deployed |
| status | string | `success`, `failed`, `rolled_back` |
| commit_sha | string | Git commit SHA |

### Change
Represents a code or configuration change.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique change identifier |
| type | string | `code`, `config`, `infrastructure`, `database` |
| description | string | What was changed |
| files_changed | int | Number of files changed |
| created_at | string | ISO 8601 timestamp |
| author | string | Change author |
| pr_url | string | Pull request URL |

### Engineer
Represents a team member.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique engineer identifier |
| name | string | Full name |
| email | string | Email address |
| team | string | Team name |
| role | string | `sre`, `backend`, `frontend`, `devops`, `lead` |
| expertise | string | Comma-separated areas of expertise |

### Project
Represents a project or product area.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique project identifier |
| name | string | Project name |
| description | string | Project description |
| status | string | `active`, `maintenance`, `deprecated` |

### RootCause
Represents a diagnosed root cause.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique root cause identifier |
| category | string | `code_bug`, `config_error`, `infra_failure`, `dependency_failure`, `capacity`, `deployment` |
| description | string | Detailed description |
| confidence | float | Confidence score (0.0 – 1.0) |

### Resolution
Represents a resolution action taken.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique resolution identifier |
| action | string | What was done to resolve |
| type | string | `rollback`, `hotfix`, `config_change`, `restart`, `scaling`, `manual` |
| duration_minutes | int | Time to resolution |
| effective | boolean | Whether the resolution worked |

### Investigation
Represents an AI-driven investigation session.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique investigation identifier |
| started_at | string | ISO 8601 timestamp |
| completed_at | string | ISO 8601 timestamp (nullable) |
| status | string | `in_progress`, `completed`, `failed` |
| summary | string | Investigation summary |

### Decision
Represents a recommendation or decision made during investigation.

| Property | Type | Description |
|----------|------|-------------|
| id | string | Unique decision identifier |
| recommendation | string | What the agent recommends |
| confidence | float | Confidence score (0.0 – 1.0) |
| reasoning | string | Why this recommendation was made |
| graph_path | string | JSON representation of the graph path that supports this decision |

## Relationship Types

### Core Incident Relationships

```cypher
// An incident affects one or more services
(i:Incident)-[:AFFECTS]->(s:Service)

// An incident is caused by a root cause
(i:Incident)-[:CAUSED_BY]->(rc:RootCause)

// An incident is resolved by a resolution
(i:Incident)-[:RESOLVED_BY]->(r:Resolution)

// An incident is similar to another incident
(i1:Incident)-[:SIMILAR_TO {score: 0.85}]->(i2:Incident)
```

### Service Relationships

```cypher
// A service depends on another service
(s1:Service)-[:DEPENDS_ON {type: "sync"}]->(s2:Service)

// A service depends on an infrastructure dependency
(s:Service)-[:DEPENDS_ON {type: "datastore"}]->(d:Dependency)

// A service is part of a project
(s:Service)-[:PART_OF]->(p:Project)
```

### Deployment and Change Relationships

```cypher
// A deployment targets a service
(dep:Deployment)-[:DEPLOYED_TO]->(s:Service)

// A change was included in a deployment
(c:Change)-[:INCLUDED_IN]->(dep:Deployment)

// A change introduced a root cause
(c:Change)-[:INTRODUCED_BY]->(rc:RootCause)
// Note: direction is (Change)-[:INTRODUCED_BY]->(RootCause) meaning
// "this change introduced this root cause"
```

### People Relationships

```cypher
// An engineer resolved an incident
(e:Engineer)-[:RESOLVED {duration_minutes: 45}]->(i:Incident)

// An engineer made a change
(e:Engineer)-[:AUTHORED]->(c:Change)

// An engineer performed a deployment
(e:Engineer)-[:PERFORMED]->(dep:Deployment)

// An engineer owns a service
(e:Engineer)-[:OWNS]->(s:Service)
```

### Investigation Relationships

```cypher
// An investigation is for an incident
(inv:Investigation)-[:INVESTIGATES]->(i:Incident)

// An investigation produced a decision
(inv:Investigation)-[:LED_TO]->(d:Decision)

// A decision references services in its reasoning
(d:Decision)-[:REFERENCES]->(s:Service)
```

## Graph Schema Diagram

```
                    ┌───────────┐
                    │  Project   │
                    └─────┬─────┘
                          │ PART_OF
                          │
┌──────────┐  AFFECTS  ┌──┴──────┐  DEPENDS_ON  ┌────────────┐
│ Incident  ├─────────►│ Service  ├─────────────►│ Dependency  │
└──┬──┬──┬──┘          └──┬──┬────┘              └─────────────┘
   │  │  │                │  │
   │  │  │ SIMILAR_TO     │  │ DEPLOYED_TO
   │  │  └───►(Incident)  │  │
   │  │                   │  ▼
   │  │ CAUSED_BY    OWNS │ ┌──────────┐ INCLUDED_IN ┌────────┐
   │  └──────►(RootCause)◄┘ │Deployment│◄────────────│ Change  │
   │              ▲          └────┬─────┘             └───┬────┘
   │              │               │                       │
   │        INTRODUCED_BY    PERFORMED                AUTHORED
   │              │               │                       │
   │         ┌────┴───┐     ┌────┴──────┐           ┌────┴─────┐
   │         │ Change  │     │ Engineer   │           │ Engineer  │
   │         └─────────┘     └───────────┘           └──────────┘
   │
   │ RESOLVED_BY
   ▼
┌──────────┐     INVESTIGATES     ┌───────────────┐
│Resolution │     ┌───────────────│ Investigation  │
└──────────┘     │                └──────┬────────┘
                 ▼                       │ LED_TO
            (Incident)                   ▼
                                  ┌──────────┐
                                  │ Decision  │──REFERENCES──►(Service)
                                  └──────────┘
```

## Key Traversal Patterns

These are the core graph traversal patterns that agents will use. Each pattern maps to a question the system should answer.

### 1. Find all services affected by an incident
```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)
RETURN s.name, s.tier
```

### 2. Find transitive dependencies of affected services
```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)-[:DEPENDS_ON*1..3]->(dep)
RETURN s.name AS service, collect(dep.name) AS dependencies
```

### 3. Find recent deployments to affected services
```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)<-[:DEPLOYED_TO]-(d:Deployment)
WHERE d.deployed_at > datetime($since)
RETURN s.name, d.version, d.deployed_at, d.deployed_by
ORDER BY d.deployed_at DESC
```

### 4. Find changes that could have caused the incident
```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)<-[:DEPLOYED_TO]-(dep:Deployment)<-[:INCLUDED_IN]-(c:Change)
WHERE dep.deployed_at > datetime($since)
RETURN c.description, c.author, c.type, dep.version
```

### 5. Find similar past incidents
```cypher
MATCH (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)<-[:AFFECTS]-(past:Incident)
WHERE past.id <> i.id AND past.status = 'resolved'
RETURN past.id, past.title, past.severity,
       collect(s.name) AS shared_services
ORDER BY past.resolved_at DESC
```

### 6. Find how a similar incident was resolved
```cypher
MATCH (past:Incident {id: $past_incident_id})-[:RESOLVED_BY]->(r:Resolution)
MATCH (past)-[:CAUSED_BY]->(rc:RootCause)
OPTIONAL MATCH (e:Engineer)-[:RESOLVED]->(past)
RETURN r.action, r.type, r.duration_minutes,
       rc.category, rc.description,
       e.name AS resolver
```

### 7. Find the expert for a given service
```cypher
MATCH (e:Engineer)-[:RESOLVED]->(i:Incident)-[:AFFECTS]->(s:Service {name: $service_name})
RETURN e.name, e.email, count(i) AS incidents_resolved
ORDER BY incidents_resolved DESC
LIMIT 5
```

### 8. Build the explainability path
```cypher
MATCH path = (i:Incident {id: $incident_id})-[:AFFECTS]->(s:Service)-[:DEPENDS_ON]->(dep)
              -[:DEPENDS_ON*0..2]->(root_dep)<-[:DEPLOYED_TO]-(d:Deployment)<-[:INCLUDED_IN]-(c:Change)
WHERE d.deployed_at > datetime($since)
RETURN path
```

### 9. Find patterns across incidents
```cypher
MATCH (rc:RootCause)<-[:CAUSED_BY]-(i:Incident)-[:AFFECTS]->(s:Service)
RETURN rc.category, count(DISTINCT i) AS incident_count,
       collect(DISTINCT s.name) AS affected_services
ORDER BY incident_count DESC
```

### 10. Get investigation timeline
```cypher
MATCH (inv:Investigation)-[:INVESTIGATES]->(i:Incident {id: $incident_id})
MATCH (inv)-[:LED_TO]->(d:Decision)
RETURN inv.started_at, inv.completed_at, inv.summary,
       collect({recommendation: d.recommendation, confidence: d.confidence}) AS decisions
```
