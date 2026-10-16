import fs from 'fs';
import path from 'path';
import { Song } from '../models/song.model.js';
import { User } from '../models/user.model.js';
import { ApiError } from '../utils/apiError.js';

export const getAllSongs = async ({ query = '', genre = '', page = 1, limit = 20, sort = '-createdAt' }) => {
  const filter = {};

  if (query) {
    filter.$or = [
      { title: { $regex: query, $options: 'i' } },
      { artist: { $regex: query, $options: 'i' } },
    ];
  }

  if (genre) {
    filter.genre = genre;
  }

  const skip = (Number(page) - 1) * Number(limit);

  const [songs, total] = await Promise.all([
    Song.find(filter).sort(sort).skip(skip).limit(Number(limit)),
    Song.countDocuments(filter),
  ]);

  return {
    songs,
    pagination: {
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      limit: Number(limit),
    },
  };
};

export const getSongById = async (id) => {
  const song = await Song.findById(id);
  if (!song) {
    throw new ApiError(404, 'Không tìm thấy bài hát yêu cầu!');
  }

  // Tự động tăng lượt nghe
  song.playsCount += 1;
  await song.save();

  return song;
};

export const createSong = async (songData) => {
  return await Song.create(songData);
};

export const toggleLike = async (userId, songId) => {
  const [song, user] = await Promise.all([
    Song.findById(songId),
    User.findById(userId),
  ]);

  if (!song) throw new ApiError(404, 'Không tìm thấy bài hát!');
  if (!user) throw new ApiError(404, 'Không tìm thấy người dùng!');

  const isLiked = user.favoriteSongs.includes(songId);

  if (isLiked) {
    user.favoriteSongs.pull(songId);
    song.likesCount = Math.max(0, song.likesCount - 1);
  } else {
    user.favoriteSongs.push(songId);
    song.likesCount += 1;
  }

  await Promise.all([user.save(), song.save()]);

  return {
    liked: !isLiked,
    likesCount: song.likesCount,
  };
};

export const streamSongAudio = (filePath, range, res) => {
  if (!fs.existsSync(filePath)) {
    throw new ApiError(404, 'Không tìm thấy file âm thanh trên hệ thống lưu trữ');
  }

  const stat = fs.statSync(filePath);
  const fileSize = stat.size;

  // Xử lý HTTP Range header (Partial Content 206) để phát nhạc streaming mượt mà
  if (range) {
    const parts = range.replace(/bytes=/, '').split('-');
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

    if (start >= fileSize) {
      res.status(416).send('Requested range not satisfiable\n' + start + ' >= ' + fileSize);
      return;
    }

    const chunksize = end - start + 1;
    const file = fs.createReadStream(filePath, { start, end });
    const head = {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': 'audio/mpeg',
    };

    res.writeHead(206, head);
    file.pipe(res);
  } else {
    const head = {
      'Content-Length': fileSize,
      'Content-Type': 'audio/mpeg',
    };
    res.writeHead(200, head);
    fs.createReadStream(filePath).pipe(res);
  }
};
