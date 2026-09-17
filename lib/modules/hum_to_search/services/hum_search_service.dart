import '../models/hum_search_result_model.dart';

class HumSearchService {
  HumSearchResultModel getMockSearchResult() {
    return const HumSearchResultModel(
      confidenceScore: 98,
      bestMatch: SongMatchModel(
        id: 'hum_match_1',
        title: 'Bầu Trời Mới',
        artist: 'Da LAB ft. Miu Lê',
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDyWzJQ_ykh4Go9R6ERjWZWLeH0YazfpVILLk7Cn5KFnC5L0eKQ83-oJ46xWLu0To24G-TZaBe-JOO-Zo_Rb70vpcnIpb4vAbuwxCYuF12ZDPhP4esGvmpvRugW2U9vzQm7L5uNDIhrdGcgQkgGBHJccVBF1hRh0g3Ge4qBF_j5U1gKXJG-8TBs0ExTQIh7f0z9ZuZmuemFU_99z34Q44_LrbDDd7o226tP_kg76e6uque7Sl25t4hhzw',
        album: 'Album Single (2024)',
        matchPercentage: 96,
        matchReason: 'Trùng khớp cao độ giọng hát',
        detectionSegment: 'Điệp khúc',
        timeRange: '01:15 - 01:28',
        isTop1: true,
        isFavorite: false,
      ),
      otherCandidates: [
        SongMatchModel(
          id: 'hum_match_2',
          title: 'Có Đôi Lần',
          artist: 'Đức Trí, Hoàng Dũng',
          coverUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBFb44tPFoIcLYv1SxA_PyQ0II656dH9fRP2kN2VaPVAks1KGjOw0NW7kvnAmKEFirTMbcbxfbqQv08Ckqi76h4HiFfF92bdkR2rwUGw0T9pMDXOATjAvB_ymg3argcMC8IWVrg5AaSe9iM7rFdJ4PoCqfA4Ml8q09Vioxo05HCYuMh427RWeE5FZ0rURkm1f1vfea-xk-ChRS-8-9F6y5BbALG7N-twZpFLBz3MKXJQ3IQhmFvBA2Nrw',
          album: 'Single',
          matchPercentage: 84,
          isTop1: false,
          isFavorite: false,
        ),
        SongMatchModel(
          id: 'hum_match_3',
          title: 'Ngày Đầu Tiên',
          artist: 'Đức Phúc',
          coverUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCNEaLdRTVqvj8s90M374mgyPWGac-4PU-SnIK86hq4dCeZDNYX7JcYMheNX6t4Eq_WAlVgyrf3ubd9mJdTv9DXUyeUYKD180aw0eKgXAjnN1QChMR5Qh9pYiOhY8IL3UFqejWeIzS_yr-Vai9aHgdagu-PEZ6Fq8ksos2FFIDrpAEMz6P-DyexHhEC48Jh8Fn0G78mKW-qApPCkXNeK8HK330lKh_q1vP8dID6rVrGtzkkbHr0H4eB_g',
          album: 'Single',
          matchPercentage: 78,
          isTop1: false,
          isFavorite: false,
        ),
      ],
    );
  }

  List<String> getGuidanceHints() {
    return const [
      'Bạn có thể hát một câu, huýt sáo hoặc ngâm nga “la la la”...',
      'Càng rõ nhịp điệu chính, AI nhận diện càng chuẩn xác!',
      'Đang phân tích cao độ và chuỗi hợp âm thực...',
      'Hãy giữ micro ở khoảng cách 15-20cm để chất lượng tốt nhất.',
    ];
  }
}
