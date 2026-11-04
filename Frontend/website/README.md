# Sonara Website

Giao diện nghe nhạc React + Vite + Tailwind. Chạy tại thư mục `Frontend/website`:

Giao diện có chế độ **Sáng / Tối / Theo hệ thống**. Dùng nút mặt trời/mặt trăng trên thanh đầu trang để đổi nhanh, hoặc vào **Cài đặt → Giao diện** (`/settings?tab=appearance`). Lựa chọn được lưu riêng tại `sonara-theme` trên trình duyệt; mặc định theo hệ thống. Màn hình đăng nhập cũng có nút chuyển. `npm run test:theme:ui` kiểm tra lựa chọn, đồng bộ tab, bảng màu và responsive bằng Chrome/Playwright.

```powershell
npm ci
npm run dev
```

Mở địa chỉ Vite in ra trong terminal. Nếu cổng 5173 đang được dùng, Vite sẽ chọn cổng tiếp theo.

Kiểm tra mã và đóng gói:

```powershell
npm run lint
npm run test:player
npm run test:workspace
npm run test:listening
npm run build
```

Kiểm tra trình duyệt: `npm run test:screens` cho các màn hình mới và `npm run test:ui` cho hồi quy player/responsive ban đầu. Cần Playwright và Chrome có sẵn trên máy; có thể đặt `PLAYWRIGHT_MODULE` thành đường dẫn module Playwright, `UI_BROWSER` thành `chrome` hoặc `msedge`. `UI_SCREENS_OUTPUT` chọn thư mục ảnh/báo cáo màn hình mới; `UI_REVIEW_OUTPUT` chọn thư mục hồi quy. Script tự chạy server kiểm thử cổng 5201 hoặc 5198 rồi đóng server khi xong.

`test:screens` tự build rồi chạy Vite preview để kiểm tra đúng gói production; `test:ui` dùng dev server cho các kiểm tra Audio/store chi tiết.

Trang mới gồm đăng nhập/đăng ký/khôi phục mật khẩu, album, bài hát, thể loại, bộ sưu tập, lịch sử nghe, hồ sơ công khai, cài đặt, Premium/checkout, thông báo, podcast và trợ giúp. Có luồng tạo/sửa/xóa playlist, thêm/xóa/đổi thứ tự bài, thư mục, menu tài khoản/bài hát và quản lý hàng đợi.

Catalog kết hợp dữ liệu thật từ MongoDB (Internet Archive, Audius, MusicBrainz) và dữ liệu mẫu trong `src/data`. Kết quả AI Hum hiện dùng dữ liệu mẫu. Hum chưa gọi API nhận diện; cài đặt âm học chưa xử lý âm thanh thực. Đăng nhập và thanh toán là luồng trải nghiệm, không xác minh mật khẩu hoặc xử lý giao dịch. Không dùng mật khẩu/thông tin thẻ thật. Podcast có trình phát mô phỏng, chưa có audio thực.

Playlist, hồ sơ, mục đã lưu, yêu thích, theo dõi, lịch sử và cài đặt lưu trên trình duyệt khi bộ nhớ cho phép. Không lưu mật khẩu. Nếu bộ nhớ bị chặn/đầy, trạng thái tiếp tục trong phiên và giao diện thông báo không lưu được. Chưa có đồng bộ tài khoản qua máy chủ. Audio phát bằng HTML Audio từ nguồn trực tiếp, MP3 đã chuẩn bị hoặc tệp mẫu trong `public/audio`.

Chi tiết sửa lỗi và phạm vi kiểm tra: `docs/UI_REVIEW.md`.

Danh mục giao diện và hướng dẫn chạy các luồng mới: `docs/UI_SCREEN_CATALOG.md`. Quy tắc giao diện áp dụng từ skill `ui-ux-pro-max`: `design-system/sonara/MASTER.md`.

Mới: **Chuỗi nghe nhạc** (`/activity`, `/profile`) tính hoạt động từ Audio thực phát đủ 30 giây/ngày. **YouTube → MP3** (`/import`) dùng yt-dlp + FFmpeg thật; chạy thêm `npm run media` trong `Backend`. Hướng dẫn cấu hình, giới hạn lưu trữ và kiểm thử: [LISTENING_AND_YOUTUBE.md](docs/LISTENING_AND_YOUTUBE.md).

**Nghe nhạc** (`/youtube`, truy cập qua Trang chủ/Tìm kiếm): lọc nguồn Internet Archive/Audius/MusicBrainz, metadata video đã tuyển chọn và phát audio trên cùng thanh điều khiển. Cách cập nhật dữ liệu và kiểm thử: [YOUTUBE_CATALOG.md](docs/YOUTUBE_CATALOG.md).

Mã kiểm thử nằm trong `tests/`; `scripts/` chỉ giữ đồng bộ metadata và seed. `npm test` chạy các kiểm thử logic; kiểm thử UI/phát thật là các lệnh riêng.
