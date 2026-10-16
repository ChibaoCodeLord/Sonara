import '../models/playlist_detail_model.dart';

class PlaylistMockService {
  PlaylistDetailModel getPlaylistDetail(String id) {
    return const PlaylistDetailModel(
      id: 'ai_curated_01',
      title: 'Sonara AI Mix #01',
      engineTag: 'SONARA AI TUYỂN CHỌN',
      description:
          'Tạo từ 5 bài hát bạn tìm bằng giai điệu tuần này • 2 giờ 15 phút • Cập nhật hôm nay',
      coverUrl: 'assets/images/sonara_ai_mix.jpg',
      emotionAnalysis: 'Trầm lắng & Hoài niệm',
      tracks: [
        PlaylistTrackItemModel(
          id: 'track_1',
          index: 1,
          title: 'Bầu Trời Mới',
          artist: 'Da LAB ft. Miu Lê',
          durationText: '3:45',
          qualityBadge: 'LOSSLESS',
          matchPercentage: '98% Khớp gu',
          coverUrl: 'assets/images/bau_troi_moi.jpg',
        ),
        PlaylistTrackItemModel(
          id: 'track_2',
          index: 2,
          title: 'Dưới Ánh Hoàng Hôn',
          artist: 'Vũ ft. Min',
          durationText: '4:12',
          qualityBadge: 'LOSSLESS',
          matchPercentage: '96% Khớp gu',
          coverUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAXR3wG5fvWAkP2tlVR45c8EcltpUH11QgyUV-is2a-4IMWyiWAet2QMQMvBWLoEcxhUCUQ1wOzxUjLQfT1mUrqoFZi9BE8KNM8dQsqP1ZPnXCtqwLE9xYyl-4G1q8WcOu0SQCiaW_MYrDAE-4hVZTS7JkmaYYI7K8isbkDLbT-fEDHAeq_JLDwN5JgjXOs3F28yDX2rFdfhcXnnVz7-AnZk0GejbUKUfDpLAZoLLtJstosqKl-V5j0WQ',
        ),
        PlaylistTrackItemModel(
          id: 'track_3',
          index: 3,
          title: 'Có Đôi Lần',
          artist: 'Đức Trí, Hoàng Dũng',
          durationText: '4:50',
          qualityBadge: 'HI-RES',
          matchPercentage: '95% Khớp gu',
          coverUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAW13Y_5sANu1OMKOIV7EaT6Iw8e7tN_hIKtUSr7ZbaW6RM60onii_OjuR1Ohj2kTJeMQVQcH82mDFTbc1zZv8jdKW53FteRjtG9HS9D4d2Bz0mrAysOxLu5sLOv8HP626W7Ag_GTx-YSrGLnGlarU-GFYwQA3CwnvPzz8EMz00U772TbxyZCVIXbx4wlCawZnaoPZvXhCTjdQWz6jMKV7awBoKoXWEMUj4cTYnaac_tamuq9oTS7WXJQ',
        ),
        PlaylistTrackItemModel(
          id: 'track_4',
          index: 4,
          title: 'Ngày Đầu Tiên',
          artist: 'Đức Phúc',
          durationText: '3:30',
          qualityBadge: 'LOSSLESS',
          matchPercentage: '92% Khớp gu',
          coverUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBpfpEp7cd-5FSgK06vY48z-m3oEKqveGSixoF8AMoMjlbRG__RRzu3b-3fABc3A8uW3Rw9KunxKiSanXzwD8vUEbk0HyyjKQ5TZMu0-xvXFOoZXOp231fzB0UBqjfLQ_K10SVl6jJ-dLtajqVi0Np3YdUdEA6q79DKHGHFEzlHJF2RYjUipLJlqt91UvyOVsEYe5n1mC9q_TsGVpimZCY0ldcX4dNfnHlD_HzS7OkzOv8DuLXkUfZfUQ',
        ),
        PlaylistTrackItemModel(
          id: 'track_5',
          index: 5,
          title: 'Mưa Trên Tầng Thượng',
          artist: 'The Cassette',
          durationText: '4:05',
          qualityBadge: 'HI-RES',
          matchPercentage: '90% Khớp gu',
          coverUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBFlS1hYf1CrjVGn-NChPgDPG2Vb9ZTdbM6yQRuDr2KRWmUtGVC4QcyKlngzZ0dj0YJ3CFej2ioLvGx3aVgxaCovLPnTmpGZRUPXoGrrP-1beFev4c4R9gR4UN5rcom3dZPzsWhFFYRxP8MriO9mRIDbuyYGLhKd3-p5LIqOZUn50NnP63vzAODGGmCx_cPE6kwB3nNvTEKTQW0HkrAI0SAGcMlgnr-ZOtfJO_H4W7vPpQ_BmPNx-F1jw',
        ),
      ],
    );
  }
}
