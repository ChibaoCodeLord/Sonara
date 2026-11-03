import { Router } from 'express';
import * as trackController from '../controllers/track.controller.js';

const router = Router();

// GET /api/v1/tracks - Lấy danh sách bài hát (phân trang, search, lọc genre)
router.get('/', trackController.getTracks);

// GET /api/v1/tracks/:id - Lấy chi tiết bài hát, nghệ sĩ, album & synced_lyrics
router.get('/:id', trackController.getTrackById);

// GET /api/v1/tracks/:id/stream - Phát nhạc trực tuyến (HTTP Range 206)
router.get('/:id/stream', trackController.streamTrack);

export default router;
