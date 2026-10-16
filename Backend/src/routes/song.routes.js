import { Router } from 'express';
import {
  getSongs,
  getSongById,
  createSong,
  toggleLike,
  streamSong,
} from '../controllers/song.controller.js';
import { protect, restrictTo } from '../middlewares/auth.middleware.js';
import { upload } from '../middlewares/upload.middleware.js';

const router = Router();

// Lấy danh sách bài hát (hỗ trợ phân trang, tìm kiếm)
router.get('/', getSongs);

// Lấy chi tiết bài hát theo ID
router.get('/:id', getSongById);

// Phát trực tuyến bài hát (HTTP 206 Partial Content Stream)
router.get('/:id/stream', streamSong);

// Thả tim / Bỏ thích bài hát (yêu cầu đăng nhập)
router.post('/:id/like', protect, toggleLike);

// Thêm bài hát mới (kèm file audio và ảnh bìa)
router.post(
  '/',
  protect,
  upload.fields([
    { name: 'audio', maxCount: 1 },
    { name: 'cover', maxCount: 1 },
  ]),
  createSong
);

export default router;
