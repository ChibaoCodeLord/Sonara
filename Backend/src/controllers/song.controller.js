import path from 'path';
import * as songService from '../services/song.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/apiError.js';

export const getSongs = asyncHandler(async (req, res) => {
  const result = await songService.getAllSongs(req.query);
  res
    .status(200)
    .json(new ApiResponse(200, result, 'Lấy danh sách bài hát thành công!'));
});

export const getSongById = asyncHandler(async (req, res) => {
  const song = await songService.getSongById(req.params.id);
  res
    .status(200)
    .json(new ApiResponse(200, song, 'Lấy thông tin bài hát thành công!'));
});

export const createSong = asyncHandler(async (req, res) => {
  const songData = { ...req.body };

  // Nếu có file upload từ multer
  if (req.files) {
    if (req.files.audio && req.files.audio[0]) {
      songData.audioUrl = `/uploads/${req.files.audio[0].filename}`;
    }
    if (req.files.cover && req.files.cover[0]) {
      songData.coverUrl = `/uploads/${req.files.cover[0].filename}`;
    }
  }

  if (!songData.audioUrl) {
    throw new ApiError(400, 'Vui lòng cung cấp file hoặc đường dẫn âm thanh (audioUrl)!');
  }

  const newSong = await songService.createSong(songData);
  res
    .status(201)
    .json(new ApiResponse(201, newSong, 'Thêm bài hát mới thành công!'));
});

export const toggleLike = asyncHandler(async (req, res) => {
  const result = await songService.toggleLike(req.user._id, req.params.id);
  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        result,
        result.liked ? 'Đã thêm vào danh sách yêu thích' : 'Đã bỏ yêu thích'
      )
    );
});

export const streamSong = asyncHandler(async (req, res) => {
  const song = await songService.getSongById(req.params.id);

  // Nếu audioUrl bắt đầu bằng /uploads/ thì stream file nội bộ
  if (song.audioUrl.startsWith('/uploads/')) {
    const filename = song.audioUrl.replace('/uploads/', '');
    const filePath = path.resolve('uploads', filename);
    songService.streamSongAudio(filePath, req.headers.range, res);
  } else {
    // Nếu là link online (CDN/Cloudinary), redirect tới link đó
    res.redirect(song.audioUrl);
  }
});
