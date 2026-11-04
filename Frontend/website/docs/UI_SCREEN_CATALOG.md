# Các màn hình Sonara Web đã bổ sung

Skill: `ui-ux-pro-max`, áp dụng Dark Mode (OLED), semantic controls, focus/keyboard, reduced motion và bố cục responsive. Giữ màu ruby, Plus Jakarta Sans / Inter của Sonara. Quy tắc chung: `design-system/sonara/MASTER.md`.

## Trang và đường dẫn

| Nhóm | Đường dẫn / điểm vào | Trạng thái giao diện |
| --- | --- | --- |
| Chào mừng / khách | `/welcome`, trang chủ khi chưa đăng nhập | CTA đăng ký, đăng nhập, tiếp tục khách; nút tạo playlist mở lời mời đăng nhập |
| Đăng nhập | `/login` | Form có nhãn, hiện/ẩn mật khẩu, lỗi nhập liệu, điều hướng về trang trước; tạo phiên demo cục bộ |
| Đăng ký | `/signup` | Tên, email, mật khẩu mẫu, checkbox xác nhận trải nghiệm |
| Quên / đặt lại mật khẩu | `/forgot-password`, `/reset-password` | Form và kết quả mẫu; không giả thông báo đã gửi email hoặc đã đổi mật khẩu máy chủ |
| Album | `/album/album_bau_troi_moi` | Artwork, thông tin, tracklist, phát album, lưu/bỏ lưu và đề xuất khám phá |
| Bài hát / credits | `/track/song_bau_troi_moi` | Thông tin bài, lời, nghệ sĩ, album và thông báo nếu chưa có metadata credits |
| Thể loại | `/browse`, `/category/indie` | Thẻ chủ đề, bài hát và playlist liên quan |
| Bộ sưu tập | `/collection/mixes`, `/collection/albums`, `/collection/artists`, `/collection/recommended`, `/collection/trending` | Trang Xem tất cả đúng nhóm nội dung |
| Thư viện | `/library` | Bộ lọc, tìm kiếm, sort, lưới/danh sách, album, nghệ sĩ, podcast, tập lưu và thư mục playlist |
| Playlist | `/playlist/:id` | Tạo/sửa/xóa, thêm/xóa bài, tìm trong playlist, đổi thứ tự, công khai/riêng tư, bản sao và chuyển vào thư mục |
| Lịch sử | `/history` | Ghi khi Audio thực sự bắt đầu phát; hiển thị thời gian; xác nhận xóa lịch sử |
| Chuỗi nghe nhạc | `/activity`, `/profile` | Lịch năm kiểu GitHub, chuỗi hiện tại/dài nhất và mục tiêu nghe thực 30 giây/ngày |
| YouTube → MP3 | `/import` | Dán URL, chuyển MP3 thật qua dịch vụ media cục bộ, tiến trình/hủy/thử lại, phát và quản lý MP3 |
| Catalog YouTube thật | `/youtube`, hai playlist YouTube, `/track/yt_:id` | Metadata nguồn thật, bộ lọc Việt/quốc tế, trình nhúng đồng bộ player, link nguồn cho video chặn nhúng; truy cập từ Trang chủ/Tìm kiếm |
| Hồ sơ / âm học | `/profile` | Dữ liệu hồ sơ, số liệu theo dữ liệu trải nghiệm, chỉnh sửa và các công tắc âm học mẫu |
| Hồ sơ công khai | `/user/me`, `/user/sonara`, `/user/minh-anh` | Playlist công khai, follow và giao diện danh sách người theo dõi; me yêu cầu phiên demo và tôn trọng cài đặt hiển thị |
| Cài đặt | `/settings?tab=account`, `playback`, `privacy`, `notifications`, `billing` | Hồ sơ, ngôn ngữ hiện có, lựa chọn phát/riêng tư/thông báo, quản lý gói mẫu |
| Premium | `/premium` | Thẻ so sánh các gói Sonara minh họa và FAQ |
| Thanh toán | `/checkout?plan=individual` | Chọn phương thức mẫu, xác nhận và xem kết quả thành công/thất bại; không nhập thông tin thẻ thật |
| Kết quả thanh toán | `/checkout/result?status=success&plan=individual` | Trạng thái thành công/thất bại, thử lại, mở gói; có ghi rõ mô phỏng |
| Thông báo | `/notifications`, nút chuông | Bảng xem nhanh, danh sách, đánh dấu đã đọc và điều hướng nội dung |
| Podcast | `/podcasts`, `/show/cham-mot-nhip` | Khám phá chương trình, theo dõi và danh sách tập |
| Tập podcast | `/episode/ep-lang-nghe` | Chi tiết, lưu tập, tiến trình, tốc độ và tiếp tục mô phỏng; không phát audio |
| Trợ giúp / dữ liệu | `/help`, `/legal/privacy`, `/legal/terms` | Hướng dẫn, FAQ và mô tả lưu dữ liệu frontend |
| Không tìm thấy | URL không hợp lệ | Empty state và nút về khám phá thay vì âm thầm mở mục đầu tiên |

## Thành phần dùng chung và hộp thoại

- Avatar → menu tài khoản: hồ sơ, hồ sơ công khai, cài đặt, Premium, trợ giúp, đăng xuất có xác nhận.
- Menu `…` bài hát: phát, yêu thích, thêm queue, chọn playlist, mở album/nghệ sĩ/chi tiết, chia sẻ; xóa khỏi playlist khi là chủ sở hữu.
- Tạo/sửa playlist: tên, mô tả, ảnh upload JPG/PNG/WebP tối đa 300 KB.
- Hộp chọn playlist: tìm, tạo mới, báo bài đã tồn tại.
- Playlist của bạn: thêm bài, nút đổi thứ tự lên/xuống, xác nhận xóa, quyền hiển thị, chọn thư mục.
- Hàng đợi: kéo thả, nút lên/xuống thay cho kéo, xóa từng bài, xác nhận xóa queue và giữ bài đang phát.
- Thiết bị: trình duyệt hiện tại, thao tác tìm thiết bị và empty state trung thực khi chưa có dịch vụ kết nối.
- Loading skeleton, empty states, boundary lỗi có tải lại, banner ngoại tuyến và thông báo khi bộ nhớ không lưu được.
- Modal giới hạn chiều cao, cuộn bên trong; Tab/Escape và khôi phục focus hoạt động trên overlay trên cùng.

## Các trạng thái AI Hum

1. Giới thiệu và xin quyền trước khi mở micro.
2. Đang chờ quyền; chỉ chạy bộ đếm khi đã mở micro thành công.
3. Thu âm / sóng âm trực tiếp; tự dừng sau 15 giây.
4. Micro bị từ chối, không tìm thấy hoặc không mở được: giải thích và thao tác thử lại.
5. Không có tín hiệu: nhắc kiểm tra micro và thu lại; không trả một kết quả nhận diện giả.
6. Kết quả minh họa, thêm queue, thích bài và phát tệp nhạc mẫu.
7. Không đúng bài / chưa có kết quả phù hợp: thu lại hoặc chuyển tìm kiếm chữ.

Kết quả nhận diện vẫn là dữ liệu mẫu. Âm thanh micro hiện chỉ phục vụ visualizer trên máy, không được gửi tới API nhận diện.

## Kiểm thử và ảnh

- `npm run lint`, `npm run build`.
- `npm run test:player`: 6 tình huống trạng thái phát nhạc.
- `npm run test:workspace`: 10 nhóm CRUD playlist, bản sao, thứ tự, bảo vệ tuyển tập, history, saved items, sửa queue và đăng xuất.
- `npm run test:screens`: 37 URL trên 7 kích thước; 19 nhóm tương tác gồm tạo/sửa playlist, lưu sau reload, thư mục, album, hồ sơ, thanh toán mẫu, podcast, micro và mobile navigation.
- `npm run test:ui`: kiểm tra hồi quy những luồng player, tìm kiếm, thư viện và responsive ban đầu. Có thể đặt `UI_INTERACTIONS_ONLY=1` khi chỉ muốn chạy các tương tác.

Kích thước của bộ kiểm thử màn hình: 1440×900, 1366×600, 1024×768, 768×1024, 375×812, 320×568, 812×375. File `screen-results.json` chứa kết quả đo và cờ `passed`; chỉ dùng một lượt có `passed: true` làm bằng chứng hoàn tất.

Kết quả bàn giao: bản production đã qua **259 tổ hợp URL/kích thước, 19 nhóm tương tác**, không ghi nhận `pageerror`. Bộ hồi quy cũ qua **11 nhóm tương tác**, gồm seek Audio thật và fullscreen. Lint không cảnh báo/lỗi; build thành công; các bộ kiểm thử trạng thái player/workspace đều qua. Có kiểm tra riêng vị trí phát khi hàng đợi chứa bài trùng lặp.

Ảnh và kết quả tại:

`C:/Users/ADMIN/.codex/visualizations/2026/10/18/01a14f19-bc5d-7c01-ac30-bc6f3d8e7cfa/screens/`

Ảnh tiêu biểu: `login-1440.png`, `library-1440.png`, `premium-1440.png`, `album-album_bau_troi_moi-1440.png`, các bản `-375.png`, `hum-320.png`. Bản sao trước mở rộng: `website-before-screen-expansion.zip` trong thư mục cha. Báo cáo hồi quy nằm trong `regression/` ở thư mục cha.

Bản sao trước mở rộng đã kiểm tra tính toàn vẹn ZIP, gồm 46 entry. SHA-256: `4A0AA9AE59A519BF3BCFE256BA8CD6B5B8DF665A4B8036492761CA9DC4E4FD47`.

## Giới hạn dịch vụ

Đã triển khai giao diện và trạng thái frontend, chưa triển khai backend mới. Xác thực, email khôi phục, thanh toán, Spotify Connect tương đương, nhận diện Hum, Spatial 3D/Karaoke và phát audio podcast chưa là dịch vụ thực tế. Các quyền lợi/giá Premium, danh sách người theo dõi, thông báo và catalog là dữ liệu minh họa, không phải tuyên bố dịch vụ đang cung cấp.

Playlist, hồ sơ, cài đặt và dữ liệu thư viện lưu ở trình duyệt. Không lưu mật khẩu. Đăng xuất đóng phiên demo nhưng giữ dữ liệu trên máy, không bảo đảm an ninh như đăng nhập qua máy chủ. Ảnh/font bên ngoài cần kết nối; khi thay thiết bị hoặc xóa dữ liệu trình duyệt chưa có đồng bộ/khôi phục từ server.

## Điều hướng rút gọn

Sidebar chỉ giữ **Trang chủ, Tìm kiếm, Thư viện** và danh sách playlist/yêu thích. Tạo playlist vẫn có nút cộng ngay trong khu vực playlist. Hồ sơ/tài khoản nằm ở menu avatar góc trên phải.

- **Thư viện → Nhập nhạc**: YouTube → MP3.
- **Thư viện → Nghe gần đây / Chuỗi nghe nhạc**: lịch sử và lịch hoạt động; Hồ sơ cũng có lịch và liên kết Chuỗi nghe nhạc.
- **Tìm kiếm → Khám phá thể loại & tâm trạng / Khám phá podcast / Bảng xếp hạng**: các trang khám phá phụ. Trang chủ vẫn có liên kết đến bảng xếp hạng.
- AI Hum mở bằng micro trong thanh tìm kiếm hoặc hero trang chủ; bỏ banner trùng lặp khỏi sidebar.

Cách nhóm thư viện theo nội dung đã lưu tham khảo [Your Library của Spotify](https://support.spotify.com/uk/article/your-library/), giữ màu và tính năng riêng của Sonara.

Đã xác minh sau khi rút gọn sidebar: lint/build đạt; 273 tổ hợp bố cục (39 URL × 7 kích thước), 22 nhóm thao tác, không lỗi JavaScript. Có kiểm tra đường đi mới từ Thư viện/Tìm kiếm và playlist trong menu ngang 812 × 375.
