# Sonara - Nền Tảng Âm Nhạc Trực Tuyến & Nhận Diện Giai Điệu AI

> Dự án đồ án / hệ thống streaming âm nhạc đa nền tảng kết hợp công nghệ AI Hum-to-Search (tìm kiếm bài hát qua giọng ngân nga / huýt sáo).

---

## 📁 Cấu Trúc Dự Án (Repository Structure)

Dự án được tổ chức theo mô hình phân tách rõ ràng giữa Frontend và Backend:

```text
Sonara/
├── Frontend/                 # Ứng dụng client đa nền tảng viết bằng Flutter (Dart)
│   ├── lib/                  # Toàn bộ mã nguồn giao diện & BLoC state management
│   ├── assets/               # Hình ảnh và tài nguyên tĩnh
│   ├── pubspec.yaml          # Quản lý phụ thuộc Flutter SDK & Packages
│   └── README.md             # 📖 Tài liệu chi tiết về Frontend (Giao diện, Chức năng, Test Plan)
│
└── Backend/                  # Máy chủ REST API xây dựng bằng Node.js / Express
    ├── src/                  # Mã nguồn xử lý API, Controllers, Models, Routes
    ├── .env.example          # Mẫu biến môi trường (MongoDB URI, JWT Secret, Port)
    ├── package.json          # Quản lý dependencies (Express, Mongoose, Multer, JWT, Bcrypt)
    └── node_modules/         # Thư viện Node.js cài đặt
```

---

## 🚀 Khởi Động Nhanh

### 1. Khởi Chạy Backend (Node.js & MongoDB)
```bash
cd Backend
npm install
# Cấu hình file .env từ .env.example
npm run dev
```

### 2. Khởi Chạy Frontend (Flutter)
```bash
cd Frontend
flutter pub get
flutter run -d chrome    # Chạy trên Trình duyệt Web
# hoặc: flutter run -d windows  (Chạy trên Windows Desktop)
```

---

## 📖 Tài Liệu Tham Khảo Chi Tiết
* Chi tiết phân tích toàn bộ 9 giao diện, kiến trúc BLoC / Cubit, ma trận kiểm thử và luồng hoạt động người dùng của Frontend: xem tại **[Frontend/README.md](Frontend/README.md)**.
