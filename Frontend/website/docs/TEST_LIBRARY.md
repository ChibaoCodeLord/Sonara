# Dữ liệu test thư viện cá nhân

Đăng nhập bản trải nghiệm với email `quocdat19991712@gmail.com`, rồi mở `/library`. Phiên đã đăng nhập chỉ cần tải lại trang. Backend catalog phải đang chạy để tải các bản thu thật.

Bộ dữ liệu tự thêm một lần khi catalog tải xong và có ít nhất 24 bản thu audio đầy đủ:

- 4 playlist, mỗi playlist 12 bài: V-Pop yêu thích, Chill cuối ngày, Cà phê sáng, Nạp năng lượng.
- 24 bài yêu thích, tối đa 5 album và 6 nghệ sĩ lấy từ catalog hiện tại.
- 2 thư mục và 15 mục lịch sử nghe mô phỏng, có ghi chú trên giao diện. Lịch sử mẫu không tạo chuỗi nghe nhạc.

Playlist và các mục đã lưu trước đó được giữ lại. Sau khi sửa, xóa hoặc bỏ thích, tải lại trang không thêm lại dữ liệu mẫu. Email khác không được thêm bộ mẫu này. Các thư viện được giữ riêng theo email trong cùng trình duyệt khi đăng xuất/đăng nhập lại.

Đây là dữ liệu cho luồng đăng nhập trải nghiệm hiện có, lưu trong localStorage (`sonara-workspace-v1`, `sonara-library-v1`). Chưa tạo tài khoản hay ghi thư viện người dùng vào MongoDB; chưa đồng bộ giữa trình duyệt hoặc thiết bị. Xóa dữ liệu website sẽ làm mất thư viện local và bộ mẫu sẽ được tạo lại ở lần đăng nhập tiếp theo.

Kiểm tra: `npm test`, `npm run lint`, `npm run build`. Khi backend catalog đang chạy, `npm run test:library:ui` kiểm tra bằng Chrome trong phiên test riêng. Đặt `PLAYWRIGHT_MODULE` nếu Playwright nằm ngoài node_modules của website. Kết quả UI mặc định ở `ui-review-artifacts/test-library`.
