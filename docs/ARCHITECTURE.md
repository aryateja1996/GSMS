# GSMA Architecture

## Layers

```text
Presentation (GetX Controllers, Pages, Widgets)
        ↓
Domain (Entities, Repository interfaces, Use cases)
        ↓
Data (Local/Remote datasources, Models, Repository impl)
        ↓
Isar (offline)  |  Firebase (cloud)
        ↓
SyncManager (queue, connectivity, conflict handling — Phase 10)
```

## Principles

- UI never calls Firestore directly.
- Controllers delegate to use cases.
- Repositories merge local and remote sources; offline writes go to Isar first with `syncStatus = pending` and a `SyncQueueItem`.
- Financial records are append-only; corrections use reversal/adjustment entries.

## Feature folders

Each feature under `lib/features/<name>/` follows `data/`, `domain/`, `presentation/`.

## Multi-store readiness

Documents include `storeId`. User profile (Phase 2) selects the active store; queries filter by `storeId`.
