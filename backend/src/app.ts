import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { getMenu, getCombos } from './controllers/menu.controller';
import { syncSalesBatch, exportDailyBackup } from './controllers/sync.controller';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// Security & Parsing middlewares
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
}));
app.use(express.json({ limit: '10mb' }));

// Health Check
app.get('/api/v1/health', (_req, res) => {
  res.json({
    status: 'healthy',
    service: "Snacks O'Clock × Chill O'Clock Cloud Service",
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Menu Endpoints
app.get('/api/v1/menu', getMenu);
app.get('/api/v1/combos', getCombos);

// POS Sync & Backup Endpoints
app.post('/api/v1/sync/sales', syncSalesBatch);
app.post('/api/v1/backup/export', exportDailyBackup);

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`[Snacks O'Clock Backend] Server running on http://localhost:${PORT}`);
  });
}

export default app;
