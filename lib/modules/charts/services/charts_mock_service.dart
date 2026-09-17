import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../models/chart_item_model.dart';
import '../models/mood_genre_model.dart';
import '../models/spotlight_radar_model.dart';

class ChartsMockService {
  List<ChartItemModel> getVnChartItems() {
    return const [
      ChartItemModel(
        rank: '01',
        title: 'Từng Là Của Nhau',
        artist: 'Bảo Anh, Táo',
        rankDelta: 2,
        playsText: '1.8M lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDXuUKynlBv5fMCMdcUKcsOtgM61v6smbs5e7UZg076eFAYS-kU23OXl1UCu9_xzWd_Kf6K5nu-HhYOboApfXlBKUKCQIz0M3aBMCxMHu4VCYngfcxkEnoygkM1hZVNunPDveoWl-Rm4cx_Z9vynOi9gqgZdLqk8iOFxx1mABEHwU6Xn-_Fpa8iBh06JYqm1uKfkzOdoNh27Z3RF8YRsbB_H-GAPXscAZ1Z1YTnHIw5yermsqV3o--MYA',
        isLeader: true,
        badgeLabel: 'No.1',
      ),
      ChartItemModel(
        rank: '02',
        title: 'Lạc Giữa Màn Đêm',
        artist: 'Sơn Tùng M-TP',
        rankDelta: 0,
        playsText: '1.4M lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAyQLW2j4_WBQJkMteyFnv9NdOJP-BkWMmohAVBqH1ls6AwoWXf_D73xcvagyeY2tcSGewSh15biyIpTynTiao902n08RIpfCCbuvyk7sB2fIVO2V-mYm-gvlxy-B-QKsp2jNj55X0EN0QOQ9Row3TyVhW0mEzjpG_xcjKGoDGfAk9AgtcUX8m3vaNMN38q4mFaSFEGVnGjtgw748bhiR5O3Ztz-olapJ7t7cjpFShqZ-QcsQW5orgoow',
      ),
      ChartItemModel(
        rank: '03',
        title: 'Bầu Trời Mới',
        artist: 'Da LAB ft. Miu Lê',
        rankDelta: 5,
        playsText: '1.2M lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBFvMFZOb-ugTj17pmjBgB0YChlAJlF6D6I-dijNr9_6xBBGQrZdAvPKT8oMbhyxGvwWb8u1oTrwg64Ok0gmgHR82PIukh9LOvNjASJoDjRvfQ-43D86YRgifaEYvDpdZvCTFfiIqCZMrTm2REkx7QAbVGeg5QvfoULykEYdG-yWZVbw7G60Lyi6tz7tCGPsL49xL7Ps2QCHQRa0IshBiOzr4WjyBx2aFNuhtZTHPgplcxaBnlu16pJvg',
        isHumHot: true,
        badgeLabel: 'Hum Hot',
      ),
      ChartItemModel(
        rank: '04',
        title: 'Cơn Mưa Mùa Hạ',
        artist: 'Hoàng Dũng',
        rankDelta: 0,
        playsText: '950K lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDCZ362Cw_f9BEWLq_tdmvtNHCUpxz3Ky8H4UFupxjCGZQ89UYUbmLX5KeoEgfIPNq3WQnWN2JKmg16H-s8_1t6oYu4YG2AzCMmDeOZ8f7lIB5Dh4YrE9d9f6IrJKtvFsMywXpmSmwSTJfPu9lgLffEK4V1-NgoKzkIrlOytK8IxRdh1VQuO9eKZDvz4jAnJAdASvOuadRS7CwWL7-1rxjmjIVJ6W6gCNAayEXUQ2q9h6CwbXgd73j3aA',
      ),
      ChartItemModel(
        rank: '05',
        title: 'Vũ Trụ Có Anh',
        artist: 'Phương Mỹ Chi',
        rankDelta: 1,
        playsText: '820K lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDxRosWi2aLxaDciZazULHLHJWnBADB2pOQ9l00HJswglgV5fi5DsisdBCj9RwbEj3HkQA3JzEMIR1x14eLfXzz55geDFHknOBEHkY3fH8VHuNi_8fGUf9nF8QMulL0VZuu1-uioB5zfPLIo_OqpoI5y3o0YndExgx24KW6Zjfd5iGlonZ5AXoKY0QdpjkrjqtuQ7xQeQy3rDkNbk7wSczbyAt6PV5y8NON3HfDickr3z2iTo1iaai3Zg',
      ),
    ];
  }

  List<ChartItemModel> getGlobalChartItems() {
    return const [
      ChartItemModel(
        rank: '01',
        title: 'Die With A Smile',
        artist: 'Lady Gaga, Bruno Mars',
        rankDelta: 1,
        playsText: '3.4M lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDXuUKynlBv5fMCMdcUKcsOtgM61v6smbs5e7UZg076eFAYS-kU23OXl1UCu9_xzWd_Kf6K5nu-HhYOboApfXlBKUKCQIz0M3aBMCxMHu4VCYngfcxkEnoygkM1hZVNunPDveoWl-Rm4cx_Z9vynOi9gqgZdLqk8iOFxx1mABEHwU6Xn-_Fpa8iBh06JYqm1uKfkzOdoNh27Z3RF8YRsbB_H-GAPXscAZ1Z1YTnHIw5yermsqV3o--MYA',
        isLeader: true,
        badgeLabel: 'Global #1',
      ),
      ChartItemModel(
        rank: '02',
        title: 'Birds of a Feather',
        artist: 'Billie Eilish',
        rankDelta: 0,
        playsText: '2.8M lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAyQLW2j4_WBQJkMteyFnv9NdOJP-BkWMmohAVBqH1ls6AwoWXf_D73xcvagyeY2tcSGewSh15biyIpTynTiao902n08RIpfCCbuvyk7sB2fIVO2V-mYm-gvlxy-B-QKsp2jNj55X0EN0QOQ9Row3TyVhW0mEzjpG_xcjKGoDGfAk9AgtcUX8m3vaNMN38q4mFaSFEGVnGjtgw748bhiR5O3Ztz-olapJ7t7cjpFShqZ-QcsQW5orgoow',
      ),
      ChartItemModel(
        rank: '03',
        title: 'Espresso',
        artist: 'Sabrina Carpenter',
        rankDelta: 2,
        playsText: '2.5M lượt nghe',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBFvMFZOb-ugTj17pmjBgB0YChlAJlF6D6I-dijNr9_6xBBGQrZdAvPKT8oMbhyxGvwWb8u1oTrwg64Ok0gmgHR82PIukh9LOvNjASJoDjRvfQ-43D86YRgifaEYvDpdZvCTFfiIqCZMrTm2REkx7QAbVGeg5QvfoULykEYdG-yWZVbw7G60Lyi6tz7tCGPsL49xL7Ps2QCHQRa0IshBiOzr4WjyBx2aFNuhtZTHPgplcxaBnlu16pJvg',
        isHumHot: true,
        badgeLabel: 'Viral Hum',
      ),
    ];
  }

  SpotlightRadarModel getSpotlightRadar() {
    return const SpotlightRadarModel(
      title: 'Khóa Ánh Mắt Lại',
      artist: 'Bùi Trường Linh',
      humCountText: '128.4K người ngân nga',
      matchRateText: '98.6% Nhận Diện Chuẩn',
      growthText: '+48% Huýt sáo 24h',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDSuaDu1jlw-5o5c99Bnn-mh0qSiYbG9ZmlReIUKOd3K69M7yjJw0btQCapfTdMku4MXgK17WKf2wpVhdH-hJZ-1deSM9nj0QcbLrpsBuApMpSdZC14Lsr2LPSIL5nA3VRerS0UeY0LTikrZjtY32eItyupzqGlgEoDFvfVLWtq0XtpBziQbUUvjvIWbWOcJzvpn43pdXOedp7dhaNugBi0JF4Z7qGtOETNM-VF3e49-DoHvjTfI9K1Aw',
    );
  }

  List<MoodGenreModel> getMoodGenres() {
    return const [
      MoodGenreModel(
        id: 'acoustic',
        title: 'Acoustic Mộc',
        subtitle: 'Ấm áp & thư thái',
        icon: Icons.music_note_rounded,
        dotColor: Color(0x668B001E),
      ),
      MoodGenreModel(
        id: 'lofi',
        title: 'Lo-Fi Làm Việc',
        subtitle: 'Tập trung tuyệt đối',
        icon: Icons.headphones_rounded,
        dotColor: Color(0x80FF4B4B),
      ),
      MoodGenreModel(
        id: 'vpop',
        title: 'V-Pop Thịnh Hành',
        subtitle: 'Bắt nhịp giai điệu',
        icon: Icons.local_fire_department_rounded,
        isHot: true,
        dotColor: AppColors.primary,
      ),
      MoodGenreModel(
        id: 'edm',
        title: 'EDM & Rap',
        subtitle: 'Bùng nổ năng lượng',
        icon: Icons.bolt_rounded,
        dotColor: AppColors.tertiary,
      ),
    ];
  }
}
