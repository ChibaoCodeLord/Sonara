# Chuỗi nghe nhạc và YouTube → MP3

## Chạy ứng dụng

Mở hai terminal PowerShell:

```powershell
cd E:\HOCKY7\PBL6\SORANA-CODE\Sonara\Backend
npm run media
```

```powershell
cd E:\HOCKY7\PBL6\SORANA-CODE\Sonara\Frontend\website
npm run dev
```

Dịch vụ media nghe tại `127.0.0.1:5001`, độc lập với API MongoDB cổng 5000. Vite chuyển tiếp `/media-api` sang dịch vụ này, cả dev và preview. Giữ hai terminal chạy khi sử dụng MP3. Máy cần Node, `yt-dlp`, FFmpeg/ffprobe trong PATH; không cần cài thư viện Node mới. Nếu công cụ chưa nằm trong PATH, đặt `YTDLP_PATH` và `FFMPEG_PATH` thành đường dẫn executable trong `Backend/.env` (xem `.env.example`). Không nhập cookie YouTube hoặc thông tin đăng nhập vào ứng dụng.

Nếu Vite dùng cổng khác 5173/4173, thêm origin tương ứng vào `MEDIA_ORIGINS` trong `Backend/.env`. Proxy cho máy chủ media khác có thể đặt bằng biến môi trường `MEDIA_API_TARGET` khi chạy Vite. Giữ dịch vụ cục bộ; đây chưa phải dịch vụ chuyển đổi công khai có xác thực/phân quyền tài khoản. Triển khai web production cần reverse proxy `/media-api` về dịch vụ media và cấu hình origin phù hợp.

## Chuỗi nghe nhạc

- Điểm vào **Thư viện → Chuỗi nghe nhạc** (`/activity`), cũng xuất hiện trong **Hồ sơ** (`/profile`).
- Đạt một ngày khi âm thanh thực phát đủ **30 giây**, cộng dồn qua nhiều bài và lần nghe trong ngày. Không suy ra hoạt động từ thao tác nhấn Play hoặc dữ liệu lịch sử cũ.
- Lấy mẫu đồng hồ và thời gian Audio. Tua, tạm dừng, buffering và khoảng treo timer dài không được cộng; chia thời gian qua nửa đêm theo múi giờ thiết bị.
- Lịch cả năm kiểu GitHub, năm nhuận, chọn năm, cường độ 5 mức theo giây/phút nghe. Dữ liệu tương lai để trống. Có nhãn ngày/giá trị, phím mũi tên và bảng dữ liệu thay cho việc chỉ đọc màu.
- Chuỗi hiện tại tính đến hôm nay, hoặc hôm qua nếu hôm nay chưa đủ thời gian. Khi bỏ lỡ một ngày trọn vẹn, chuỗi hiện tại về 0; chuỗi dài nhất vẫn giữ.
- Lưu trong `sonara-workspace-v1` trên trình duyệt. Chưa đồng bộ theo tài khoản qua backend; các phiên demo trên cùng trình duyệt dùng chung dữ liệu này. Xóa lịch sử bài không xóa thống kê hoạt động.

## YouTube → MP3

- Điểm vào **Thư viện → Nhập nhạc** (`/import`). Dán một video HTTPS từ youtube.com/youtu.be/Shorts, rồi chuyển đổi.
- Máy chủ lấy thông tin bằng yt-dlp, kiểm tra thời lượng/livestream, tải audio và chuyển MP3 **192 kbps** bằng FFmpeg. Có trạng thái đọc metadata, tải, chuyển đổi, sẵn sàng, thất bại, hủy và thử lại. Tiến trình phần trăm là tải; bước mã hóa hiển thị riêng.
- Chỉ một video mỗi tác vụ, tối đa 30 phút/100 MB; tối đa hai tác vụ đồng thời và 30 MP3. Không hỗ trợ playlist, livestream, video riêng tư, DRM hoặc video cần đăng nhập. YouTube có thể chặn một số video/yêu cầu; UI không giả báo thành công.
- Tệp lưu tại `Backend/temp/media-library/<UUID>/audio.mp3`. Manifest giúp phục hồi sau khi khởi động lại; tác vụ đang chạy lúc dịch vụ dừng sẽ báo thất bại để thử lại.
- Danh sách MP3, ID tác vụ chờ và metadata lưu trên trình duyệt. Chuyển sang trang khác vẫn đồng bộ tác vụ chờ; tải lại trang tiếp tục kiểm tra. Không tự phát khi chuyển đổi xong, bấm **Nghe ngay** để phát.
- Bài nhập dùng chung trình phát, tua, hàng đợi, yêu thích, tìm kiếm, lịch sử, trang chi tiết và playlist. Nguồn được ghi là YouTube; không gắn nhãn Lossless. Playlist vẫn dùng cơ chế đăng nhập demo hiện có.
- Xóa MP3 có bước xác nhận, xóa tệp trên dịch vụ và gỡ bài khỏi hàng đợi/yêu thích/playlist/lịch sử của trình duyệt hiện tại. Các trình duyệt khác đang giữ metadata của cùng tệp cần xóa mục cũ nếu tệp đã bị xóa.
- URL đầu vào được chuẩn hóa về ID video; không chuyển URL tùy ý vào downloader. Chạy tiến trình bằng mảng tham số, không qua shell; không đọc cấu hình/plugin yt-dlp của người dùng. API mutation yêu cầu header ứng dụng và kiểm tra origin. Dịch vụ bind loopback.

## Kiểm tra

```powershell
# Frontend/website
npm run lint
npm run test:listening
npm run test:player
npm run test:workspace
npm run build
npm run test:screens
# Cần Playwright/Chrome và FFmpeg, script tự tạo/xóa thư mục kiểm thử
node tests/test-listening-ui.cjs

# Backend
npm run test:media
# Kiểm tra tải thật qua UI bằng bộ kiểm thử hiện có:
# $env:UI_LIVE_YOUTUBE='1'; npm run test:listening:ui  (chạy tại Frontend/website)
```

`test-media` phân biệt runner giả lập cho lifecycle/API với bài kiểm tra FFmpeg mã hóa/giải mã thật. `test-listening-ui` mặc định dùng metadata kiểm thử và FFmpeg thật; đặt `UI_LIVE_YOUTUBE=1` để kiểm tra tải YouTube thật qua giao diện. Có thể đặt `PLAYWRIGHT_MODULE` đến module đã cài, `UI_MEDIA_OUTPUT` chọn thư mục báo cáo/ảnh. Kiểm tra UI dùng cổng 5205 và dịch vụ media cổng tạm, không ghi dữ liệu vào thư viện người dùng.

Tham khảo công cụ: [tài liệu yt-dlp](https://github.com/yt-dlp/yt-dlp#usage-and-options), [video fixture 5 giây của yt-dlp](https://github.com/yt-dlp/yt-dlp/blob/master/yt_dlp/extractor/youtube/_video.py).

## Kết quả xác minh ngày 18/10/2026

- Lint sạch, build production thành công.
- 7 bài kiểm tra logic ngày/chuỗi, URL và tích hợp store; 6 kịch bản player và 10 nhóm workspace cũ đạt.
- 7 bài kiểm tra backend đạt: URL, lifecycle/HTTP Range/khởi động lại/xóa, video quá dài, thiếu công cụ, giới hạn đồng thời/hủy, FFmpeg mã hóa/giải mã thật và hủy tiến trình thật trên Windows.
- Hồi quy 39 URL × 7 kích thước = 273 tổ hợp bố cục, 19 nhóm thao tác cũ, không lỗi JavaScript.
- Bộ kiểm tra mới chạy `UI_LIVE_YOUTUBE=1`: 22 nhóm thao tác, 21 tổ hợp bố cục `/activity`, `/import`, `/profile`, không lỗi JavaScript. Đã nghe audio thật đủ 30 giây và xác minh không cộng khi pause; đã tải/chuyển video YouTube fixture `gHKT4uU8Zng` thành MP3 thật, phát/tua và đưa vào playlist. Các ca UI lỗi/hủy dùng phản hồi fixture có ghi rõ trong báo cáo; bài backend kiểm tra hủy tiến trình thật riêng.
- Probe độc lập cũng tải video trên và giải mã MP3 bằng FFmpeg thành công. Video fixture cũ `BaW_jenozKc` hiện báo không khả dụng; ứng dụng trả trạng thái thất bại đúng. Một video kiểm thử thành công không đảm bảo mọi video YouTube đều tải được.
