# Danh Sách Tính Năng Ứng Dụng Âm Nhạc Sonara (Feature Specification)

> **Tài liệu đặc tả toàn bộ tính năng dựa trên hệ thống giao diện UI của ứng dụng Sonara.**  
> *Phiên bản: 1.0.0 • Ngôn ngữ phát triển: Flutter (Dart) • Kiến trúc: Clean Architecture & BLoC Pattern.*

---

## Mục Lục
1. [Tổng Quan Ứng Dụng](#1-tổng-quan-ứng-dụng)
2. [Hệ Thống Điều Hướng Toàn Cục (Global Shell & Navigation)](#2-hệ-thống-điều-hướng-toàn-cục-global-shell--navigation)
3. [Màn Hình Khám Phá (Home Screen)](#3-màn-hình-khám-phá-home-screen)
4. [Màn Hình Bảng Xếp Hạng (Charts Screen)](#4-màn-hình-bảng-xếp-hạng-charts-screen)
5. [Tính Năng Nhận Diện Giai Điệu (AI Hum-to-Search)](#5-tính-năng-nhận-diện-giai-điệu-ai-hum-to-search)
6. [Trình Phát Nhạc (Audio Player - Mini & Full Now Playing)](#6-trình-phát-nhạc-audio-player---mini--full-now-playing)
7. [Màn Hình Thư Viện Cá Nhân (Personal Library Screen)](#7-màn-hình-thư-viện-cá-nhân-personal-library-screen)
8. [Màn Hình Chi Tiết Playlist (Playlist Detail Screen)](#8-màn-hình-chi-tiết-playlist-playlist-detail-screen)
9. [Màn Hình Hồ Sơ & Cài Đặt Âm Học (Profile Screen)](#9-màn-hình-hồ-sơ--cài-đặt-âm-học-profile-screen)
10. [Bảng Ma Trận Tính Năng & Trạng Thái Kỹ Thuật (Feature Matrix)](#10-bảng-ma-trận-tính-năng--trạng-thái-kỹ-thuật-feature-matrix)

---

## 1. Tổng Quan Ứng Dụng

**Sonara** là ứng dụng phát nhạc trực tuyến kết hợp công nghệ nhận diện giai điệu (Hum-to-Search) độc đáo. Ứng dụng mang phong cách thiết kế hiện đại, sang trọng với tông màu chủ đạo **Crimson Wine** (`#9A1B2F`) trên nền ấm **Warm Ivory** (`#FBF9F7`), tối giản các hiệu ứng đổ bóng nặng và chi tiết thừa để mang lại trải nghiệm nghe nhạc thuần túy, cao cấp tương tự Apple Music và Spotify.

---

## 2. Hệ Thống Điều Hướng Toàn Cục (Global Shell & Navigation)

*File: [main_shell_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/app/presentations/main_shell_screen.dart), [main_bottom_nav_bar.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/app/presentations/widgets/main_bottom_nav_bar.dart)*

### Các tính năng chính:
- **Thanh điều hướng đáy (Bottom Navigation Bar)**:
  - **Tab 1: Khám Phá (Home)** — Icon la bàn âm nhạc, truy cập kho nhạc gợi ý, mixes và bảng xếp hạng xu hướng.
  - **Tab 2: Xếp Hạng (Charts)** — Icon bảng xếp hạng, duyệt top hit Việt Nam & Quốc Tế.
  - **Nút trung tâm AI HUM**: Thiết kế hình tròn gradient đỏ đô nhô lên nổi bật giữa thanh điều hướng, cho phép người dùng kích hoạt tính năng tìm kiếm bằng giai điệu tức thì từ bất kỳ màn hình nào.
  - **Tab 3: Thư Viện (Library)** — Icon thư viện cá nhân, danh sách phát, bài hát đã tải và bài hát yêu thích.
  - **Tab 4: Hồ Sơ (Profile)** — Icon hồ sơ, xem chỉ số nghe nhạc, thiết lập hiệu ứng âm thanh và giao diện.
- **Thanh Mini Player Bar ghim đáy**:
  - Nằm ngay phía trên thanh Navbar với khoảng đệm an toàn `12px`, không bị che khuất bởi phím Home của thiết bị.
  - Hiển thị bài hát đang phát xuyên suốt ứng dụng với thao tác chạm để mở trình phát toàn màn hình.

---

## 3. Màn Hình Khám Phá (Home Screen)

*File: [home_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/home/presentations/home_screen.dart)*

### Các tính năng chính:
- **Thanh tiêu đề (Home Header)**:
  - Hiển thị logo sóng âm và tiêu đề "Khám Phá".
  - Nút tìm kiếm nhanh (Search) và nút thông báo (Notification).
  - Avatar đại diện có viền đỏ chuyển hướng nhanh sang màn hình Hồ sơ cá nhân.
- **Banner Hero Tìm Kiếm Bằng Giai Điệu (HumHeroBanner)**:
  - Khối banner gradient đỏ đô nổi bật ở đầu trang.
  - Chip chức năng "Tìm kiếm bằng giai điệu".
  - Tiêu đề mời gọi: *"Không nhớ tên bài hát? Ngân nga để tìm ngay"*.
  - Sóng âm âm học sống động (Dynamic live soundwave visualization) chuyển động liên tục.
  - Nút CTA tròn trắng *"Thử tìm kiếm ngay"* mở trực tiếp màn hình thu âm nhận diện.
- **Mixes cho bạn (AI Personalized Playlists)**:
  - Danh sách cuộn ngang các danh sách phát tự động tạo dựa trên gu âm nhạc của người dùng.
  - Thẻ playlist gồm: Ảnh bìa nghệ thuật, thẻ phân loại (`AI MOOD`, `AUTO MIX`), tên playlist, số lượng bài hát và tổng thời lượng.
  - Bấm vào thẻ để mở màn hình [Playlist Detail Screen](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/playlist/presentations/playlist_detail_screen.dart).
- **Gợi ý cho bạn (Taste-matched Recommended Tracks)**:
  - Danh sách các bài hát gợi ý hiển thị dạng danh sách phẳng, nền trong suốt tinh tế.
  - Mỗi hàng bài hát gồm: Ảnh đại diện track nhạc bo góc, tên bài hát, ca sĩ, tỷ lệ khớp gu âm nhạc (ví dụ: `98% Khớp gu`), nút yêu thích (trái tim).
  - Chạm vào bất kỳ vị trí nào trên hàng để bắt đầu phát nhạc ngay lập tức.
- **Xu hướng (Trending Charts Card)**:
  - Khối bảng xếp hạng xu hướng trong ngày/tuần.
  - Bộ gạt thời gian (Toggle Switch): chuyển đổi giữa xếp hạng **Theo Tuần** và **Theo Tháng**.
  - Hiển thị Top bài hát thịnh hành với: Thứ hạng số (01, 02, ...), biến động vị trí (tăng hạng `+`, giảm hạng `-`, giữ hạng), ảnh bìa, tên bài hát, nghệ sĩ và số lượt nghe.
  - Chạm bài hát để phát và mở trình phát `NowPlayingScreen`.

---

## 4. Màn Hình Bảng Xếp Hạng (Charts Screen)

*File: [charts_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/charts/presentations/charts_screen.dart)*

### Các tính năng chính:
- **Thanh tiêu đề (Charts Header)**:
  - Tiêu đề màn hình "Bảng Xếp Hạng" gọn gàng, nút tìm kiếm và avatar cá nhân.
- **Bộ chuyển đổi bảng xếp hạng (ChartTabSwitcher)**:
  - Chấm tín hiệu nhấp nháy (Pulsing Dot) cùng trạng thái *"Cập nhật trực tiếp"*.
  - Bộ chuyển tab 2 lựa chọn: **"Việt Nam Hot 50"** và **"Quốc Tế Viral"** có hiệu ứng chuyển động mượt mà.
- **Hàng nút phân loại danh mục (ChartCategoryPills)**:
  - Danh sách cuộn ngang các bộ lọc: "Tổng hợp", "Thịnh hành", "Lossless Master", "Podcast".
- **Thẻ tiêu điểm Radar tuần này (SpotlightRadarCard)**:
  - Banner nền gradient đỏ sẫm dành cho bài hát có tốc độ lan tỏa cao nhất tuần.
  - Nhãn "Radar tuần này" và chỉ số tăng trưởng (ví dụ: `+48% Huýt sáo 24h`).
  - Bài hát tiêu điểm với ảnh bìa, tên bài, nghệ sĩ, số người ngân nga tìm kiếm và tỷ lệ nhận diện chuẩn xác.
  - Visualizer sóng âm mini phản hồi nhịp điệu và nút tròn phát bài hát nhanh.
- **Bảng xếp hạng Top 5 tuần này (Top 5 Leaderboard)**:
  - **Thẻ Quán quân (Rank 01)**: Thiết kế đặc quyền với viền dọc đỏ đô sang trọng, thứ hạng "01" kích thước lớn, huy hiệu `No.1`, chỉ số biến động hạng và lượt nghe.
  - **Thẻ Thứ hạng 02 đến 05**: Thiết kế phẳng, viền mờ `borderSubtle`, hiển thị biến động thứ hạng, lượt nghe và nút phát bài.
- **Lưới Khám phá Tâm trạng & Thể loại (MoodGenreGrid - Lưới 2x2)**:
  - **Acoustic Mộc**: Giai điệu mộc mạc, thư thái.
  - **Lo-Fi Làm Việc**: Nhịp điệu êm dịu, tập trung làm việc và học tập.
  - **V-Pop Thịnh Hành**: Các bản hit nhạc Việt mới nhất (kèm nhãn `HOT`).
  - **EDM & Rap**: Bùng nổ năng lượng, giai điệu sôi động.
- **Dải mời gọi tìm kiếm nhanh (HumQuickInviteCard)**:
  - Dải thông điệp cuối trang: *"Nhớ lời nhưng quên tên bài hát? - Ngân nga hoặc huýt sáo để tìm kiếm"*, có nút *"Thử ngay"* điều hướng sang Hum Search.

---

## 5. Tính Năng Nhận Diện Giai Điệu (AI Hum-to-Search)

*File: [hum_to_search_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/hum_to_search/presentations/hum_to_search_screen.dart), [hum_search_result_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/hum_to_search/presentations/hum_search_result_screen.dart)*

Tính năng cốt lõi và là điểm nhấn công nghệ của Sonara giúp người dùng tìm bài hát bằng cách huýt sáo hoặc ngân nga giai điệu.

### 5.1. Màn Hình Lắng Nghe & Thu Âm (`HumToSearchScreen`):
- **Chuyển đổi chế độ âm học (ModeSegmentedSwitch)**:
  - Hai chế độ tối ưu hóa thuật toán nhận diện: **Huýt sáo (Whistle)** và **Ngân nga (Humming)**.
- **Thanh trạng thái âm học**:
  - Hiển thị trạng thái *"Đang lắng nghe"* với chấm pulsing dot hoạt họa.
  - Hiển thị chuẩn mẫu âm thanh thu âm: *"48kHz / Lossless"*.
- **Vòng sóng âm động phản hồi giọng nói (AnimatedMicVisualizer)**:
  - Icon Microphone trung tâm được bao quanh bởi nhiều lớp sóng âm lan tỏa động (Ripple soundwaves) co giãn theo nhịp điệu.
- **Bộ đếm thời gian thu âm (Timer Progress)**:
  - Hiển thị số giây đã thu âm và tổng thời gian tối đa (ví dụ: `00:07 / 00:15`).
  - Thanh tiến trình tuyến tính (Progress bar) tự động chạy từ 0 đến 15 giây.
- **Thẻ gợi ý xoay vòng (HintRotatorCard)**:
  - Tự động thay đổi các lời khuyên hữu ích để người dùng ngân nga chuẩn xác hơn (giữ mic gần miệng, ngân nga rõ cao độ, tránh tiếng ồn xung quanh).
- **Cụm nút điều khiển**:
  - Nút chính: *"Dừng & Phân tích ngay"* (kèm hiệu ứng xoay loading khi đang suy luận).
  - Nút phụ: *"Hủy bỏ"* đóng màn hình quay về trang trước.

### 5.2. Màn Hình Kết Quả Tìm Kiếm (`HumSearchResultScreen`):
- **Banner độ tin cậy**:
  - Thông báo: *"Đã tìm thấy 3 bài hát tương đồng"*.
  - Tỷ lệ tin cậy: *"Độ khớp: 96%"*.
  - Nút *"Hát lại"* (Retry) cho phép thu âm lại tức thì nếu chưa hài lòng.
- **Thẻ kết quả khớp nhất (BestMatchCard - Top 1)**:
  - Hiển thị ảnh bìa album lớn, tên bài hát, nghệ sĩ, tên album, nhãn chất lượng Lossless.
  - **Trình phát thử đoạn trích (Snippet Preview Player)**: Tích hợp phát thử đoạn nhạc đặc trưng 15-30 giây của bài hát kèm thanh thời gian phát riêng.
  - Thao tác nhanh: Nút yêu thích (trái tim), nút thêm vào danh sách phát (+ Playlist).
  - Nút lớn: *"Nghe bản đầy đủ"* mở trực tiếp vào trình phát [NowPlayingScreen](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/player/presentations/now_playing_screen.dart).
- **Danh sách bài hát tiềm năng khác (CandidateTrackCard)**:
  - Liệt kê các kết quả có tỷ lệ khớp thấp hơn (ví dụ: 88%, 79%).
  - Mỗi thẻ có ảnh bìa, tên bài hát, nghệ sĩ, độ khớp % và nút phát thử nhanh.
- **Thẻ hỗ trợ giải quyết sự cố (TroubleshootingCard)**:
  - Hiển thị khi người dùng cần phương án thay thế: mẹo ngân nga rõ lời hơn, hoặc tùy chọn chuyển sang *"Tìm kiếm bằng lời bài hát"*.

---

## 6. Trình Phát Nhạc (Audio Player - Mini & Full Now Playing)

*File: [mini_player_bar.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/player/presentations/widgets/mini_player_bar.dart), [now_playing_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/player/presentations/now_playing_screen.dart)*

### 6.1. Thanh Phát Thu Nhỏ (MiniPlayerBar):
- Luôn hiển thị trên Navbar khi có bài hát đang phát.
- Ảnh thu nhỏ bài hát bo tròn góc, tên bài hát, ca sĩ.
- Nút Play/Pause nhanh không cần mở toàn màn hình.
- Nút trái tim đánh dấu bài hát yêu thích.
- Chạm vào toàn bộ thanh để vuốt mở [NowPlayingScreen](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/player/presentations/now_playing_screen.dart).

### 6.2. Trình Phát Toàn Màn Hình (NowPlayingScreen):
- **Thanh Header**:
  - Nút mũi tên gập xuống (Dismiss chevron) để quay lại màn hình trước.
  - Ngữ cảnh phát nhạc: Hiển thị nguồn phát (ví dụ: *"Phát từ gợi ý • AI Hum Match (98%)"* hoặc tên Playlist).
  - Nút menu 3 chấm mở thêm tùy chọn bài hát.
- **Artwork Album Hero (AlbumArtworkHero)**:
  - Ảnh bìa album khổ lớn 300x300 bo góc cong 24px, đổ bóng âm học ấm áp.
  - Huy hiệu định dạng âm thanh chất lượng cao: `Hi-Res Lossless 24-bit`.
- **Thông tin bài hát**:
  - Tên bài hát hiển thị chữ lớn đậm, tên nghệ sĩ & album.
  - Nút trái tim yêu thích có phản hồi chuyển màu đỏ đô khi kích hoạt.
- **Thanh trượt thời gian phát (PlaybackScrubber)**:
  - Hiển thị thời gian đã phát (`01:42`) và thời lượng bài hát (`03:55`).
  - Thanh slider mượt mà cho phép người dùng kéo thả để tua nhạc đến bất kỳ giây nào.
- **Cụm phím điều khiển phát nhạc (PlaybackControlsRow)**:
  - **Nút Xáo trộn (Shuffle)**: Bật/tắt chế độ phát ngẫu nhiên.
  - **Nút Bài trước (Previous)**: Quay lại bài hát trước hoặc về đầu bài.
  - **Nút Phát/Tạm dừng chính (Play/Pause)**: Thiết kế nổi bật với kích thước lớn 64x64 bo tròn.
  - **Nút Bài tiếp theo (Next)**: Chuyển sang bài hát kế tiếp trong danh sách phát.
  - **Nút Lặp lại (Repeat)**: Chuyển đổi giữa không lặp, lặp lại toàn bộ playlist, hoặc lặp lại một bài.
- **Lời bài hát đồng bộ thời gian thực (SyncedLyricsCard)**:
  - Khối thẻ hiển thị lời bài hát chạy chữ theo thời gian thực (Karaoke Synced Lyrics).
  - Dòng đang hát được làm nổi bật với chữ trắng rõ nét, các dòng trước/sau hiển thị mờ.
  - Tự động cuộn theo tiến trình bài hát.
- **Điều hướng ngõ ra âm thanh & Âm thanh vòm (AcousticRouteChips)**:
  - Nút bật/tắt hiệu ứng **Spatial Audio (Âm thanh vòm 3D)**.
  - Nút hiển thị và chuyển đổi thiết bị phát âm thanh (ví dụ: *"AirPods Pro"* hoặc loa ngoài).

---

## 7. Màn Hình Thư Viện Cá Nhân (Personal Library Screen)

*File: [library_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/library/presentations/library_screen.dart)*

### Các tính năng chính:
- **Thanh Header**: Tiêu đề "Thư Viện", nút tìm kiếm và avatar cá nhân.
- **Cụm tác vụ Thư viện**:
  - Tiêu đề *"Thư viện của tôi"*.
  - Nút tìm kiếm bài hát trong thư viện.
  - Nút bo tròn *"Tạo mới"* (+ New Playlist) tạo danh sách phát cá nhân.
- **Hàng bộ lọc danh mục (LibraryFilterChips)**:
  - Các tab lọc nhanh: "Tất cả", "Playlists", "Bài hát đã thích (328)", "Lịch sử AI Hum (14)", "Nghệ sĩ & Album".
- **Hero Card 1 - Bài hát yêu thích (LikedSongsHeroCard)**:
  - Thẻ lớn nền đỏ đô với hoa văn trái tim chìm.
  - Chỉ báo tải ngoại tuyến: *"Ngoại tuyến"* kèm icon tải hoàn tất.
  - Thống kê: *"328 bài hát • Đã đồng bộ 96kHz"*.
  - Nút tròn phát ngẫu nhiên nhanh toàn bộ bài hát đã thích.
- **Hero Card 2 - Lịch sử tìm bằng giai điệu (AiHumHistoryCard)**:
  - Hiển thị số lượng giai điệu đã nhận diện: *"14 giai điệu"*.
  - Kết quả tìm kiếm gần nhất: tên bài hát, nghệ sĩ và tỷ lệ khớp %.
  - Bộ visualizer sóng âm 4 thanh và nút phát nhanh bài hát vừa tìm.
- **Nghệ sĩ đang theo dõi (FollowingArtistsRow)**:
  - Danh sách cuộn ngang avatar tròn các nghệ sĩ yêu thích.
  - Tích xanh chứng nhận cho nghệ sĩ chính thức.
  - Chấm tín hiệu thông báo khi nghệ sĩ có bài hát/album mới.
  - Nút `+` thêm nghệ sĩ theo dõi mới.
- **Danh sách phát cá nhân (LibraryPlaylistTile)**:
  - Hiển thị danh sách các playlist của người dùng với: Ảnh bìa, tên playlist, số lượng bài hát, thẻ phân loại và nút phát nhanh.
- **Dải dung lượng lưu trữ ngoại tuyến (StorageMetricTile)**:
  - Thống kê dung lượng nhạc đã tải về bộ nhớ máy (ví dụ: *"Đã tải 4.2 GB • Chất lượng Studio Master"*).
  - Nút *"Quản lý"* để kiểm tra danh sách file đã tải và dọn dẹp bộ nhớ đệm.

---

## 8. Màn Hình Chi Tiết Playlist (Playlist Detail Screen)

*File: [playlist_detail_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/playlist/presentations/playlist_detail_screen.dart)*

### Các tính năng chính:
- **Thanh tiêu đề Header**: Nút quay lại (Back), tiêu đề danh sách phát và nút menu tùy chọn (chia sẻ, chỉnh sửa playlist).
- **Artwork Playlist Hero (PlaylistHeroArtwork)**:
  - Ảnh đại diện playlist khổ vuông 300x300, bo góc 24px với hiệu ứng đổ bóng đa lớp.
  - Huy hiệu `AI LIVE MIX` có chấm nhấp nháy và huy hiệu chất lượng âm thanh `Hi-Res 96kHz`.
- **Thông tin Metadata Playlist**:
  - Nhãn phân loại: `HUM-TO-SEARCH ENGINE`.
  - Tên playlist: *"Resonance AI Curated Mix #01"*.
  - Mô tả tự động: Tự động tổng hợp dựa trên 5 bài hát gần nhất mà người dùng đã tìm kiếm.
  - Tổng số bài hát và thời lượng nghe toàn bộ playlist.
- **Cụm nút điều khiển hành động (PlaylistActionControls)**:
  - Nút Phát / Tạm dừng lớn viền gradient đỏ.
  - Nút Smart Shuffle (Xáo trộn thông minh).
  - Nút Tải ngoại tuyến toàn bộ playlist (Download).
  - Nút Trái tim yêu thích lưu playlist vào thư viện.
- **Thẻ phân tích cảm xúc âm học (PlaylistAiMoodCard)**:
  - Phân tích cảm xúc âm nhạc chủ đạo của danh sách phát (ví dụ: *"Trầm lắng & Hoài niệm"*).
  - Bộ lọc tâm trạng tùy chỉnh: Các chip chuyển phong cách nghe nhạc ("Mặc định AI", "Bình yên", "Sôi động", "Tập trung").
- **Danh sách bài hát trong Playlist (PlaylistTrackTile)**:
  - Đánh số thứ tự từng bài (`01`, `02`, ...).
  - Tên bài hát, nghệ sĩ, thời lượng, huy hiệu Lossless và tỷ lệ khớp gu âm nhạc `% Match`.
  - Nút menu 3 chấm mở tùy chọn: Thêm vào hàng đợi tiếp theo, Tải bài hát này, Xóa khỏi danh sách.
  - Chạm bài hát bất kỳ để phát và mở trình phát [NowPlayingScreen](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/player/presentations/now_playing_screen.dart).
- **Thanh tìm kiếm giai điệu nổi (PlaylistFloatingHumCapsule)**:
  - Viên thuốc nổi (floating capsule) ở góc dưới cho phép người dùng kích hoạt tìm kiếm bằng giai điệu ngay khi đang duyệt playlist.

---

## 9. Màn Hình Hồ Sơ & Cài Đặt Âm Học (Profile Screen)

*File: [profile_screen.dart](file:///Users/chibao/Documents/Mobile/xmusic/Sonara/lib/modules/profile/presentations/profile_screen.dart)*

### Các tính năng chính:
- **Thẻ hồ sơ người dùng (ProfileHeroCard)**:
  - Avatar đại diện có viền gradient phát sáng nhẹ và icon ngôi sao xác thực.
  - Tên người dùng (ví dụ: *"Lê Hải Đăng"*) kèm tích xanh chứng nhận tài khoản.
  - Huy hiệu thành viên: *"VIP LOSSLESS"* với chấm tín hiệu xanh.
  - Nút *"Chỉnh sửa hồ sơ"* mở trang cập nhật thông tin cá nhân.
  - **Bộ 3 chỉ số âm nhạc**:
    - **480**: Giờ nghe nhạc tích lũy.
    - **142**: Số lần nhận diện giai điệu thành công bằng AI Hum.
    - **68**: Số danh sách phát đã tạo và lưu.
- **Thẻ hiệu ứng âm thanh (AiAcousticEngineCard)**:
  - **Không gian âm thanh 3D (3D Spatial Audio)**: Công tắc bật/tắt giả lập âm thanh vòm 360 độ thích ứng chuyển động.
  - **Tách giọng hát & Nhạc nền (Vocal & Beat Separation)**: Bật chế độ Karaoke tách giọng hát ca sĩ theo thời gian thực.
  - **Độ nhạy nhận diện AI (Hum Sensitivity)**: 3 nấc điều chỉnh độ nhạy micro thu âm (Tiết kiệm 44.1kHz, Tiêu chuẩn 48kHz, Ultra Clean 96kHz / 32-bit).
  - **Chất lượng phát trực tuyến**: Lựa chọn chất lượng stream nhạc (Tiêu chuẩn 320kbps vs Hi-Res FLAC 24-bit / 192kHz).
- **Thiết lập ứng dụng & Thiết bị (PreferencesListCard)**:
  - **Lịch sử nhận diện**: Xem lại toàn bộ 142 bản ghi bài hát đã tìm qua giọng ngân nga.
  - **Thiết bị đã ghép đôi**: Kiểm tra trạng thái tai nghe Bluetooth/AirPlay (ví dụ: *"AirPods Pro 2 • Hi-Fi LDAC"*).
  - **Bộ cân bằng âm thanh (Equalizer)**: Tùy chỉnh EQ 10 băng tần hoặc chọn các preset (Acoustic, Bass Boost, Pop, Vocal).
  - **Chế độ giao diện (App Theme Mode)**: 3 nút lựa chọn chuyển đổi chế độ **Sáng (Warm Ivory)**, **Tối (Dark Onyx)** hoặc **Tự động theo hệ thống**.
  - **Dọn dẹp bộ nhớ đệm (Cache Cleaner)**: Quản lý và giải phóng dung lượng bộ nhớ tạm thời của bài hát.
- **Đăng xuất & Phiên bản**:
  - Nút *"Đăng xuất tài khoản"* an toàn với hộp thoại xác nhận.
  - Footer thông tin ứng dụng: *"Sonara • Phiên bản 1.0.0"*.

---

## 10. Bảng Ma Trận Tính Năng & Trạng Thái Kỹ Thuật (Feature Matrix)

| STT | Phân Hệ Tính Năng | Mô Tả Chức Năng Cốt Lõi | Trạng Thái UI | Trạng Thái Logic / Backend |
| :--- | :--- | :--- | :---: | :---: |
| **1** | **Global Navigation** | 4 Tab chuyển đổi + Nút nổi AI Hum trung tâm + Mini Player ghim đáy | Hoàn thành 100% | BLoC State Navigation sẵn sàng |
| **2** | **Home Discovery** | Hero banner Hum, Mixes cá nhân hóa, Gợi ý theo gu, BXH xu hướng | Hoàn thành 100% | BLoC Mock Data sẵn sàng |
| **3** | **Charts & Leaderboard** | Tab Việt Nam Hot 50 & Quốc Tế Viral, Spotlight Radar, Top 5 xếp hạng, Lưới Mood 2x2 | Hoàn thành 100% | BLoC Mock Data sẵn sàng |
| **4** | **AI Hum-to-Search** | Thu âm microphone, Sóng âm phản hồi, Xoay mẹo ngân nga, Bộ đếm 15s | Hoàn thành 100% | Đã sẵn sàng Service Interface |
| **5** | **Hum Search Results** | Thẻ Best Match Top 1, Snippet Player nghe thử, Các ứng viên tiềm năng, Troubleshooting | Hoàn thành 100% | BLoC State Handling sẵn sàng |
| **6** | **Audio Playback Engine** | Scrubber tua nhạc, Play/Pause/Next/Prev, Shuffle, Repeat, Quản lý ngõ ra âm thanh | Hoàn thành 100% | Tích hợp `just_audio` & `audio_session` |
| **7** | **Synced Lyrics Engine** | Lời bài hát chạy chữ Karaoke theo giây, chạm từng dòng để tua nhạc | Hoàn thành 100% | Cấu trúc dữ liệu `LyricLineModel` sẵn sàng |
| **8** | **Personal Library** | Liked Songs ngoại tuyến, Lịch sử Hum-to-Search, Danh sách Playlist, Nghệ sĩ theo dõi | Hoàn thành 100% | BLoC Mock Data sẵn sàng |
| **9** | **Playlist Details** | Artwork lớn, Smart Shuffle, Tải ngoại tuyến, Bộ lọc cảm xúc AI Mood, Danh sách track | Hoàn thành 100% | BLoC Mock Data sẵn sàng |
| **10**| **Profile & Settings** | Thống kê giờ nghe, Hiệu ứng 3D Spatial & Tách lời, EQ Equalizer, Chế độ Sáng/Tối | Hoàn thành 100% | Tích hợp `shared_preferences` bền vững |
