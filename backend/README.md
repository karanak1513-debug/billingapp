# Snacks O'Clock — Cloud Backend (Optional Sync & Backup Service)

## Architectural Role

Snacks O'Clock is engineered as an **offline-first Android POS application**. The primary working database is a local SQLite database running natively on the device with zero cloud latency and no dependency on internet availability.

This `backend/` directory houses the modular Node.js/TypeScript backend intended for:
1. Daily end-of-shift cloud backups.
2. Multi-till sales aggregation (e.g. if the food stall expands to multiple terminals).
3. Remote owner reporting dashboard.

## Planned API Endpoints

- `POST /api/v1/sync/sales`: Ingest encrypted batch of completed local sales tickets.
- `GET /api/v1/sync/products`: Fetch centrally managed menu pricing updates.
- `POST /api/v1/backup/export`: Store daily SQLite snapshot / CSV audit dump in secure storage.
- `GET /api/v1/health`: Cloud health check.

## Setup & Running

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```
