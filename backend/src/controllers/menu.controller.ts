import { Request, Response } from 'express';
import { SHARED_MENU } from '../data/menu';

export const getMenu = (req: Request, res: Response) => {
  const category = req.query.category as string | undefined;

  if (category && category !== 'all') {
    const filtered = SHARED_MENU.filter((item) => item.category === category);
    return res.json({
      success: true,
      count: filtered.length,
      category,
      data: filtered,
    });
  }

  return res.json({
    success: true,
    count: SHARED_MENU.length,
    data: SHARED_MENU,
  });
};

export const getCombos = (_req: Request, res: Response) => {
  const combos = SHARED_MENU.filter((item) => item.category === 'combos');
  return res.json({
    success: true,
    count: combos.length,
    data: combos,
  });
};
