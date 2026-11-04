# Ảnh thể loại và tâm trạng

Sáu ảnh minh họa được tạo bằng công cụ **image_gen tích hợp**, dùng cho các thẻ trên `/search` và `/browse`. Đây là ảnh minh họa AI cho thể loại; không phải ảnh xác nhận một nghệ sĩ, bản thu hoặc sự kiện có thật.

File sử dụng trong website:

| File trong `public/images/genres/` | Chủ đề |
| --- | --- |
| `mood.webp` | Tâm trạng & Cảm xúc / R&B & Soul |
| `relax.webp` | Thư giãn & Indie / Chậm lại một chút |
| `workout.webp` | Tập luyện / Nạp năng lượng |
| `cafe.webp` | Quán Cafe Cuối Tuần / Acoustic |
| `vpop.webp` | V-Pop |
| `acoustic.webp` | Indie Việt & Mộc |

Tổng dung lượng 716.362 byte, WebP quality 84. PNG gốc được giữ trong thư mục generated_images của Codex, không đặt bản trùng trong repo. Ảnh có kích thước khai báo, lazy loading, lớp phủ cố định giúp chữ trắng dễ đọc ở cả hai theme. Nếu ảnh tải lỗi, thẻ giữ nền gradient, nhãn và hành động. `CategoryCard` dùng button cho tìm kiếm và Link cho điều hướng; ảnh trang trí có alt rỗng vì tên thể loại đã là nhãn điều khiển.

## Prompt đã dùng

Mỗi ảnh dùng prompt riêng theo mẫu sau, thay `SCENE` bằng một dòng tương ứng phía dưới:

```text
Create one square photographic category-cover asset for a Vietnamese music listening website, SCENE Editorial music photography with realistic texture, cinematic soft light and rich natural colors. Strong simple composition readable at 200px. Main visual subject in upper two thirds, bottom quarter visually calm and darker for a separately rendered white category label. No typography, no text, no letters, no watermarks, no logos, no UI, no album sleeve frame. This is a decorative category illustration, not documentation of a real artist or real album.
```

- **mood:** A candid close portrait of a young Vietnamese woman wearing over-ear headphones by a rain-streaked apartment window at blue hour, quietly reflecting, burgundy sweater, pink city bokeh, wistful emotional music mood.
- **relax:** A serene Vietnamese lakeside at dawn, a solitary wooden pier, misty blue mountains, lavender sky, a tiny figure sitting quietly on the pier listening to headphones, peaceful spacious indie chill feeling.
- **workout:** Dynamic athletic runner on a red outdoor running track at sunrise, low angle close-up of running shoes and legs in motion, warm amber rim lighting, bold energetic diagonal composition, no visible brands.
- **cafe:** A warm intimate Vietnamese coffee shop interior at golden hour, a ceramic coffee cup on a wooden table beside a softly lit window, blurred vinyl records and plants in the background, cozy amber and espresso tones.
- **vpop:** An electric live music concert stage in Vietnam, a generic singer silhouette far away with bright magenta and crimson stage beams and excited crowd silhouettes below, vivid modern pop energy, no recognizable performer.
- **acoustic:** Close-up of an unbranded wooden acoustic guitar being gently played by a young Vietnamese musician, cropped hands and guitar body with soft green foliage and warm sunlight in a small garden, authentic intimate indie folk mood.

## Kiểm tra

`npm run test:categories:ui` dùng Chrome/Playwright để kiểm tra tải đủ ảnh, nhãn, thao tác chuột/bàn phím, link thể loại, ảnh lỗi và 20 tổ hợp trang/theme/kích thước (320–1920px). Catalog API trong phép thử dùng fixture rỗng để kiểm tra giao diện độc lập với dữ liệu bài hát. Lưu ảnh/báo cáo bằng biến `UI_CATEGORY_OUTPUT` để tránh sinh file thử nghiệm trong source.
