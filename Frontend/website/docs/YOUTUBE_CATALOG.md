# Catalog và phát audio

Trang **Nghe nhạc** (`/youtube`) hợp nhất dữ liệu Internet Archive, Audius và MusicBrainz cùng danh sách video đã tuyển chọn. Catalog tham gia tìm kiếm, chi tiết bài, hàng đợi, yêu thích, lịch sử và playlist. Sidebar giữ ba mục chính; các nguồn nằm trong bộ lọc trên trang Nghe nhạc.

Ứng dụng dùng HTML Audio. Internet Archive/Audius cung cấp URL audio trực tiếp; bài từ YouTube được chuẩn bị thành MP3 khi chọn phát, có trạng thái tiến độ, lỗi và thử lại. Component iframe YouTube cũ và các probe tương ứng đã được loại bỏ. Không suy ra rằng một video phát được chỉ vì lấy được metadata.

## Dữ liệu và cấu hình

- `src/data/youtubeCatalog.json`: metadata nguồn và kết quả kiểm tra lịch sử của 32 video, gồm nguồn, kênh, thời điểm lấy và thời lượng nếu đã xác định. Trạng thái nhúng lưu lại chỉ là dữ liệu lịch sử; luồng audio hiện tại xử lý tại `utils/audioCatalog.js`.
- `scripts/youtube-seeds.json`: danh sách video và thông tin biên tập Việt/quốc tế.
- `src/data/youtubeCatalog.js`: ánh xạ metadata và hai playlist tuyển chọn. Giữ ID để playlist đã lưu tiếp tục hoạt động.
- Catalog từ MongoDB được tải qua `/api/v1/catalog`; thông tin giấy phép Archive hiển thị trên card và trang chi tiết.

Chạy backend bằng `npm start` trong `Backend`, website bằng `npm run dev` trong `Frontend/website`. Cách nhập thêm dữ liệu, giới hạn nguồn và cache audio: [AUDIO_CATALOG.md](../../../Backend/AUDIO_CATALOG.md), [ARCHIVE_CATALOG.md](../../../Backend/ARCHIVE_CATALOG.md).

## Cập nhật metadata video

Trong `Frontend/website`:

```powershell
npm run catalog:youtube
```

Script lấy oEmbed cho danh sách seed, kiểm tra ID/hostname/tên kênh, giữ metadata cũ khi lỗi mạng tạm thời. Không tự động crawl định kỳ và không chứa API secret phía frontend.

## Kiểm thử

```powershell
npm test
npm run lint
npm run build
# Cần Playwright/Chrome và backend với dữ liệu đã nhập:
npm run test:audio:ui
npm run test:archive:ui
```

Các bộ kiểm thử nằm trong `tests/`; `scripts/` chỉ chứa đồng bộ catalog và seed. Test audio UI sử dụng tệp MP3/stream thực; ca lỗi API chuyển đổi được giả lập riêng và có ghi rõ trong báo cáo. Không dùng fixture để kết luận mọi bài trên nguồn đều phát được. `PLAYWRIGHT_MODULE` có thể trỏ đến module Playwright đã cài; `UI_AUDIO_OUTPUT`/`UI_ARCHIVE_OUTPUT` chọn nơi lưu báo cáo bên ngoài repo.
