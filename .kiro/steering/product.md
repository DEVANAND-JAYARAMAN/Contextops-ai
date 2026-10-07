# ContextOps — Product Context

ContextOps is a graph-powered AI incident response system built for the Graph Hacks 2026 hackathon (WeMakeDevs + FalkorDB).

## What it does

It investigates engineering incidents by reasoning over connected data stored in FalkorDB. Instead of treating incidents as isolated, it traverses a graph of services, dependencies, deployments, changes, engineers, and historical incidents to produce explainable recommendations.

## Tracks

- Primary: Agents That Act on Connected Data
- Secondary: Agent Memory and Coordination

## Core principle

The system answers questions that require traversing relationships:
- What services are affected by this incident?
- What dependencies could explain the failure?
- Have we seen a similar incident before?
- Who previously resolved a similar incident?
- What deployment or change may have caused this?
- What should the team investigate next?
- Why did the agent make this recommendation?

## The graph is central

FalkorDB must perform meaningful work. It is not a visualization layer or a secondary database. All relationship reasoning happens in Cypher, not in application code.

## Explainability

Every major recommendation must be explainable through a graph path. The UI provides a "Show me why" experience exposing the relevant path behind each recommendation.

Example path:
Payment API → DEPENDS_ON → Redis → AFFECTED_BY → Incident #21 → RESOLVED_BY → Engineer
