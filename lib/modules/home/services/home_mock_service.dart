import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../models/chart_track_model.dart';

class HomeMockService {
  List<PlaylistModel> getAiMixes() {
    return const [
      PlaylistModel(
        id: 'mix_1',
        title: 'Acoustic Tĩnh Lặng',
        subtitle: 'Phối lại bởi AI • 2.4k thính giả',
        tag: 'AI Mix',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDeVtmSLo7AYHFzq8ffQ-mvBCjxiB3c8s94i9mIfJCO3hENDTG1I0Hodk1rvwG5eJQDpJh0Ho2lP7FV_kbZFT9DqN7M_E4_Hx3a7U4F2r7a0d28jJ0s1b1VSHStmjDfkW56YN5WYdr3pwh_Sj4CJXETmWKE8ilmxDxAExfwAekZSGsviGjrO1ngOfKc5UlxvibjA_nRLUw4cLEdH8SOEwcAVgmVCBXf6Mh53lMTa50JO_-icYDmr2-T7g',
      ),
      PlaylistModel(
        id: 'mix_2',
        title: 'Lo-Fi Giai Điệu Đêm',
        subtitle: 'Nhịp tim 68 BPM • Chillout',
        tag: 'AI Mix',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCsPWAY2IVf8TlN17bfSsbUhIEspR4ze4hjntQIiZF-_2MANmLlJvctJoaVyH4f_fl-siN_GMQhRwWrSa-13lchwsC0pYVmyt2sTFy6LCu0L-GiJriOjxsOe5EOq0-eegLHs5FhPffWOB9L_2qAaMX31wiDUQjElLG86_pu9Ege7n789u_WX95f-ku7-LcfUDGcLiUUxaUDBe0O9Uz_z44Zj7RxP2B4DAajQAuc-2Gu8TgxmALDyAyFDg',
      ),
      PlaylistModel(
        id: 'mix_3',
        title: 'Indie Việt Tinh Tuyển',
        subtitle: 'Hoàng Dũng, Vũ, Trang & AI',
        tag: 'Indie Pick',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA6OEJ6un7aTq08215a0nxFGq6MLHkXtuH113GPV7sbK-smUvMt323WJtwONCqmL6RfZFhEkviuZv56c2n1Gq6gFgqciBw8fPDaM42f3IcP3lvfIei7gUxMstMXZuUpE5W8EoexcAN248HaUqj8FDcXbgQjd4JkY_aXeWWTT2l2__PdO_nANEyhWATlYyWqiPYXoQS-WbuMdD3q4NtzObP6nKconBhPVGpdLMzmg5qJ2iREl-lfui5Pig',
      ),
    ];
  }

  List<TrackModel> getRecommendedTracks() {
    return const [
      TrackModel(
        id: 'track_1',
        title: 'Dưới Ánh Hoàng Hôn',
        artist: 'Vũ ft. Min',
        matchPercentage: '98%',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBrOZgCzcXR1_2YIE8bUUpDw8-kGmcYaEXBJLBmlJwjN8XGLw6MqhRxnwpi1ZBfmn6nOVHqnhCQBv8tPt2C5NSbr5j3HpmBJ5zGS38yZ4K-fW2ef3mmQoC4UtE8ZHKeIvjvJsxULpaHrNV_J78WEWtN8UycmZPLPJzeiq85-YFyK8t43gaIuNP1J-B6q1bDeKYNWlwWh3MO8J5RLx0LonISUV7n2uKJ7OM68P8x9tW7B-8rthgiIfdYLQ',
        isFavorite: false,
      ),
      TrackModel(
        id: 'track_2',
        title: 'Chạm Vào Giai Điệu',
        artist: 'Sonara AI Mastered',
        matchPercentage: '95%',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBySUc5GA-Fx3mDooypAGPUC8E6Rk0T7O9-4K9W8erI2unTulH3tzzto2qaSlSei3C6FMYnnE8SZrbNBf22j9L_u_OtAzaJwPxRh6wGXT-HD6T25U0x2kTH8IifVcxMvUwb58VgpCEadEAXkyRDkHy1VGBHhMOgaIKqK0TZEpYH9h5Nf5K_h4byGBjwMd3rdoD4O2a2NxbPNtXgtCP4GrUDbIeFbsXZB0YnfnKMz-FtR0CXRmaCQTxroA',
        isFavorite: true,
      ),
      TrackModel(
        id: 'track_3',
        title: 'Mưa Trên Tầng Thượng',
        artist: 'The Cassette',
        matchPercentage: '91%',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDbTGUCf2q3ha8Ut0e4d30KqyI9Oa-aflNMoBJjFHnlaOC49UMxGJJeP6dQpFlgfRZ_z5LfZCfAx8J1mG-PEHJOAjccNoJ83TloSl9Yf7onRpN2B5msxEZtLPsqN6KFRb8sGy6tW8VgubrhFriUC6VBzPvCtowUGN61_EUXGH7NrTTdYahW1wuDyAYVdnAYHEG1v5czDtgMSUEOPsXUnROH7TgSEXNF7n50KMcl9xJSzgkaaDFOQJpHFg',
        isFavorite: false,
      ),
    ];
  }

  List<ChartTrackModel> getTrendingCharts() {
    return const [
      ChartTrackModel(
        rank: '01',
        title: 'Từng Là Của Nhau',
        artist: 'Bảo Anh, Táo',
        plays: '1.2M lượt nghe',
        rankDelta: 2,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCdrkOhXSM92jsXGqN_S7m_NJbRj9DJzsO1wm4BEisL5F_CJ2mpf2IBMUEWU8keH_bk7vVmrx9bomnwonqZ7DUxTNqh9f4W8OMJoizvDCELGK1uLsHSi0PW15xx8AaC3GDOhpunI564qfO_SZ2DpL2zXHYDP6B1lf-iMc5b231U-RidH1e_ain-jm7omZE8A49R20ZsvIpD3JLxpYKzgcWn82Wx68mL1vqdnjHnb3KvsAKqx5UsWVaBXw',
      ),
      ChartTrackModel(
        rank: '02',
        title: 'Lạc Giữa Màn Đêm',
        artist: 'Sơn Tùng M-TP',
        plays: '980k lượt nghe',
        rankDelta: 0,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA3jjOj9QkjVNgwu6MSo2fXm_08k-plckAZVA9vTse1yhqKxYZneG4_ORrSq270DPcyIZ4ovrphSxF0qWSC-8zbMpWE4eRYJ7uPv1eH-TluKtdlMfQFQX7ntfzz7H6I4itf-Yr05HsAP95DsT3FO5WXn38U3R00vTNvoo4-SYah-HI92-vSiqkR_yr0kLO3oiAuUI9nj9x0BxIi1dJMyhsU7pqKkBHPafE0xMQSZj1cmpj-FOWt9Fj4PA',
      ),
      ChartTrackModel(
        rank: '03',
        title: 'Cơn Mưa Mùa Hạ',
        artist: 'Hoàng Dũng',
        plays: '845k lượt nghe',
        rankDelta: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuClkhSiOBE_eCE6gJHefo9Ni13t1m0bbBiCsNu4STjaAqRONG38YyIjU-4GIwZ0InddheThzr7pS1qx7Pds-z2ndW3bWZeLMH3fmPTcXyAcXMySQ_mGKD_tnghHCdZPDgaIV7bA9JBFPWiBG2LnG6uk7qCVKNaGGMREpZFv9_j2YmhKXfxfUedo0H3rvC1DgQADydfW3XT1pWn3BfFNG-v-LQLABivSISVPjI9xX3h-BJ2tUQmrOR5pYg',
      ),
      ChartTrackModel(
        rank: '04',
        title: 'Vũ Trụ Có Anh',
        artist: 'Phương Mỹ Chi, DTAP',
        plays: '712k lượt nghe',
        rankDelta: -1,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB1u_LpQ13SiCProB8DLd9yLjZZlKLm_2viAJ3XkKKHonUSQjHJm21OJUP9M7oHXeL-ZLZvjm9iWRkHswjegVz0P1hD_ikqwTm13SR1ljWGC3JyZWcEKnL2fq2ZwH6uPMqH1b2HSWvIlRNTTBH_VzuuxW1-WtYQ5JG65Q55gENP2EpebaoN-x2_sFQg8V440wEMDDcGyokVGHYwz1_eIzsIpZ1_rWctBUrjykeCJ_OIE3jI9wSkWLEvCQ',
      ),
      ChartTrackModel(
        rank: '05',
        title: 'Bật Tình Yêu Lên',
        artist: 'Tăng Duy Tân, Hòa Minzy',
        plays: '650k lượt nghe',
        rankDelta: 3,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCaz1Gw9VKoCcE5b5XPCqCdZaOoNFZ-yPY_yllHR7KLhmYldrBdHS0M9PRACuJfpSo1wojM4jQQskTd4p1myBfd5kqMZESjGbsD_Kd6fziByk9YcXYVrrTcgUhfN0-TDLuEb8OO7wqrrHYDuz2i5TQqAaVAMxiFfWu2-Z_ia2R4QG63i-amK5QGpUP1M9iLuyqYw3XB66KptGxw8IH6kNGl9YdNvIYmC5DcXDcTsWyTXp0mzbNi9qsrCw',
      ),
    ];
  }
}
