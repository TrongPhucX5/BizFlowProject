# 🚀 BIZFLOW - HỆ THỐNG QUẢN LÝ BÁN HÀNG THÔNG MINH (AI-POWERED SaaS)

> **Giải pháp chuyển đổi số toàn diện cho hộ kinh doanh vật liệu xây dựng & kim khí.**
> Tích hợp Trợ lý ảo AI, Quản lý kho thời gian thực và Báo cáo thông minh.

[![Spring Boot](https://img.shields.io/badge/Backend-Spring%20Boot-green)](https://spring.io/)
[![Next.js](https://img.shields.io/badge/Frontend-Next.js%2014-black)](https://nextjs.org/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/AI-FastAPI%20%2B%20Gemini-yellow)](https://fastapi.tiangolo.com/)
[![MySQL](https://img.shields.io/badge/Database-MySQL-orange)](https://www.mysql.com/)

---

## 📖 1. TỔNG QUAN DỰ ÁN

**BizFlow** giải quyết bài toán quản lý lỏng lẻo tại các cửa hàng vật liệu xây dựng truyền thống bằng cách loại bỏ sổ sách thủ công. Hệ thống không chỉ là phần mềm quản lý kho (ERP) mà còn tích hợp **Generative AI** để đơn giản hóa thao tác nhập liệu.

### 🌟 Điểm nổi bật (Key Highlights)

- **AI Assistant (Gemini):** Hiểu ngôn ngữ tự nhiên. Ví dụ: _"Bán cho anh Nam 10 bao xi măng Hà Tiên, ghi nợ nhé"_ -> Hệ thống tự tạo đơn, trừ kho và ghi nợ.
- **SaaS Architecture:** Hỗ trợ mô hình đa chi nhánh/đa cửa hàng (Multi-tenant). Có phân hệ riêng cho Super Admin quản trị hệ thống.
- **Clean Dashboard UI:** Giao diện quản trị hiện đại, trực quan với biểu đồ phân tích dữ liệu thực (Recharts).
- **Đồng bộ đa nền tảng:** Dữ liệu đồng bộ tức thì giữa Web (cho quản lý) và Mobile App (cho nhân viên bán hàng).

---

## 🏗 2. KIẾN TRÚC HỆ THỐNG

Hệ thống hoạt động theo mô hình **Microservices-like**, tách biệt rõ ràng giữa các service:

| Thành phần       | Công nghệ                    | Nhiệm vụ chính                                            | Port Mặc định |
| :--------------- | :--------------------------- | :-------------------------------------------------------- | :------------ |
| **Backend Core** | Java 17+, Spring Boot 3      | Xử lý nghiệp vụ chính, bảo mật (JWT), giao tiếp Database. | `8080`        |
| **Web Admin**    | Next.js 14, Tailwind, Shadcn | Dashboard quản lý, Báo cáo, Cấu hình hệ thống.            | `3000`        |
| **AI Service**   | Python, FastAPI, Gemini      | Xử lý NLP, Phân tích dữ liệu, Chatbot logic.              | `8000`        |
| **Mobile App**   | Flutter (Dart)               | POS bán hàng tại quầy, tra cứu nhanh.                     | `Mobile`      |
| **Database**     | MySQL 8.0                    | Lưu trữ dữ liệu quan hệ (Users, Products, Orders...).     | `3306`        |

---

## ⚡ 3. TÍNH NĂNG CHI TIẾT

### 🖥️ A. Phân hệ Web Admin (Dành cho Chủ cửa hàng)

1.  **Dashboard thông minh:**
    - Thống kê doanh thu, lợi nhuận, tổng đơn theo thời gian thực.
    - Biểu đồ trực quan (Bar/Area/Pie Chart) sử dụng thư viện Recharts.
    - Danh sách cảnh báo tồn kho (Low stock alerts).
2.  **Quản lý Kho & Sản phẩm:**
    - CRUD sản phẩm, cập nhật giá vốn/giá bán.
    - Quản lý đơn vị tính quy đổi (Bao, Kg, Tấn).
3.  **Quản lý Công nợ:**
    - Theo dõi nợ khách hàng chi tiết.
    - Ghi nhận lịch sử trả nợ (Tiền mặt/Chuyển khoản).
4.  **AI Chatbox:**
    - Hỏi đáp số liệu kinh doanh: _"Doanh thu hôm nay thế nào?"_.
    - Ra lệnh tạo đơn hàng nhanh.

### 📱 B. Phân hệ Mobile App (Dành cho Nhân viên/Sales)

1.  **POS Bán hàng:** Tạo đơn nhanh, chọn sản phẩm, áp mã giảm giá.
2.  **Quét mã vạch:** Tìm kiếm sản phẩm bằng Camera.
3.  **In hóa đơn:** Kết nối máy in nhiệt qua Bluetooth/LAN.

### 👑 C. Phân hệ Super Admin (Quản trị hệ thống)

1.  Quản lý danh sách các cửa hàng (Tenants) đăng ký sử dụng.
2.  Khóa/Mở khóa tài khoản cửa hàng.
3.  Xem báo cáo tổng quan toàn sàn.

---

## 🛠 4. CÀI ĐẶT & HƯỚNG DẪN CHẠY (LOCAL)

### Yêu cầu tiên quyết (Prerequisites)

- Java JDK 17+ & Maven
- Node.js 18+ & npm/yarn
- Python 3.10+
- MySQL Server
- Flutter SDK

### Bước 1: Cấu hình Database

1.  Tạo database tên `bizflow` trong MySQL.
2.  Import file SQL mẫu (nếu có) hoặc để Hibernate tự động sinh bảng (`ddl-auto: update`).

### Bước 2: Khởi chạy AI Service (Python) **(QUAN TRỌNG: Chạy trước)**

Backend Java cần service này để xử lý các request AI.

```bash
cd ai_service
# Tạo môi trường ảo (Khuyên dùng)
python -m venv venv
# Windows:
venv\Scripts\activate
# Mac/Linux:
# source venv/bin/activate

# Cài thư viện
pip install -r requirements.txt

# Tạo file .env chứa key Gemini
# (Lưu ý: Tạo file .env và dán GEMINI_API_KEY=... vào)

# Chạy Server
uvicorn main:app --reload --port 8000
```

### ▶️ Bước 3: Backend

1.  Mở src/main/resources/application.properties.
2.  Cấu hình lại spring.datasource.username và password của máy bạn.
3.  Chạy lệnh:

```bash
cd backend
mvn spring-boot:run
```

✅ Server chạy tại: http://localhost:8080

### ▶️ Bước 4: Web Admin

```bash
cd web-admin
npm install
npm run dev
```

✅ Truy cập Dashboard: http://localhost:3000

### Bước 📂 5. CẤU TRÚC THƯ MỤC DỰ ÁN

Backend Java cần service này để xử lý các request AI.

```bash
bizflow-project/
├── backend/                # Spring Boot App
│   ├── src/main/java/com/bizflow/...
│   │   ├── interfaces/web  # REST Controllers
│   │   ├── core/domain     # Entities
│   │   └── infrastructure  # Repositories & Security
│
├── web-admin/              # Next.js App
│   ├── src/app/            # App Router (Dashboard, Login...)
│   ├── src/components/     # UI Components (Shadcn, Recharts)
│   ├── src/services/       # API integration (Axios, React Query)
│   └── public/
│
├── ai_service/             # Python FastAPI
│   ├── main.py             # Entry point
│   ├── prompt_templates.py # Các kịch bản cho AI
│   └── requirements.txt
│
└── mobile/                 # Flutter App
    ├── lib/
    └── pubspec.yaml
```
