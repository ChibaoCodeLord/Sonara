# Review và sửa giao diện Sonara Website — 18/10/2026

Đây là báo cáo đợt sửa bố cục ban đầu. Danh mục màn hình, trạng thái lưu dữ liệu và phạm vi mới nhất sau mở rộng nằm trong `UI_SCREEN_CATALOG.md`.

Phạm vi: `Frontend/website`, các trang Khám phá, Bảng xếp hạng, Thư viện, Tìm kiếm, Hồ sơ, Playlist, Nghệ sĩ và các thành phần phát nhạc/overlay dùng chung. Giữ kiểu giao diện tối và màu thương hiệu hiện có.

## Lỗi bố cục chính

Ở viewport 1366×600 trước sửa, vùng nội dung chỉ cao 440px nhưng banner cao 416px, bắt đầu tại y=96 và kết thúc y=512, trong khi thanh phát bắt đầu tại y=504. Vì vậy các section tiếp theo nằm ngoài vùng nhìn đầu tiên. Nội dung vẫn có trong DOM, không phải bị xóa.

Ở viewport 375px trước sửa, sidebar cố định 256px làm vùng nội dung chỉ còn 119px; thanh phát có `scrollWidth=692px` trên màn hình rộng 375px.

Đã sửa:

- Khung ứng dụng dùng `100dvh` với fallback `100vh`; thanh phát có chiều cao riêng và không bị flex co lại.
- Banner giảm cỡ chữ, khoảng cách và phần trang trí theo chiều cao cửa sổ. Ở 1366×600 sau sửa, banner kết thúc khoảng y=365.6, trước thanh phát y=504; tiêu đề và đầu các thẻ Mixes xuất hiện ngay trong vùng nhìn.
- Nội dung chính và danh sách sidebar cuộn được; chuyển trang đưa nội dung về đầu.
- Sidebar thu thành menu ở dưới 1024px, có nút mở/đóng và tự đóng khi chuyển trang hoặc tăng lên desktop.
- Thanh phát đổi thành bố cục hai hàng trên điện thoại; các cột không còn áp đặt tổng chiều rộng vượt màn hình.
- Drawer lời nhạc/hàng đợi chừa thanh phát phía dưới; modal Hum giới hạn chiều cao và cuộn bên trong; artwork toàn màn hình theo cả chiều rộng và chiều cao khả dụng.

## Các lỗi khác đã sửa

| Vấn đề | Kết quả sau sửa |
| --- | --- |
| Tab Nghệ sĩ ở tìm kiếm không áp dụng bộ lọc, kết quả nghệ sĩ không hiển thị | Có nhóm kết quả bài hát/nghệ sĩ đúng tab và điều hướng đến nghệ sĩ |
| Tìm kiếm có dấu/không dấu, khoảng trắng và gõ nhanh | Chuẩn hóa từ khóa khi lọc; giữ chuỗi đang gõ trong state đồng bộ; Enter hoặc chọn gợi ý mới cập nhật URL |
| Chủ đề tìm kiếm lấy từ đầu tiên trong tiêu đề | Mỗi chủ đề có từ khóa thể loại cụ thể |
| Bộ lọc thư viện chỉ đổi giao diện nút | Hiện đúng playlist, bài thích, lịch sử Hum hoặc nghệ sĩ |
| Bài yêu thích/số lượng dùng dữ liệu cố định | Danh sách, số lượng và nút phát dùng `likedSongIds` hiện tại; sidebar chỉ hiện một mục yêu thích |
| Theo dõi nghệ sĩ chỉ tồn tại ở state của một trang | Đồng bộ trạng thái theo dõi giữa trang nghệ sĩ và thư viện trong cùng phiên |
| Route playlist/nghệ sĩ không tồn tại hiển thị dữ liệu của mục đầu tiên | Hiển thị trạng thái không tìm thấy |
| Nút có biểu tượng tạm dừng lại bắt đầu bài từ đầu | Bài/thẻ đang hoạt động gọi đúng thao tác play/pause |
| Phát playlist chỉ phát bài đầu trên hàng đợi cũ | Thiết lập hàng đợi từ danh sách bài của playlist; danh sách rỗng không gây lỗi |
| Danh mục bảng xếp hạng và lựa chọn theo tháng không đổi nội dung | Lọc dữ liệu hoặc hiện trạng thái chưa có dữ liệu phù hợp |
| Bảng quốc tế dùng ID bài Việt khiến bấm nghe phát bài khác | Hiện bảng quốc tế là dữ liệu minh họa, chưa có bản nghe; bỏ thao tác phát/like sai bài |
| Seek ở lời nhạc/toàn màn hình không đồng bộ với audio | Đồng bộ store và thời điểm thật của Audio; scrubber/âm lượng dùng range input hỗ trợ bàn phím |
| Thời gian khởi tạo lấy từ ảnh mẫu, playback thất bại vẫn chạy đồng hồ giả | Bắt đầu tại 0, dùng thời lượng metadata tệp, báo lỗi khi không phát được và dọn Audio khi unmount |
| Next trong repeat-one, kết thúc hàng đợi repeat-off và queue rỗng | Next thủ công vẫn chuyển bài; phát tự động dừng cuối queue khi repeat-off; có bảo vệ queue rỗng |
| Hum bắt đầu ở 7 giây và timeout kết quả còn chạy sau đóng | Bắt đầu 0 giây; dọn timer khi đóng/đổi trạng thái |
| Escape mất tác dụng sau khi nút ghi âm bị thay bằng kết quả | Quản lý focus khi nội dung overlay đổi; Escape đóng overlay trên cùng, Tab có vòng focus và đóng trả focus về vị trí trước |
| Nút thêm hàng đợi trong kết quả Hum lại phát bài | Thêm đúng vào queue và giữ modal mở |
| Nút chia sẻ chỉ hiện thông báo đã sao chép | Sao chép clipboard thật và thông báo lỗi nếu trình duyệt từ chối |
| Điều khiển chỉ xuất hiện khi hover | Có trạng thái focus và hiển thị thao tác trên thiết bị không có hover |
| Import/state/handler bỏ thừa và hoạt ảnh không tôn trọng reduced motion | Dọn mã không dùng, thêm focus outline, nhãn điều khiển và hỗ trợ reduced motion |

## Kiểm chứng

- `npm run lint`: không cảnh báo/lỗi.
- `npm run build`: thành công.
- `npm run test:player`: 6 tình huống trạng thái hàng đợi/phát nhạc thành công.
- `npm run test:ui`: Chrome headless, 64 tổ hợp trang/kích thước và 11 nhóm tương tác; không có lỗi JavaScript runtime được phát ra qua `pageerror`.
- Kích thước kiểm tra: 1920×1080, 1366×768, 1366×600, 1024×768, 768×1024, 375×812, 812×375, 320×568.
- Mỗi kích thước kiểm tra 8 route: `/`, `/charts`, `/library`, `/search?q=Hoang`, `/profile`, `/playlist/playlist_ai_mix_01`, `/artist/artist_vu`, `/playlist/playlist_liked_songs`.
- Kiểm tra không tràn ngang ở main/player/document, không chồng vùng main với player, player nằm trong viewport và cuộn đến được cuối nội dung.
- Kiểm tra nhập nhanh, lọc/nghệ sĩ, yêu thích, theo dõi, category chart, route lỗi, menu mobile/resize, seek Audio từ lời nhạc và bàn phím, Escape, Hum đóng/mở lại, thêm hàng đợi và reduced motion.
- Đã xem ảnh chụp desktop 1366×600/768, trang chủ điện thoại, hồ sơ màn hình nhỏ và kết quả Hum trên điện thoại. Đây là kiểm tra viewport trong Chrome headless, không phải kiểm chứng trực tiếp phím F11/zoom của cửa sổ Edge đang mở trên máy người dùng.

Bằng chứng và ảnh nằm tại:

`C:/Users/ADMIN/.codex/visualizations/2026/10/18/01a14f19-bc5d-7c01-ac30-bc6f3d8e7cfa/`

- `ui-review-results.json`: dữ liệu đo và các luồng kiểm tra.
- `before-1366.png`, `home-1366x600.png`, `home-1366x768.png`: ảnh trước/sau.
- `home-*.png`, `profile-*.png`, `hum-results-mobile.png`: ảnh các kích thước khác.
- `website-before-ui-fix.zip`: bản sao mã nguồn trước sửa; đã kiểm tra tính toàn vẹn ZIP. SHA-256: `D6D4B993F713AE458C64924E076065E023A5A74C018CAA754905B52BD48EB9FD`.

## Giới hạn còn lại

Website đang dùng catalog/hồ sơ/lịch sử và kết quả Hum mẫu trong `src/data`. Hum chưa gọi backend nhận diện; mô phỏng đoạn khớp không phát âm thanh. Spatial 3D/Karaoke và các thông số chất lượng chưa có pipeline xử lý âm thanh thực. Các tính năng tài khoản, tải ngoại tuyến và tạo playlist chưa được triển khai đầy đủ; sửa giao diện không xác nhận các dịch vụ này đã hoạt động.

Các tệp audio hiện có là bản mẫu; thời lượng thật có thể ngắn hơn thời lượng mô tả trong catalog. Yêu thích và theo dõi đồng bộ trong phiên, chưa lưu lâu dài qua backend. Ảnh/font từ bên ngoài vẫn cần kết nối mạng. Chưa kiểm tra thiết bị vật lý hoặc Safari/Firefox.

## Chạy lại

Tại `Frontend/website`: `npm run dev`, mở địa chỉ Vite in ra, nhấn `Ctrl+0` để về zoom 100% rồi `Ctrl+F5` nếu trình duyệt đang giữ phiên cũ. Các section dài tiếp tục truy cập bằng cuộn trong vùng nội dung chính.

`npm run test:ui` cần Playwright và Chrome đã có trên máy. Có thể truyền `PLAYWRIGHT_MODULE`, `UI_BROWSER` và `UI_REVIEW_OUTPUT` như hướng dẫn trong README. `npm run test:player` không cần trình duyệt.
