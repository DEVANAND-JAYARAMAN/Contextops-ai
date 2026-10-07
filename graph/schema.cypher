// ContextOps — FalkorDB Graph Schema
// Run this file to create indexes and constraints for the contextops graph.

// =============================================================================
// Indexes — for fast property lookups
// =============================================================================

// Primary key indexes (every node type has an indexed id)
CREATE INDEX FOR (i:Incident) ON (i.id)
CREATE INDEX FOR (s:Service) ON (s.id)
CREATE INDEX FOR (d:Dependency) ON (d.id)
CREATE INDEX FOR (dep:Deployment) ON (dep.id)
CREATE INDEX FOR (c:Change) ON (c.id)
CREATE INDEX FOR (e:Engineer) ON (e.id)
CREATE INDEX FOR (p:Project) ON (p.id)
CREATE INDEX FOR (rc:RootCause) ON (rc.id)
CREATE INDEX FOR (r:Resolution) ON (r.id)
CREATE INDEX FOR (inv:Investigation) ON (inv.id)
CREATE INDEX FOR (d:Decision) ON (d.id)

// Secondary indexes for common query patterns
CREATE INDEX FOR (s:Service) ON (s.name)
CREATE INDEX FOR (e:Engineer) ON (e.email)
CREATE INDEX FOR (i:Incident) ON (i.status)
CREATE INDEX FOR (i:Incident) ON (i.severity)
