// ContextOps — Synthetic Seed Data
// This creates a realistic graph of services, incidents, and relationships
// for demonstration and testing purposes.

// =============================================================================
// Projects
// =============================================================================

CREATE (:Project {id: 'proj-001', name: 'E-Commerce Platform', description: 'Core commerce product including checkout, payments, and order management', status: 'active'})
CREATE (:Project {id: 'proj-002', name: 'User Platform', description: 'Authentication, user profiles, and notifications', status: 'active'})
CREATE (:Project {id: 'proj-003', name: 'Data Platform', description: 'Analytics, search, and data processing pipelines', status: 'active'})

// =============================================================================
// Services
// =============================================================================

CREATE (:Service {id: 'svc-001', name: 'payment-api', tier: 'critical', language: 'Python', team: 'payments', repository: 'https://github.com/org/payment-api'})
CREATE (:Service {id: 'svc-002', name: 'checkout-service', tier: 'critical', language: 'Python', team: 'commerce', repository: 'https://github.com/org/checkout-service'})
CREATE (:Service {id: 'svc-003', name: 'order-service', tier: 'critical', language: 'Python', team: 'commerce', repository: 'https://github.com/org/order-service'})
CREATE (:Service {id: 'svc-004', name: 'user-service', tier: 'standard', language: 'Python', team: 'identity', repository: 'https://github.com/org/user-service'})
CREATE (:Service {id: 'svc-005', name: 'notification-service', tier: 'standard', language: 'Python', team: 'identity', repository: 'https://github.com/org/notification-service'})
CREATE (:Service {id: 'svc-006', name: 'search-service', tier: 'standard', language: 'Python', team: 'data', repository: 'https://github.com/org/search-service'})
CREATE (:Service {id: 'svc-007', name: 'analytics-service', tier: 'internal', language: 'Python', team: 'data', repository: 'https://github.com/org/analytics-service'})
CREATE (:Service {id: 'svc-008', name: 'api-gateway', tier: 'critical', language: 'Go', team: 'platform', repository: 'https://github.com/org/api-gateway'})
CREATE (:Service {id: 'svc-009', name: 'inventory-service', tier: 'critical', language: 'Python', team: 'commerce', repository: 'https://github.com/org/inventory-service'})

// =============================================================================
// Dependencies (infrastructure)
// =============================================================================

CREATE (:Dependency {id: 'dep-001', name: 'redis-primary', type: 'cache', version: '7.2', region: 'us-east-1'})
CREATE (:Dependency {id: 'dep-002', name: 'postgres-main', type: 'database', version: '15.4', region: 'us-east-1'})
CREATE (:Dependency {id: 'dep-003', name: 'rabbitmq-cluster', type: 'queue', version: '3.12', region: 'us-east-1'})
CREATE (:Dependency {id: 'dep-004', name: 'elasticsearch-cluster', type: 'database', version: '8.11', region: 'us-east-1'})
CREATE (:Dependency {id: 'dep-005', name: 'stripe-api', type: 'external_api', version: 'v1', region: 'external'})
CREATE (:Dependency {id: 'dep-006', name: 'sendgrid-api', type: 'external_api', version: 'v3', region: 'external'})
CREATE (:Dependency {id: 'dep-007', name: 's3-storage', type: 'storage', version: 'n/a', region: 'us-east-1'})
CREATE (:Dependency {id: 'dep-008', name: 'postgres-analytics', type: 'database', version: '15.4', region: 'us-east-1'})

// =============================================================================
// Engineers
// =============================================================================

CREATE (:Engineer {id: 'eng-001', name: 'Alice Chen', email: 'alice@company.com', team: 'payments', role: 'backend', expertise: 'payments,redis,python'})
CREATE (:Engineer {id: 'eng-002', name: 'Bob Martinez', email: 'bob@company.com', team: 'commerce', role: 'backend', expertise: 'orders,checkout,postgres'})
CREATE (:Engineer {id: 'eng-003', name: 'Carol Williams', email: 'carol@company.com', team: 'platform', role: 'sre', expertise: 'infrastructure,monitoring,kubernetes'})
CREATE (:Engineer {id: 'eng-004', name: 'David Kim', email: 'david@company.com', team: 'identity', role: 'backend', expertise: 'auth,user-management'})
CREATE (:Engineer {id: 'eng-005', name: 'Eva Singh', email: 'eva@company.com', team: 'data', role: 'backend', expertise: 'search,elasticsearch,analytics'})
CREATE (:Engineer {id: 'eng-006', name: 'Frank Lopez', email: 'frank@company.com', team: 'commerce', role: 'lead', expertise: 'architecture,commerce,scaling'})

// =============================================================================
// Service → Project relationships
// =============================================================================

MATCH (s:Service {id: 'svc-001'}), (p:Project {id: 'proj-001'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-002'}), (p:Project {id: 'proj-001'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-003'}), (p:Project {id: 'proj-001'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-009'}), (p:Project {id: 'proj-001'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-004'}), (p:Project {id: 'proj-002'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-005'}), (p:Project {id: 'proj-002'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-006'}), (p:Project {id: 'proj-003'}) CREATE (s)-[:PART_OF]->(p)
MATCH (s:Service {id: 'svc-007'}), (p:Project {id: 'proj-003'}) CREATE (s)-[:PART_OF]->(p)

// =============================================================================
// Service → Service dependencies
// =============================================================================

MATCH (s1:Service {id: 'svc-002'}), (s2:Service {id: 'svc-001'}) CREATE (s1)-[:DEPENDS_ON {type: 'sync'}]->(s2)
MATCH (s1:Service {id: 'svc-002'}), (s2:Service {id: 'svc-009'}) CREATE (s1)-[:DEPENDS_ON {type: 'sync'}]->(s2)
MATCH (s1:Service {id: 'svc-003'}), (s2:Service {id: 'svc-001'}) CREATE (s1)-[:DEPENDS_ON {type: 'async'}]->(s2)
MATCH (s1:Service {id: 'svc-003'}), (s2:Service {id: 'svc-009'}) CREATE (s1)-[:DEPENDS_ON {type: 'sync'}]->(s2)
MATCH (s1:Service {id: 'svc-005'}), (s2:Service {id: 'svc-004'}) CREATE (s1)-[:DEPENDS_ON {type: 'sync'}]->(s2)
MATCH (s1:Service {id: 'svc-008'}), (s2:Service {id: 'svc-001'}) CREATE (s1)-[:DEPENDS_ON {type: 'sync'}]->(s2)
MATCH (s1:Service {id: 'svc-008'}), (s2:Service {id: 'svc-004'}) CREATE (s1)-[:DEPENDS_ON {type: 'sync'}]->(s2)

// =============================================================================
// Service → Infrastructure dependencies
// =============================================================================

MATCH (s:Service {id: 'svc-001'}), (d:Dependency {id: 'dep-001'}) CREATE (s)-[:DEPENDS_ON {type: 'cache'}]->(d)
MATCH (s:Service {id: 'svc-001'}), (d:Dependency {id: 'dep-002'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-001'}), (d:Dependency {id: 'dep-005'}) CREATE (s)-[:DEPENDS_ON {type: 'external'}]->(d)
MATCH (s:Service {id: 'svc-002'}), (d:Dependency {id: 'dep-002'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-002'}), (d:Dependency {id: 'dep-001'}) CREATE (s)-[:DEPENDS_ON {type: 'cache'}]->(d)
MATCH (s:Service {id: 'svc-003'}), (d:Dependency {id: 'dep-002'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-003'}), (d:Dependency {id: 'dep-003'}) CREATE (s)-[:DEPENDS_ON {type: 'queue'}]->(d)
MATCH (s:Service {id: 'svc-004'}), (d:Dependency {id: 'dep-002'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-005'}), (d:Dependency {id: 'dep-003'}) CREATE (s)-[:DEPENDS_ON {type: 'queue'}]->(d)
MATCH (s:Service {id: 'svc-005'}), (d:Dependency {id: 'dep-006'}) CREATE (s)-[:DEPENDS_ON {type: 'external'}]->(d)
MATCH (s:Service {id: 'svc-006'}), (d:Dependency {id: 'dep-004'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-007'}), (d:Dependency {id: 'dep-008'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-007'}), (d:Dependency {id: 'dep-007'}) CREATE (s)-[:DEPENDS_ON {type: 'storage'}]->(d)
MATCH (s:Service {id: 'svc-009'}), (d:Dependency {id: 'dep-002'}) CREATE (s)-[:DEPENDS_ON {type: 'datastore'}]->(d)
MATCH (s:Service {id: 'svc-009'}), (d:Dependency {id: 'dep-001'}) CREATE (s)-[:DEPENDS_ON {type: 'cache'}]->(d)

// =============================================================================
// Engineer → Service ownership
// =============================================================================

MATCH (e:Engineer {id: 'eng-001'}), (s:Service {id: 'svc-001'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-002'}), (s:Service {id: 'svc-002'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-002'}), (s:Service {id: 'svc-003'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-003'}), (s:Service {id: 'svc-008'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-004'}), (s:Service {id: 'svc-004'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-004'}), (s:Service {id: 'svc-005'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-005'}), (s:Service {id: 'svc-006'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-005'}), (s:Service {id: 'svc-007'}) CREATE (e)-[:OWNS]->(s)
MATCH (e:Engineer {id: 'eng-006'}), (s:Service {id: 'svc-009'}) CREATE (e)-[:OWNS]->(s)

// =============================================================================
// Historical Incident #1: Redis connection pool exhaustion
// =============================================================================

CREATE (:Incident {id: 'INC-021', title: 'Redis connection timeouts affecting payments', description: 'Payment API experiencing intermittent timeouts when connecting to Redis. Error rate at 8%. Users seeing delayed payment confirmations.', severity: 'high', status: 'resolved', symptoms: 'Redis connection timeouts, increased payment latency, HTTP 504 errors', created_at: '2026-09-15T10:30:00Z', resolved_at: '2026-09-15T12:15:00Z'})

CREATE (:RootCause {id: 'rc-001', category: 'config_error', description: 'Redis connection pool max size was set too low (10) for the current traffic volume, causing pool exhaustion during peak hours', confidence: 0.92})

CREATE (:Resolution {id: 'res-001', action: 'Increased Redis connection pool max size from 10 to 50 and added connection pool monitoring alerts', type: 'config_change', duration_minutes: 105, effective: true})

CREATE (:Deployment {id: 'deploy-001', version: 'v2.12.1', environment: 'production', deployed_at: '2026-09-14T16:00:00Z', deployed_by: 'alice', status: 'success', commit_sha: 'a1b2c3d'})

CREATE (:Change {id: 'chg-001', type: 'config', description: 'Updated Redis connection pool settings for payment-api', files_changed: 2, created_at: '2026-09-14T14:30:00Z', author: 'alice', pr_url: 'https://github.com/org/payment-api/pull/234'})

// Link INC-021 relationships
MATCH (i:Incident {id: 'INC-021'}), (s:Service {id: 'svc-001'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-021'}), (s:Service {id: 'svc-002'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-021'}), (rc:RootCause {id: 'rc-001'}) CREATE (i)-[:CAUSED_BY]->(rc)
MATCH (i:Incident {id: 'INC-021'}), (r:Resolution {id: 'res-001'}) CREATE (i)-[:RESOLVED_BY]->(r)
MATCH (e:Engineer {id: 'eng-001'}), (i:Incident {id: 'INC-021'}) CREATE (e)-[:RESOLVED {duration_minutes: 105}]->(i)
MATCH (d:Deployment {id: 'deploy-001'}), (s:Service {id: 'svc-001'}) CREATE (d)-[:DEPLOYED_TO]->(s)
MATCH (c:Change {id: 'chg-001'}), (d:Deployment {id: 'deploy-001'}) CREATE (c)-[:INCLUDED_IN]->(d)
MATCH (e:Engineer {id: 'eng-001'}), (c:Change {id: 'chg-001'}) CREATE (e)-[:AUTHORED]->(c)
MATCH (e:Engineer {id: 'eng-001'}), (d:Deployment {id: 'deploy-001'}) CREATE (e)-[:PERFORMED]->(d)

// =============================================================================
// Historical Incident #2: Database connection leak
// =============================================================================

CREATE (:Incident {id: 'INC-028', title: 'Order service database connection leak', description: 'Order service gradually consuming all available database connections. Postgres max connections reached after 6 hours of uptime.', severity: 'critical', status: 'resolved', symptoms: 'Postgres connection limit reached, order creation failures, cascading failures to checkout', created_at: '2026-09-28T08:00:00Z', resolved_at: '2026-09-28T10:30:00Z'})

CREATE (:RootCause {id: 'rc-002', category: 'code_bug', description: 'Database connection not being returned to pool in error path of order creation handler. Connections leaked on every failed order attempt.', confidence: 0.95})

CREATE (:Resolution {id: 'res-002', action: 'Fixed connection leak in order creation error handler by ensuring connection release in finally block. Restarted order-service to clear leaked connections.', type: 'hotfix', duration_minutes: 150, effective: true})

CREATE (:Deployment {id: 'deploy-002', version: 'v3.5.0', environment: 'production', deployed_at: '2026-09-27T14:00:00Z', deployed_by: 'bob', status: 'success', commit_sha: 'e5f6g7h'})

CREATE (:Change {id: 'chg-002', type: 'code', description: 'Refactored order creation to use new async pattern', files_changed: 8, created_at: '2026-09-27T11:00:00Z', author: 'bob', pr_url: 'https://github.com/org/order-service/pull/567'})

// Link INC-028 relationships
MATCH (i:Incident {id: 'INC-028'}), (s:Service {id: 'svc-003'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-028'}), (s:Service {id: 'svc-002'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-028'}), (rc:RootCause {id: 'rc-002'}) CREATE (i)-[:CAUSED_BY]->(rc)
MATCH (i:Incident {id: 'INC-028'}), (r:Resolution {id: 'res-002'}) CREATE (i)-[:RESOLVED_BY]->(r)
MATCH (e:Engineer {id: 'eng-002'}), (i:Incident {id: 'INC-028'}) CREATE (e)-[:RESOLVED {duration_minutes: 150}]->(i)
MATCH (d:Deployment {id: 'deploy-002'}), (s:Service {id: 'svc-003'}) CREATE (d)-[:DEPLOYED_TO]->(s)
MATCH (c:Change {id: 'chg-002'}), (d:Deployment {id: 'deploy-002'}) CREATE (c)-[:INCLUDED_IN]->(d)
MATCH (e:Engineer {id: 'eng-002'}), (c:Change {id: 'chg-002'}) CREATE (e)-[:AUTHORED]->(c)
MATCH (e:Engineer {id: 'eng-002'}), (d:Deployment {id: 'deploy-002'}) CREATE (e)-[:PERFORMED]->(d)
MATCH (c:Change {id: 'chg-002'}), (rc:RootCause {id: 'rc-002'}) CREATE (c)-[:INTRODUCED_BY]->(rc)

// =============================================================================
// Historical Incident #3: Elasticsearch cluster degradation
// =============================================================================

CREATE (:Incident {id: 'INC-033', title: 'Search service returning stale results', description: 'Search results not reflecting recent product updates. Elasticsearch indexing lag exceeding 30 minutes.', severity: 'medium', status: 'resolved', symptoms: 'Stale search results, slow indexing, Elasticsearch cluster yellow status', created_at: '2026-10-02T15:00:00Z', resolved_at: '2026-10-02T17:45:00Z'})

CREATE (:RootCause {id: 'rc-003', category: 'capacity', description: 'Elasticsearch heap memory insufficient for index size after product catalog expansion. GC pauses causing indexing delays.', confidence: 0.88})

CREATE (:Resolution {id: 'res-003', action: 'Increased Elasticsearch JVM heap from 4GB to 8GB, added a third data node to the cluster, and optimized index mapping to reduce memory usage', type: 'scaling', duration_minutes: 165, effective: true})

CREATE (:Deployment {id: 'deploy-003', version: 'v1.8.0', environment: 'production', deployed_at: '2026-10-01T10:00:00Z', deployed_by: 'eva', status: 'success', commit_sha: 'i9j0k1l'})

CREATE (:Change {id: 'chg-003', type: 'code', description: 'Added new product attribute fields to search index', files_changed: 4, created_at: '2026-10-01T08:00:00Z', author: 'eva', pr_url: 'https://github.com/org/search-service/pull/189'})

// Link INC-033 relationships
MATCH (i:Incident {id: 'INC-033'}), (s:Service {id: 'svc-006'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-033'}), (rc:RootCause {id: 'rc-003'}) CREATE (i)-[:CAUSED_BY]->(rc)
MATCH (i:Incident {id: 'INC-033'}), (r:Resolution {id: 'res-003'}) CREATE (i)-[:RESOLVED_BY]->(r)
MATCH (e:Engineer {id: 'eng-005'}), (i:Incident {id: 'INC-033'}) CREATE (e)-[:RESOLVED {duration_minutes: 165}]->(i)
MATCH (d:Deployment {id: 'deploy-003'}), (s:Service {id: 'svc-006'}) CREATE (d)-[:DEPLOYED_TO]->(s)
MATCH (c:Change {id: 'chg-003'}), (d:Deployment {id: 'deploy-003'}) CREATE (c)-[:INCLUDED_IN]->(d)
MATCH (e:Engineer {id: 'eng-005'}), (c:Change {id: 'chg-003'}) CREATE (e)-[:AUTHORED]->(c)
MATCH (e:Engineer {id: 'eng-005'}), (d:Deployment {id: 'deploy-003'}) CREATE (e)-[:PERFORMED]->(d)
MATCH (c:Change {id: 'chg-003'}), (rc:RootCause {id: 'rc-003'}) CREATE (c)-[:INTRODUCED_BY]->(rc)

// =============================================================================
// Historical Incident #4: API gateway rate limiting failure
// =============================================================================

CREATE (:Incident {id: 'INC-035', title: 'API gateway not enforcing rate limits', description: 'Rate limiting on API gateway stopped working after config update. Traffic spike from scraper bots overwhelming payment-api and user-service.', severity: 'critical', status: 'resolved', symptoms: 'No rate limiting, traffic 5x normal, cascading latency increase across all services', created_at: '2026-10-04T22:00:00Z', resolved_at: '2026-10-05T00:30:00Z'})

CREATE (:RootCause {id: 'rc-004', category: 'config_error', description: 'Rate limiting configuration was accidentally overwritten during a config migration. The new config had rate limits set to 0 (unlimited).', confidence: 0.97})

CREATE (:Resolution {id: 'res-004', action: 'Restored correct rate limiting configuration from backup, added config validation checks to prevent zero-value rate limits, and blocked the offending scraper IPs', type: 'config_change', duration_minutes: 150, effective: true})

CREATE (:Deployment {id: 'deploy-004', version: 'v4.2.0', environment: 'production', deployed_at: '2026-10-04T18:00:00Z', deployed_by: 'carol', status: 'success', commit_sha: 'm2n3o4p'})

CREATE (:Change {id: 'chg-004', type: 'config', description: 'Migrated API gateway configuration to new format', files_changed: 12, created_at: '2026-10-04T16:00:00Z', author: 'carol', pr_url: 'https://github.com/org/api-gateway/pull/78'})

// Link INC-035 relationships
MATCH (i:Incident {id: 'INC-035'}), (s:Service {id: 'svc-008'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-035'}), (s:Service {id: 'svc-001'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-035'}), (s:Service {id: 'svc-004'}) CREATE (i)-[:AFFECTS]->(s)
MATCH (i:Incident {id: 'INC-035'}), (rc:RootCause {id: 'rc-004'}) CREATE (i)-[:CAUSED_BY]->(rc)
MATCH (i:Incident {id: 'INC-035'}), (r:Resolution {id: 'res-004'}) CREATE (i)-[:RESOLVED_BY]->(r)
MATCH (e:Engineer {id: 'eng-003'}), (i:Incident {id: 'INC-035'}) CREATE (e)-[:RESOLVED {duration_minutes: 150}]->(i)
MATCH (d:Deployment {id: 'deploy-004'}), (s:Service {id: 'svc-008'}) CREATE (d)-[:DEPLOYED_TO]->(s)
MATCH (c:Change {id: 'chg-004'}), (d:Deployment {id: 'deploy-004'}) CREATE (c)-[:INCLUDED_IN]->(d)
MATCH (e:Engineer {id: 'eng-003'}), (c:Change {id: 'chg-004'}) CREATE (e)-[:AUTHORED]->(c)
MATCH (e:Engineer {id: 'eng-003'}), (d:Deployment {id: 'deploy-004'}) CREATE (e)-[:PERFORMED]->(d)
MATCH (c:Change {id: 'chg-004'}), (rc:RootCause {id: 'rc-004'}) CREATE (c)-[:INTRODUCED_BY]->(rc)

// =============================================================================
// Similarity relationships between incidents
// =============================================================================

// INC-021 and INC-035 both affected payment-api
MATCH (i1:Incident {id: 'INC-021'}), (i2:Incident {id: 'INC-035'}) CREATE (i1)-[:SIMILAR_TO {score: 0.6, reason: 'Both affected payment-api service'}]->(i2)

// INC-021 and INC-028 both involved connection issues
MATCH (i1:Incident {id: 'INC-021'}), (i2:Incident {id: 'INC-028'}) CREATE (i1)-[:SIMILAR_TO {score: 0.7, reason: 'Both involved connection resource exhaustion'}]->(i2)

// =============================================================================
// A recent deployment that could cause a new incident (for demo scenario)
// =============================================================================

CREATE (:Deployment {id: 'deploy-005', version: 'v2.14.3', environment: 'production', deployed_at: '2026-10-06T13:00:00Z', deployed_by: 'alice', status: 'success', commit_sha: 'q5r6s7t'})

CREATE (:Change {id: 'chg-005', type: 'config', description: 'Updated Redis connection timeout from 5s to 500ms for faster failover', files_changed: 1, created_at: '2026-10-06T11:00:00Z', author: 'alice', pr_url: 'https://github.com/org/payment-api/pull/267'})

CREATE (:Change {id: 'chg-006', type: 'code', description: 'Added retry logic for failed payment transactions', files_changed: 3, created_at: '2026-10-06T10:00:00Z', author: 'alice', pr_url: 'https://github.com/org/payment-api/pull/266'})

MATCH (d:Deployment {id: 'deploy-005'}), (s:Service {id: 'svc-001'}) CREATE (d)-[:DEPLOYED_TO]->(s)
MATCH (c:Change {id: 'chg-005'}), (d:Deployment {id: 'deploy-005'}) CREATE (c)-[:INCLUDED_IN]->(d)
MATCH (c:Change {id: 'chg-006'}), (d:Deployment {id: 'deploy-005'}) CREATE (c)-[:INCLUDED_IN]->(d)
MATCH (e:Engineer {id: 'eng-001'}), (c:Change {id: 'chg-005'}) CREATE (e)-[:AUTHORED]->(c)
MATCH (e:Engineer {id: 'eng-001'}), (c:Change {id: 'chg-006'}) CREATE (e)-[:AUTHORED]->(c)
MATCH (e:Engineer {id: 'eng-001'}), (d:Deployment {id: 'deploy-005'}) CREATE (e)-[:PERFORMED]->(d)
