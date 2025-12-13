# 📋 BizFlow Backend Overview

## 1. Mục Đích Backend

Backend BizFlow là **trung tâm xử lý nghiệp vụ** của nền tảng hỗ trợ chuyển đổi số cho hộ kinh doanh. Nó cung cấp:

- **REST API** chuẩn cho Mobile App (Flutter) và Web Admin (NextJS)
- **JWT Authentication** & Role-Based Access Control (RBAC)
- **Business Logic** quản lý bán hàng, tồn kho, công nợ
- **AI Gateway** để kết nối với Gemini API (tạo draft order)
- **Realtime Notification** qua WebSocket/Firebase
- **File Service** quản lý hóa đơn & ảnh sản phẩm
- **Caching** (Redis) tối ưu hiệu năng

---

## 2. Kiến Trúc Tổng Thể

### 2.1 Clean Architecture Layers

```
┌─────────────────────────────────────────────────┐
│     PRESENTATION LAYER                          │
│  (Controller, DTO, Exception Handler)           │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│     APPLICATION LAYER                           │
│  (UseCase, Service, DTO Mapper)                 │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│     DOMAIN LAYER                                │
│  (Entity, Domain Service, Business Rules)       │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│     INFRASTRUCTURE LAYER                        │
│  (Repository, Cache, File Storage, Config)      │
└─────────────────────────────────────────────────┘
```

### 2.2 Package Structure

```
com.bizflow.backend
├── config/                          # Spring Config (Security, Cache, etc)
├── core/
│   ├── domain/                      # Entity, Domain Model
│   ├── usecase/                     # Service Interface & Implementation
│   └── exception/                   # Custom Exception
├── infrastructure/
│   ├── persistence/
│   │   └── repository/              # JPA Repository
│   ├── cache/                       # Redis Cache Service
│   ├── file/                        # File Upload/Download Service
│   └── ai/                          # AI Client (Gemini, Whisper)
├── presentation/
│   ├── controller/                  # REST Controller
│   ├── dto/                         # Request/Response DTO
│   ├── filter/                      # Security Filter (JWT)
│   └── handler/                     # Exception Handler, WebSocket Handler
└── BizFlowBackendApplication        # Main Spring Boot Entry
```

---

## 3. Luồng Chính (Main Flow)

### 3.1 Đăng Nhập & Cấp Token

```
Client (Web/Mobile)
     │
     ├─ POST /auth/login (username, password)
     │
     └─ Backend: AuthController
        ├─ AuthenticationManager.authenticate() [Verify password]
        ├─ JwtUtil.generateToken() [Create JWT Token]
        └─ Return { token, refreshToken, role, username }
```

### 3.2 Tạo Đơn Hàng

```
Employee (Mobile/Web)
     │
     ├─ POST /orders (OrderRequest + JWT token)
     │
     └─ Backend: OrderController
        ├─ JwtRequestFilter.doFilter() [Validate token]
        ├─ SecurityConfig: Check role EMPLOYEE/OWNER
        ├─ OrderService.createOrder() [Business logic]
        │  ├─ Validate customer exists
        │  ├─ Validate product stock
        │  ├─ Calculate total price
        │  ├─ Create Order entity
        │  └─ Reduce stock (StockMovement)
        ├─ Send notification (WebSocket/Firebase)
        └─ Return ApiResponse { order, message }
```

### 3.3 AI Draft Order Flow

```
Employee (Voice/Text)
     │
     ├─ POST /ai/draft-order (text: "bán 10 xi măng cho Hòa")
     │
     └─ Backend: AIController
        ├─ AI Gateway: Call Gemini API
        │  └─ Return parsed: { product_name, qty, customer_name, note }
        ├─ DraftOrderService.createDraft()
        │  └─ Save DraftOrder entity
        ├─ Send notification [Employee review & confirm]
        │  └─ Emit WebSocket event
        └─ Return DraftOrder { id, status: DRAFT }

Employee (Confirm)
     │
     ├─ POST /orders/confirm-draft/{draftId} (JWT token)
     │
     └─ Backend: OrderController
        ├─ DraftOrderService.confirmDraft()
        │  ├─ Fetch DraftOrder
        │  ├─ Create Order from draft
        │  ├─ Update stock
        │  ├─ Create Receivable (if credit)
        │  └─ Mark DraftOrder.status = CONFIRMED
        └─ Return Order { id, status: CONFIRMED }
```

### 3.4 Dashboard Report

```
Owner (Web Admin)
     │
     ├─ GET /reports/dashboard?from=2025-01-01&to=2025-01-31 (JWT token)
     │
     └─ Backend: ReportController
        ├─ ReportService.getDashboard()
        │  ├─ SUM(Order.total) for Revenue (from Redis cache)
        │  ├─ SUM(Debt.amount) - SUM(Payment.amount) for Outstanding
        │  ├─ SUM(Inventory.quantity) for Stock overview
        │  └─ List top products by sales
        └─ Return DashboardDTO { revenue, outstanding, stock, topProducts }
```

---

## 4. Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Language** | Java 21 | Main programming language |
| **Framework** | Spring Boot 3.x | Web framework & DI |
| **Security** | Spring Security + JWT | Authentication & authorization |
| **Database** | MySQL 8.0 / PostgreSQL 15 | Primary data store |
| **Migration** | Flyway | Database version control |
| **Cache** | Redis | Session, dashboard cache |
| **Async/WebSocket** | Spring WebSocket (STOMP) | Realtime notification |
| **AI Integration** | HTTP Client (OkHttp/RestTemplate) | Call Gemini API |
| **File Storage** | Local Disk / S3-compatible | Invoice & product images |
| **Validation** | Jakarta Bean Validation | DTO & entity validation |
| **Logging** | SLF4J + Logback | Application logging |
| **Testing** | JUnit 5 + Mockito | Unit & integration tests |

---

## 5. Key Features Implemented

### ✅ Phase 1 (MVP)
- [x] User authentication (Login/Register)
- [x] JWT Token generation & validation
- [x] Role-based access control (ADMIN/OWNER/EMPLOYEE)
- [x] CRUD Products (Owner only)
- [x] CRUD Customers
- [x] CRUD Orders (create/confirm/cancel)
- [x] Stock management (basic)
- [x] Debt tracking

### ⏳ Phase 2 (Enhancement)
- [ ] AI Draft Order (Gemini integration)
- [ ] Advanced stock adjustments (stock-in, stock-adjust)
- [ ] Payment tracking & reconciliation
- [ ] Real-time WebSocket notifications
- [ ] Invoice generation (PDF)
- [ ] Report templates (Thông tư 88 compliance)

### 🔮 Phase 3 (Optimization)
- [ ] Redis caching (dashboard, product catalog)
- [ ] Subscription management (Admin)
- [ ] Activity logging & audit trail
- [ ] Voice order input (Whisper integration)
- [ ] Advanced analytics & forecasting

---

## 6. Database Overview

### Core Tables

| Entity | Purpose |
|--------|---------|
| `users` | User accounts (ADMIN/OWNER/EMPLOYEE) |
| `stores` | Business locations (multi-tenant support) |
| `roles` | Role definitions |
| `permissions` | Permission mapping |
| `products` | Product catalog |
| `customers` | Customer records |
| `orders` | Sales orders |
| `order_items` | Order line items |
| `inventory` | Stock levels |
| `stock_movements` | Stock in/out history |
| `debts` | Customer receivables |
| `payments` | Payment records |
| `draft_orders` | AI-generated draft orders |

---

## 7. API Endpoint Categories

### Authentication
- `POST /auth/login` - Login & get JWT
- `POST /auth/refresh` - Refresh token
- `POST /auth/logout` - Logout

### Products (Owner)
- `GET /products` - List all
- `POST /products` - Create
- `PUT /products/{id}` - Update
- `DELETE /products/{id}` - Delete

### Customers
- `GET /customers` - List
- `POST /customers` - Create
- `PUT /customers/{id}` - Update

### Orders (Employee/Owner)
- `GET /orders` - List
- `POST /orders` - Create
- `POST /orders/{id}/confirm` - Confirm
- `POST /orders/{id}/cancel` - Cancel

### Inventory (Owner)
- `GET /inventory` - List stock
- `POST /inventory/stock-in` - Add stock
- `POST /inventory/adjust` - Adjust quantity

### Debts & Payments
- `GET /debts` - Outstanding receivables
- `POST /payments` - Record payment
- `GET /debts/{customerId}` - Customer debt history

### Reports
- `GET /reports/dashboard` - Revenue, outstanding, stock
- `GET /reports/sales` - Sales summary
- `GET /reports/inventory` - Inventory report

### AI Draft Order
- `POST /ai/draft-order` - Create draft from AI
- `POST /orders/confirm-draft/{draftId}` - Confirm draft → create order

---

## 8. Deployment Overview

### Development
- MySQL (Docker)
- Redis (Docker)
- Spring Boot embedded Tomcat
- Hot reload with DevTools

### Production
- MySQL or PostgreSQL (managed database)
- Redis cluster for cache
- Tomcat or embedded container
- SSL/TLS encryption
- JWT secret key in environment variable
- Log aggregation (ELK stack optional)

---

## 9. Security Best Practices

1. **Password**: BCrypt hashing
2. **Token**: JWT with HS256 signing, 1 hour expiry
3. **CORS**: Whitelist origins (frontend URLs only)
4. **RBAC**: Fine-grained permission checks per endpoint
5. **SQL Injection**: Use JPA parameterized queries
6. **HTTPS**: Enforce in production
7. **Audit Logging**: Track sensitive operations (CREATE/UPDATE/DELETE)

---

## 10. Performance Targets

- **API Response Time**: < 200ms (average)
- **Dashboard Load**: < 500ms
- **Concurrent Users**: 1000+
- **Daily Transactions**: 10,000+

Cache strategy:
- Product catalog: 1 hour TTL
- Dashboard aggregates: 15 minutes TTL
- Session tokens: 1 hour TTL

---

## 11. Monitoring & Logging

- **Spring Boot Actuator**: `/actuator/health`, `/actuator/metrics`
- **Logback**: INFO level for production, DEBUG for development
- **Request logging**: Timestamp, method, path, response time, user

---

## 12. Reference Documents

- 📄 [backend-srs.md](./backend-srs.md) - Detailed requirements & use cases
- 📄 [backend-architecture.md](./backend-architecture.md) - Architecture decisions
- 📄 [api-documentation.md](./api-documentation.md) - API endpoints reference
- 🗂️ [/src/main/java/com/bizflow/backend](../../src/main/java/com/bizflow/backend) - Source code
- 📋 [pom.xml](../../pom.xml) - Maven dependencies

---

**Last Updated**: December 13, 2025  
**Author**: Backend Team BizFlow  
**Version**: 1.0.0
