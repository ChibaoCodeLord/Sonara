import { Router } from 'express';
import authRoutes from './auth.routes.js';
import songRoutes from './song.routes.js';

const router = Router();

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Sonara Music API is running smoothly 🚀',
    timestamp: new Date().toISOString(),
  });
});

// Gắn các module route
router.use('/auth', authRoutes);
router.use('/songs', songRoutes);

export default router;
