#  BIZFLOW - NỀN TẢNG HỖ TRỢ CHUYỂN ĐỔI SỐ CHO HỘ KINH DOANH

---

## 1. GIỚI THIỆU & BỐI CẢNH DỰ ÁN

Dự án **BizFlow** đề xuất xây dựng nền tảng chuyên biệt nhằm giải quyết các khó khăn trong quản lý vận hành của các hộ kinh doanh truyền thống (vật liệu xây dựng, kim khí) tại Việt Nam.

Hiện tại, đa số hộ kinh doanh vẫn ghi chép thủ công bằng sổ tay hoặc Excel, dẫn đến sai sót, khó kiểm soát tồn kho và công nợ không nhất quán. Đặc thù của nhóm khách hàng này là thiếu ngân sách thuê kế toán và thường chỉ sử dụng một chiếc smartphone để làm việc.

**Giải pháp đề xuất:** BizFlow tích hợp giao diện kèm trợ lý AI có khả năng hiểu yêu cầu ngôn ngữ tự nhiên (qua văn bản hoặc giọng nói), tự động tạo đơn nháp và điền dữ liệu vào biểu mẫu, giúp tự động hóa và cung cấp báo cáo theo thời gian thực.

---

## 2. KIẾN TRÚC & CÔNG NGHỆ SỬ DỤNG

BizFlow được xây dựng dựa trên kiến trúc phân tán (Distributed Architecture) với 4 thành phần chính:

### ⚙️ Tổng quan hệ thống
* **Backend (Java + Spring Boot)**: Trung tâm xử lý nghiệp vụ.
* **Mobile App (Flutter)**: Ứng dụng cho Chủ cửa hàng & Nhân viên.
* **Web Admin (NextJS)**: Ứng dụng quản trị và báo cáo.
* **AI Assistant (Gemini)**: Trợ lý tạo đơn nháp và phân tích dữ liệu.

### 💻 Tech Stack chi tiết
| Lớp | Công nghệ chính | Mục đích |
| :--- | :--- | :--- |
| **Backend** | Java 23, Spring Boot 3 | REST API chuẩn, JWT Auth, Role-based Access Control |
| **Database** | MySQL (Chính), Redis cache | Dữ liệu nghiệp vụ, Tăng tốc độ truy vấn |
| **Mobile** | Flutter, Provider, Shared Preferences | Tạo đơn tại quầy, Ghi nợ, Xem báo cáo nhanh |
| **Web Admin** | NextJS, Tanstack Query, Shadcn UI, TailwindCSS | Dashboard thống kê, CRUD Sản phẩm/Nhân viên |
| **AI** | Python, Gemini, Whisper | Xử lý ngôn ngữ tự nhiên, Tạo Draft Order |

---

## 3. PHẠM VI CHỨC NĂNG CHÍNH (SCOPE)

### 📱 BizFlow Mobile (Employee/Owner)
* **Giao dịch:** Tạo đơn tại quầy, Ghi nợ khách, Tạo / in hóa đơn bán hàng.
* **AI:** Nhận & xác nhận draft order từ AI tạo (Ví dụ: “bán 10 bao xi măng cho anh Hòa, ghi nợ nha”).
* **Quản lý:** Quản lý khách hàng, Quản lý tồn kho (Owner).
* **Thông báo:** Thông báo real-time (Firebase).

### 🖥 BizFlow Web Admin (Owner/Admin)
* Thực hiện CRUD (Sản phẩm, Khách hàng, Đơn hàng, Nhân viên).
* Dashboard thống kê doanh thu, công nợ, tồn kho.
* Quản lý phân quyền và gói subscription.

---

## 4. HƯỚNG DẪN THIẾT LẬP MÔI TRƯỜNG DEV

Các bước cần thiết để khởi động hệ thống trên máy local (Windows/Mac/Linux):

### 4.1. Khởi động Database (Docker)
1.  Đảm bảo Docker Desktop đã được khởi động.
2.  Mở Terminal tại thư mục **`backend/`**.
3.  Chạy lệnh:
    ```bash
    docker-compose up -d
    ```
    *(Lệnh này sẽ khởi tạo MySQL và Redis Cache).*

### 4.2. Khởi động Backend (Spring Boot)
1.  Mở project **`backend/`** trong IntelliJ IDEA.
2.  Bấm nút **Run** (Tam giác xanh) để khởi động ứng dụng Java trên cổng **8080**.

### 4.3. Khởi động Web Admin (NextJS)
1.  Mở Terminal tại thư mục **`web-admin/`**.
2.  Chạy lệnh:
    ```bash
    npm install
    npm run dev
    ```
3.  Truy cập giao diện tại `http://localhost:3000`.

### 4.4. Khởi động Mobile App (Flutter)
1.  Chạy lệnh `flutter pub get` trong thư mục **`mobile/`**.
2.  Chạy ứng dụng trên Android Emulator hoặc thiết bị thực.
---
