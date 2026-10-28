import { Request, Response } from 'express';

export const syncSalesBatch = (req: Request, res: Response) => {
  const { sales, deviceId } = req.body;

  if (!Array.isArray(sales)) {
    return res.status(400).json({
      success: false,
      message: 'Payload must contain a sales array.',
    });
  }

  // Simulated idempotent batch ingest
  return res.json({
    success: true,
    message: `Batch sync accepted for ${sales.length} transactions.`,
    syncedAt: new Date().toISOString(),
    deviceId: deviceId || 'anonymous-pos',
    receivedCount: sales.length,
  });
};

export const exportDailyBackup = (req: Request, res: Response) => {
  const { date, snapshot } = req.body;

  return res.json({
    success: true,
    message: 'Daily backup snapshot archived successfully.',
    backupDate: date || new Date().toISOString().split('T')[0],
    snapshotSize: snapshot ? JSON.stringify(snapshot).length : 0,
    timestamp: new Date().toISOString(),
  });
};
