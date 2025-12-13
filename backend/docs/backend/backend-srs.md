# 📋 BizFlow Backend SRS - Software Requirements Specification

## 1. Actors (Người Dùng Hệ Thống)

### 1.1 Administrator (ADMIN)
- **Mô tả**: Quản lý toàn hệ thống, không phụ thuộc cửa hàng cụ thể
- **Quyền**:
  - Quản lý chủ cửa hàng (tạo/xóa account Owner)
  - Quản lý gói subscription (tạo/cập nhật gói, gán cho Owner)
  - Xem dashboard toàn hệ thống (doanh số tất cả stores)
  - Quản lý template báo cáo kế toán (upload/update mẫu)
  - Monitor AI & hệ thống (error logs, API health)

### 1.2 Owner (Chủ Cửa Hàng) - Role OWNER
- **Mô tả**: Chủ sở hữu cửa hàng, quản lý toàn bộ hoạt động
- **Quyền**:
  - CRUD sản phẩm (tạo, sửa, xóa, giá, đơn vị tính)
  - CRUD khách hàng
  - CRUD đơn hàng (xem lịch sử)
  - CRUD nhân viên
  - Quản lý tồn kho (nhập hàng, điều chỉnh, xem lịch sử)
  - Theo dõi công nợ (danh sách khách nợ, thanh toán)
  - Xem báo cáo (doanh thu, tồn kho, công nợ)
  - Quản lý phân quyền nhân viên
  - Theo dõi log hoạt động (audit trail)
  - Cấu hình template báo cáo cho cửa hàng

### 1.3 Employee (Nhân Viên) - Role EMPLOYEE
- **Mô tả**: Nhân viên bán hàng, xử lý giao dịch hàng ngày
- **Quyền**:
  - Đăng nhập vào hệ thống
  - Tạo đơn hàng tại quầy (POS)
  - Tìm sản phẩm nhanh chóng
  - Ghi nợ khách hàng
  - In hóa đơn bán hàng
  - Xem & xác nhận draft order từ AI
  - Nhận thông báo real-time
  - Xem báo cáo nhanh (doanh số hôm nay, đơn chưa xử lý)

---

## 2. Functional Requirements

### 2.1 Authentication & Authorization (FA-001 ~ FA-010)

#### FA-001: User Registration (Admin only)
- **Actor**: ADMIN
- **Flow**:
  1. Admin gửi request `POST /auth/register` với username, password, role, email
  2. Backend hash password (BCrypt), kiểm tra username unique
  3. Tạo user record, return success
- **Validation**:
  - Username không trống, 3-30 ký tự, alphanumeric
  - Password tối thiểu 8 ký tự, có chữ số & ký tự đặc biệt
  - Email hợp lệ
  - Username chưa tồn tại

#### FA-002: User Login
- **Actor**: All (ADMIN, OWNER, EMPLOYEE)
- **Flow**:
  1. User gửi `POST /auth/login` { username, password }
  2. Backend xác thực user
  3. Tạo JWT token (HS256, 1 hour expiry)
  4. Return { accessToken, refreshToken (nếu cần), expiresIn, role, username }
- **Error Cases**:
  - 401: Username/password không đúng
  - 400: Missing fields

#### FA-003: Token Refresh
- **Actor**: All
- **Flow**:
  1. User gửi `POST /auth/refresh` { refreshToken }
  2. Backend validate refresh token
  3. Return new { accessToken }
- **Token Expiry**: Access token 1 hour, Refresh token 7 days

#### FA-004: User Logout
- **Actor**: All
- **Flow**: Blacklist token (optional), clear session

#### FA-005: Change Password
- **Actor**: All
- **Flow**:
  1. User gửi `PUT /users/change-password` { oldPassword, newPassword }
  2. Backend verify oldPassword matches user's current password
  3. Update password (hash), return success
- **Validation**: newPassword phải khác oldPassword

#### FA-006: Role-Based Access Control (RBAC)
- **Policy**:
  - ADMIN: Quyền toàn hệ thống
  - OWNER: Quyền quản lý cửa hàng của mình
  - EMPLOYEE: Quyền tạo đơn & xem báo cáo cơ bản
- **Implementation**: JWT claim `role`, SecurityConfig filter endpoint

#### FA-007: Permission Mapping
- **Table**: `roles`, `permissions`, `role_permissions`
- **Granular checks**:
  - `PRODUCT_CREATE` → Owner/Admin only
  - `ORDER_CREATE` → Employee/Owner
  - `DEBT_WRITE` → Owner only
  - `SUBSCRIPTION_MANAGE` → Admin only

#### FA-008: Multi-Tenant Isolation
- **Constraint**: Mỗi Owner quản lý 1 cửa hàng (Store)
- **Data Isolation**: 
  - Mọi entity (Product, Order, Customer) phải có `store_id`
  - Query phải filter theo `store_id` của user hiện tại
  - Employee không thể xem data của store khác

#### FA-009: JWT Validation
- **Logic**:
  - Signature verification (HS256)
  - Expiry check
  - Token malformation check
  - Return 401 if invalid/expired

#### FA-010: Session Management
- **Flow**: 
  - On login: Store token in frontend localStorage (Web) / SharedPreferences (Mobile)
  - On logout: Clear token
  - On token expiry: Redirect to login or auto-refresh

---

### 2.2 Product Management (FA-011 ~ FA-025)

#### FA-011: Create Product
- **Actor**: OWNER
- **Request**: `POST /products`
  ```json
  {
    "name": "Xi măng Portland",
    "sku": "XM-001",
    "description": "Xi măng 40kg",
    "price": 150000,
    "unit": "bao",
    "category": "Vật liệu xây dựng",
    "image": "url or file"
  }
  ```
- **Response**: 201 Created
  ```json
  {
    "id": 1,
    "name": "Xi măng Portland",
    "sku": "XM-001",
    "price": 150000,
    "unit": "bao",
    "createdAt": "2025-01-01T10:00:00Z"
  }
  ```
- **Validation**:
  - Name không trống, max 100 ký tự
  - SKU unique
  - Price >= 0
  - Unit must be from predefined list (bao, cái, bộ, etc.)

#### FA-012: List Products (with pagination, filter, sort)
- **Actor**: OWNER, EMPLOYEE (read-only)
- **Request**: `GET /products?page=1&size=20&category=vat-lieu&search=xi-mang&sort=price,asc`
- **Response**: 200 OK
  ```json
  {
    "items": [
      { "id": 1, "name": "Xi măng", "price": 150000, "unit": "bao" }
    ],
    "totalElements": 100,
    "totalPages": 5,
    "currentPage": 1,
    "pageSize": 20
  }
  ```

#### FA-013: Get Product Detail
- **Actor**: OWNER, EMPLOYEE
- **Request**: `GET /products/{id}`
- **Response**: 200 OK { product details + current stock }

#### FA-014: Update Product
- **Actor**: OWNER
- **Request**: `PUT /products/{id}` { name, price, unit, description, ... }
- **Response**: 200 OK
- **Validation**: Same as FA-011

#### FA-015: Delete Product
- **Actor**: OWNER
- **Request**: `DELETE /products/{id}`
- **Constraint**: Không thể xóa nếu sản phẩm đã được bán
- **Response**: 200 OK or 400 Bad Request

#### FA-016: Upload Product Image
- **Actor**: OWNER
- **Request**: `POST /products/{id}/image` (multipart/form-data)
- **Response**: 200 OK { imageUrl }
- **Storage**: Local disk or S3
- **Size Limit**: 5 MB max

#### FA-017: Bulk Import Products
- **Actor**: OWNER
- **Request**: `POST /products/import` (multipart/form-data, CSV/Excel)
- **Flow**:
  1. Validate file format
  2. Parse rows
  3. Check duplicates (SKU)
  4. Insert all products
- **Response**: 200 OK { imported_count, failed_count, errors[] }

#### FA-018: Product Categories
- **Management**: OWNER can CRUD categories
- **Constraint**: Category linked to products
- **Endpoints**: `GET /categories`, `POST /categories`, `PUT /categories/{id}`, `DELETE /categories/{id}`

#### FA-019: Product Units
- **Predefined Units**: bao, cái, bộ, kg, lít, m², m³, etc.
- **Customization**: OWNER can add custom units

#### FA-020: Product History
- **Tracking**: Track price changes, creation date, last modified date
- **Audit**: Who created, who modified, when
- **Table**: `products` with `created_by`, `created_at`, `updated_by`, `updated_at`

#### FA-021 ~ FA-025: (Similar pattern for other product operations)

---

### 2.3 Customer Management (FA-026 ~ FA-040)

#### FA-026: Create Customer
- **Actor**: OWNER, EMPLOYEE
- **Request**: `POST /customers`
  ```json
  {
    "name": "Anh Hòa Vật Liệu",
    "phone": "0901234567",
    "email": "hoa@email.com",
    "address": "123 Đường Lý Thái Tổ, Hà Nội",
    "type": "RETAIL" or "WHOLESALE"
  }
  ```
- **Response**: 201 Created { id, name, phone, created_at }
- **Validation**:
  - Name không trống, max 100 ký tự
  - Phone: 10-11 ký tự, Vietnamese format
  - Email hợp lệ (if provided)

#### FA-027: List Customers (with pagination, filter)
- **Actor**: OWNER, EMPLOYEE (read-only)
- **Request**: `GET /customers?page=1&size=20&search=hòa&type=RETAIL`
- **Response**: Paginated list

#### FA-028: Get Customer Detail
- **Include**: Customer info + outstanding debt + recent orders
- **Request**: `GET /customers/{id}`

#### FA-029: Update Customer
- **Actor**: OWNER
- **Request**: `PUT /customers/{id}`

#### FA-030: Delete Customer
- **Constraint**: Không thể xóa nếu có outstanding debt
- **Response**: 400 Bad Request if constraint violated

#### FA-031 ~ FA-040: (Similar customer-related operations)

---

### 2.4 Order Management (FA-041 ~ FA-070)

#### FA-041: Create Order (POS - Tạo đơn tại quầy)
- **Actor**: EMPLOYEE, OWNER
- **Request**: `POST /orders`
  ```json
  {
    "customerId": 1,
    "items": [
      { "productId": 1, "quantity": 10, "unitPrice": 150000 },
      { "productId": 2, "quantity": 5, "unitPrice": 200000 }
    ],
    "paymentType": "CASH" or "CREDIT",
    "notes": "Giao hàng ngày mai",
    "discountAmount": 50000
  }
  ```
- **Response**: 201 Created
  ```json
  {
    "id": 1001,
    "customerId": 1,
    "totalAmount": 3200000,
    "discountAmount": 50000,
    "finalAmount": 3150000,
    "status": "CONFIRMED",
    "createdAt": "2025-01-01T10:30:00Z",
    "createdBy": "employee01"
  }
  ```
- **Business Logic**:
  1. Validate customer exists
  2. Validate all products exist & have sufficient stock
  3. Calculate total = sum(quantity * unitPrice) - discount
  4. Create Order entity with status CONFIRMED
  5. Create OrderItem records
  6. Reduce stock (create StockMovement with type SALE)
  7. If payment_type = CREDIT → create Debt/Receivable
  8. Update Order.status = CONFIRMED
  9. Emit WebSocket notification
  10. Return Order response

#### FA-042: Confirm Order (from Draft)
- **Actor**: EMPLOYEE
- **Request**: `POST /orders/confirm-draft/{draftId}`
- **Flow**:
  1. Fetch DraftOrder by ID
  2. Validate draft status = DRAFT
  3. Check permissions (employee can only confirm their own draft)
  4. Call OrderService.confirmDraft(draftOrder)
  5. This triggers same logic as FA-041
  6. Mark DraftOrder.status = CONFIRMED, Order.id set to newly created order
- **Response**: 201 Created (new Order)

#### FA-043: Cancel Order
- **Actor**: OWNER, EMPLOYEE (owner only via OWNER role check)
- **Request**: `POST /orders/{id}/cancel` { reason }
- **Constraint**: Only cancel if status = CONFIRMED (not CANCELLED, not PAID)
- **Business Logic**:
  1. Restore stock (reverse StockMovement)
  2. If debt exists → mark as CANCELLED/VOIDED
  3. Update Order.status = CANCELLED
  4. Record cancellation reason & timestamp
- **Response**: 200 OK

#### FA-044: List Orders (with pagination, filter, date range)
- **Actor**: OWNER, EMPLOYEE (employees see only their own orders or all if owner-level access)
- **Request**: `GET /orders?page=1&size=20&customerId=1&status=CONFIRMED&from=2025-01-01&to=2025-01-31&sort=createdAt,desc`
- **Response**: Paginated list

#### FA-045: Get Order Detail
- **Include**: Order info + items + customer + payment status
- **Request**: `GET /orders/{id}`

#### FA-046: Print/Export Order (Invoice)
- **Format**: PDF or HTML
- **Request**: `GET /orders/{id}/print` → download PDF
- **Template**: Standard invoice with:
  - Store name, address, phone
  - Order ID, date
  - Customer name, address
  - Item list (product, qty, unit price, amount)
  - Total, discount, final amount
  - Payment terms

#### FA-047: Order Status Transitions
- **Statuses**: DRAFT → CONFIRMED → PAID / PAID_PARTIAL / UNPAID
- **Rules**:
  - DRAFT: Waiting for confirmation (from AI)
  - CONFIRMED: Confirmed, not yet fully paid
  - PAID: Fully paid
  - PAID_PARTIAL: Partially paid, still owing
  - CANCELLED: Cancelled order

#### FA-048 ~ FA-070: (Similar order-related operations)

---

### 2.5 Inventory Management (FA-071 ~ FA-090)

#### FA-071: Current Stock Levels
- **Request**: `GET /inventory?storeId=1`
- **Response**: List of { productId, productName, quantity, reorderLevel }
- **Query**: Aggregate from Inventory table

#### FA-072: Stock In (Nhập hàng)
- **Actor**: OWNER
- **Request**: `POST /inventory/stock-in`
  ```json
  {
    "productId": 1,
    "quantity": 100,
    "unitPrice": 130000,
    "supplierName": "Công ty X",
    "referenceNumber": "PO-001"
  }
  ```
- **Response**: 201 Created
- **Business Logic**:
  1. Create StockMovement { type: STOCK_IN, quantity, productId }
  2. Update Inventory { quantity += 100 }
  3. Record supplier & cost for future analysis
  4. Update Product.lastRestockDate

#### FA-073: Stock Adjustment
- **Actor**: OWNER
- **Request**: `POST /inventory/adjust`
  ```json
  {
    "productId": 1,
    "oldQuantity": 100,
    "newQuantity": 95,
    "reason": "Hàng hỏng (broken)"
  }
  ```
- **Response**: 200 OK
- **Business Logic**:
  1. Create StockMovement { type: STOCK_ADJUST, quantity: newQuantity - oldQuantity, reason }
  2. Update Inventory

#### FA-074: Stock Reorder Alert
- **Request**: `GET /inventory/low-stock` (threshold-based)
- **Logic**: Return products where quantity <= reorderLevel
- **Response**: List of products needing restock

#### FA-075: Stock Movement History
- **Request**: `GET /inventory/movements?productId=1&from=2025-01-01&to=2025-01-31`
- **Response**: List of { date, type, quantity, reference, notes }
- **Types**: SALE, STOCK_IN, STOCK_ADJUST

#### FA-076 ~ FA-090: (Similar inventory operations)

---

### 2.6 Debt & Payment Management (FA-091 ~ FA-110)

#### FA-091: Record Debt (Ghi nợ)
- **Created Automatically**: When Order is created with paymentType = CREDIT
- **Fields**:
  - customerId, storeId
  - amount, originalAmount
  - createdDate, dueDate
  - status (UNPAID, PAID, PAID_PARTIAL, OVERDUE)
  - relatedOrder (reference)

#### FA-092: List Outstanding Debts
- **Request**: `GET /debts?status=UNPAID&sort=createdAt,desc`
- **Response**: List { id, customerId, customerName, amount, createdAt, dueAt }

#### FA-093: Customer Debt Summary
- **Request**: `GET /customers/{id}/debts`
- **Response**: { totalDebt, paidAmount, unpaidAmount, overdueAmount, lastPaymentDate, debtHistory[] }

#### FA-094: Record Payment (Thanh toán nợ)
- **Actor**: OWNER, EMPLOYEE
- **Request**: `POST /payments`
  ```json
  {
    "debtId": 1,
    "amount": 500000,
    "paymentMethod": "CASH" or "BANK_TRANSFER",
    "notes": "Thanh toán nợ hàng tháng"
  }
  ```
- **Response**: 201 Created { id, debtId, amount, method, createdAt }
- **Business Logic**:
  1. Validate debt exists & status = UNPAID or PAID_PARTIAL
  2. Create Payment record
  3. Update Debt.paidAmount += amount
  4. If paidAmount >= debt.originalAmount → status = PAID
  5. Else → status = PAID_PARTIAL

#### FA-095: Payment History
- **Request**: `GET /payments?customerId=1`
- **Response**: List of payments

#### FA-096 ~ FA-110: (Similar debt operations)

---

### 2.7 AI Draft Order (FA-111 ~ FA-120)

#### FA-111: Create Draft Order from AI
- **Actor**: EMPLOYEE (via text/voice)
- **Request**: `POST /ai/draft-order`
  ```json
  {
    "input": "bán 10 bao xi măng cho anh Hòa, ghi nợ nha",
    "inputType": "TEXT" or "VOICE"
  }
  ```
- **Flow**:
  1. Call AI Gateway → Gemini API
  2. Gemini parses: productName="xi măng", qty=10, customerName="Hòa", paymentType="CREDIT"
  3. Backend searches:
     - Product by name match (fuzzy match)
     - Customer by name match (if not found, create new)
  4. Create DraftOrder entity:
     - status = DRAFT
     - productId, customerId, quantity, paymentType
     - aiParsedData (JSON) for audit
  5. Assign to employee who created it
  6. Emit WebSocket notification: "Draft order created, please review"
- **Response**: 201 Created
  ```json
  {
    "id": "DRAFT-001",
    "status": "DRAFT",
    "productId": 1,
    "productName": "Xi măng",
    "customerId": 2,
    "customerName": "Anh Hòa",
    "quantity": 10,
    "estimatedAmount": 1500000,
    "paymentType": "CREDIT",
    "createdAt": "2025-01-01T10:35:00Z",
    "assignedTo": "employee01"
  }
  ```

#### FA-112: Confirm Draft → Create Actual Order
- **Request**: `POST /ai/draft-order/{draftId}/confirm`
- **Flow**: (Same as FA-042)
- **Response**: 201 Created (actual Order)

#### FA-113: Edit Draft (Before Confirming)
- **Request**: `PUT /ai/draft-order/{draftId}`
  ```json
  {
    "quantity": 15,
    "customerId": 3,
    "notes": "Giao hàng mai"
  }
  ```
- **Validation**: Only if status = DRAFT

#### FA-114: Reject Draft
- **Request**: `POST /ai/draft-order/{draftId}/reject` { reason }
- **Response**: 200 OK, status = REJECTED

#### FA-115 ~ FA-120: (AI order operations)

---

### 2.8 Reporting & Dashboard (FA-121 ~ FA-140)

#### FA-121: Dashboard Overview
- **Actor**: OWNER
- **Request**: `GET /reports/dashboard?from=2025-01-01&to=2025-01-31`
- **Response**:
  ```json
  {
    "period": { "from": "2025-01-01", "to": "2025-01-31" },
    "revenue": 50000000,
    "orderCount": 250,
    "averageOrderValue": 200000,
    "outstandingDebt": 15000000,
    "paidDebt": 35000000,
    "stockValue": 100000000,
    "topProducts": [
      { "id": 1, "name": "Xi măng", "quantity": 500, "amount": 75000000 }
    ],
    "dailyRevenue": [
      { "date": "2025-01-01", "amount": 2000000 },
      ...
    ]
  }
  ```
- **Caching**: Redis (15 min TTL)

#### FA-122: Sales Report
- **Request**: `GET /reports/sales?from=2025-01-01&to=2025-01-31&groupBy=DAILY|WEEKLY|MONTHLY`
- **Response**: Time-series data

#### FA-123: Inventory Report
- **Request**: `GET /reports/inventory`
- **Response**: List of products with current stock, reorder level, stock value

#### FA-124: Customer Debt Report
- **Request**: `GET /reports/debts?status=UNPAID|OVERDUE`
- **Response**: List of customers with outstanding debts

#### FA-125 ~ FA-140: (Similar reporting operations)

---

### 2.9 User & Employee Management (FA-141 ~ FA-160)

#### FA-141: Create Employee (Owner creating for their store)
- **Actor**: OWNER
- **Request**: `POST /users`
  ```json
  {
    "username": "employee01",
    "password": "secure_password",
    "fullName": "Nguyễn Văn A",
    "role": "EMPLOYEE",
    "email": "a@email.com",
    "phone": "0901234567"
  }
  ```
- **Response**: 201 Created
- **Validation**: Check username unique, password complexity

#### FA-142: List Employees
- **Actor**: OWNER
- **Request**: `GET /users?role=EMPLOYEE`

#### FA-143: Update Employee
- **Actor**: OWNER
- **Request**: `PUT /users/{id}`

#### FA-144: Disable/Enable Employee
- **Request**: `POST /users/{id}/disable` or `/enable`
- **Effect**: Locked employee cannot login

#### FA-145 ~ FA-160: (User management operations)

---

### 2.10 Subscription Management (FA-161 ~ FA-175)

#### FA-161: Create Subscription Plan (Admin only)
- **Request**: `POST /subscriptions/plans`
  ```json
  {
    "name": "Free",
    "description": "Gói miễn phí",
    "price": 0,
    "features": {
      "maxProducts": 100,
      "maxEmployees": 3,
      "maxCustomers": 500,
      "hasAI": false,
      "hasReports": false
    },
    "durationMonths": 1
  }
  ```

#### FA-162: Assign Subscription to Owner
- **Request**: `POST /subscriptions/assign`
  ```json
  {
    "ownerId": 1,
    "planId": 1,
    "startDate": "2025-01-01",
    "durationMonths": 12
  }
  ```

#### FA-163: Check Feature Access
- **Request**: Internal (called by backend services)
- **Logic**: Validate if Owner's subscription includes requested feature
- **Example**: OrderService checks before allowing AI draft order

#### FA-164 ~ FA-175: (Subscription operations)

---

## 3. Non-Functional Requirements (NFR)

### 3.1 Performance (NFR-001 ~ NFR-010)
- **API Response Time**: 
  - Simple queries (GET list): < 100ms
  - Complex queries (report): < 500ms
  - POS order creation: < 200ms
- **Concurrent Users**: Support 1000+ simultaneous connections
- **Database Query**: Use indexes for common queries (product search, order list)
- **Caching**:
  - Product catalog: 1 hour TTL (Redis)
  - Dashboard: 15 minutes TTL
  - User permissions: 30 minutes TTL

### 3.2 Security (NFR-011 ~ NFR-030)
- **Authentication**: JWT with HS256
- **Password**: BCrypt with salt
- **Authorization**: Fine-grained RBAC per endpoint
- **Data Protection**:
  - HTTPS only in production
  - Encrypt sensitive fields in DB (passwords, PII)
  - Multi-tenant isolation (store_id filtering)
- **Audit**:
  - Log all CREATE/UPDATE/DELETE operations
  - Include user ID, timestamp, old/new values
- **SQL Injection**: JPA parameterized queries only
- **CORS**: Whitelist frontend origins

### 3.3 Scalability (NFR-031 ~ NFR-040)
- **Database**: Horizontal partitioning by store_id (future)
- **Caching**: Redis for frequently accessed data
- **API Versioning**: Support `/api/v1/`, `/api/v2/` for backward compatibility
- **Load Balancing**: Stateless design for horizontal scaling

### 3.4 Reliability (NFR-041 ~ NFR-050)
- **Database Backup**: Daily backup, retention 30 days
- **Error Handling**: Custom exceptions, meaningful error messages
- **Monitoring**: Spring Boot Actuator health check
- **Logging**: Structured logging (timestamp, level, message, stack trace)
- **Graceful Degradation**: If AI service fails, allow manual order entry

### 3.5 Compliance (NFR-051 ~ NFR-060)
- **Vietnamese Tax**: Support Thông tư 88 invoice format
- **Data Privacy**: GDPR/local regulations on PII storage
- **Audit Trail**: Immutable logs of all transactions

### 3.6 Maintainability (NFR-061 ~ NFR-070)
- **Code Quality**: SonarQube score > 80
- **Documentation**: JavaDoc for public methods, architecture decisions recorded
- **Testing**: > 70% code coverage (unit + integration tests)
- **Dependency Management**: Keep Spring Boot, Java, libraries up-to-date

---

## 4. Business Rules (BR)

| ID | Rule |
|----|------|
| BR-001 | Password must be hashed with BCrypt before storing |
| BR-002 | User cannot have multiple active subscriptions |
| BR-003 | Product SKU must be unique within a store |
| BR-004 | Order cannot be created if product stock < order quantity |
| BR-005 | Stock cannot go negative (enforce constraint) |
| BR-006 | Debt is automatically created if Order payment_type = CREDIT |
| BR-007 | Draft order must be confirmed or rejected within 24 hours |
| BR-008 | Employee can only see their store's data (multi-tenant) |
| BR-009 | Owner can only manage products/customers in their store |
| BR-010 | Admin can manage all stores but not directly interact with sales |
| BR-011 | Order discount cannot exceed 50% of original total |
| BR-012 | Payment must not exceed outstanding debt |
| BR-013 | Deleted products cannot be removed if they appear in historical orders |
| BR-014 | Stock-in must have unitPrice to track COGS |
| BR-015 | Customer phone number must be Vietnamese format |

---

## 5. API Use Case Mapping

| Use Case | Primary API | Secondary APIs |
|----------|------------|-----------------|
| FA-001: User Register | POST /auth/register | - |
| FA-002: User Login | POST /auth/login | - |
| FA-041: Create Order | POST /orders | GET /customers, GET /products, POST /inventory, POST /debts |
| FA-042: Confirm Draft | POST /orders/confirm-draft/{id} | (same as FA-041) |
| FA-111: Create Draft | POST /ai/draft-order | GET /products, GET /customers |
| FA-121: Dashboard | GET /reports/dashboard | (aggregates multiple tables) |

---

## 6. Data Consistency & Transaction Boundaries

### Order Creation Transaction (FA-041)
**ACID Guarantee**:
- **Atomicity**: All-or-nothing (order + items + stock movement + debt)
- **Consistency**: Stock cannot go negative, debt amount matches order
- **Isolation**: Prevent race conditions on stock update
- **Durability**: Committed to persistent storage

**Implementation**: Use `@Transactional` on OrderService.createOrder()

### Stock Movement Transaction (FA-072)
**Guarantee**: Stock-in + StockMovement must both succeed or both rollback

---

## 7. Success Criteria & Acceptance

### MVP Success Criteria
- ✅ User authentication & JWT working
- ✅ CRUD Products, Customers, Orders implemented
- ✅ Stock management basic (SALE movement only)
- ✅ Debt tracking functional
- ✅ Dashboard with basic metrics
- ✅ 80% unit test coverage for services
- ✅ API documentation complete

### Stretch Goals (Phase 2)
- 🎯 AI Draft Order (Gemini integration)
- 🎯 Advanced stock adjustments
- 🎯 Payment reconciliation
- 🎯 WebSocket real-time notifications
- 🎯 Invoice generation (PDF)

---

**Last Updated**: December 13, 2025  
**Document Version**: 1.0.0  
**Status**: In Development
