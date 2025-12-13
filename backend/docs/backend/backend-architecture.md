# 🏗️ BizFlow Backend Architecture Design

## 1. Layered Architecture Overview

### 1.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER (Web/Mobile)               │
│                  (NextJS / Flutter)                         │
└──────────────────────────────┬──────────────────────────────┘
                               │
                          HTTP/REST
                               │
┌──────────────────────────────▼──────────────────────────────┐
│               PRESENTATION LAYER (Port 8080)                │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│ │ @RestController  │ WebSocket    │  │ Exception Handler │   │
│ │ - AuthController │ Handler      │  │ GlobalExceptionH │   │
│ │ - OrderCtrl      │              │  │ - 400 Bad Req    │   │
│ │ - ProductCtrl    │ /ws/notify   │  │ - 401 Unauth     │   │
│ │ - etc.           │              │  │ - 403 Forbidden  │   │
│ └──────────────┘  └──────────────┘  │ - 404 Not Found  │   │
│                                       │ - 500 Server Err │   │
│                                       └──────────────────┘   │
│ ┌────────────────────────────────────────────────────────┐  │
│ │ Security Filter Chain                                │  │
│ │ - CorsFilter → JwtRequestFilter → AuthnFilter       │  │
│ └────────────────────────────────────────────────────────┘  │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│               APPLICATION LAYER (Services)                   │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ USE CASES (Interfaces)                                  │ │
│ │ - UserService                                           │ │
│ │ - ProductService                                        │ │
│ │ - OrderService                                          │ │
│ │ - InventoryService                                      │ │
│ │ - DebtService                                           │ │
│ │ - ReportService                                         │ │
│ │ - AIGatewayService                                      │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ IMPLEMENTATIONS (@Service)                              │ │
│ │ - UserServiceImpl                                        │ │
│ │ - ProductServiceImpl                                     │ │
│ │ - (etc.)                                                │ │
│ │                                                          │ │
│ │ MAPPERS (DTOℌ↔ Entity)                                  │ │
│ │ - ProductMapper                                         │ │
│ │ - OrderMapper                                           │ │
│ │ - (etc.)                                                │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ VALIDATORS                                              │ │
│ │ - @Valid on DTOs                                        │ │
│ │ - Custom validators                                     │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│               DOMAIN LAYER (Business Logic)                  │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ ENTITIES (@Entity)                                      │ │
│ │ - User                                                  │ │
│ │ - Product                                               │ │
│ │ - Order, OrderItem                                      │ │
│ │ - Customer                                              │ │
│ │ - Inventory, StockMovement                              │ │
│ │ - Debt, Payment                                         │ │
│ │ - DraftOrder                                            │ │
│ │ - Subscription                                          │ │
│ │ - Store, Role, Permission                               │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ DOMAIN SERVICES (Pure business logic)                   │ │
│ │ - OrderDomainService (calculate price, etc)             │ │
│ │ - StockDomainService (reserve stock, etc)               │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ VALUE OBJECTS                                           │ │
│ │ - Money (amount, currency)                              │ │
│ │ - Quantity (value, unit)                                │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│           INFRASTRUCTURE LAYER (Technical Details)           │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ PERSISTENCE (@Repository)                               │ │
│ │ - UserRepository extends JpaRepository<User, Long>       │ │
│ │ - ProductRepository                                      │ │
│ │ - OrderRepository                                        │ │
│ │ - (etc. for all entities)                               │ │
│ │                                                          │ │
│ │ CUSTOM QUERIES (jpql, native)                           │ │
│ │ - findByCustomer(...)                                   │ │
│ │ - findOutstandingDebts(...)                             │ │
│ │ - findDailyRevenue(...)                                 │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ CONFIGURATION                                           │ │
│ │ - SecurityConfig (JWT, RBAC)                            │ │
│ │ - AppConfig (Beans: PasswordEncoder, etc)               │ │
│ │ - CacheConfig (Redis)                                   │ │
│ │ - WebSocketConfig (STOMP/SockJS)                        │ │
│ │ - JacksonConfig (JSON serialization)                    │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ EXTERNAL SERVICES CLIENTS                               │ │
│ │ - AIGatewayClient (call Gemini API)                     │ │
│ │ - FirebaseClient (push notifications)                   │ │
│ │ - FileStorageClient (S3 / Local disk)                   │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│            EXTERNAL SYSTEMS & DATABASES                      │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ PRIMARY DATABASE                                        │ │
│ │ - MySQL 8.0 (prod: RDS / Dev: Docker)                  │ │
│ │ - Tables: users, products, orders, inventory, etc       │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ CACHE (Redis)                                           │ │
│ │ - session data                                          │ │
│ │ - product catalog (TTL: 1 hour)                         │ │
│ │ - dashboard metrics (TTL: 15 min)                       │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ FILE STORAGE                                            │ │
│ │ - Local disk / S3 (invoice PDFs, product images)        │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ EXTERNAL APIs                                           │ │
│ │ - Google Gemini (AI text parsing)                       │ │
│ │ - Google Cloud Speech-to-Text (voice input)             │ │
│ │ - Firebase (push notifications)                         │ │
│ └──────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Package Structure & Responsibilities

### 2.1 Package Layout

```
src/main/java/com/bizflow/backend/
├── BizFlowBackendApplication.java        ← Spring Boot entry point
│
├── config/
│   ├── SecurityConfig.java               ← JWT, CORS, RBAC
│   ├── AppConfig.java                    ← Beans (PasswordEncoder, etc.)
│   ├── CacheConfig.java                  ← Redis cache configuration
│   ├── WebSocketConfig.java              ← WebSocket/STOMP setup
│   └── JacksonConfig.java                ← JSON serialization
│
├── core/
│   ├── domain/
│   │   ├── User.java                     ← @Entity
│   │   ├── Product.java
│   │   ├── Order.java, OrderItem.java
│   │   ├── Customer.java
│   │   ├── Inventory.java, StockMovement.java
│   │   ├── Debt.java, Payment.java
│   │   ├── DraftOrder.java
│   │   ├── Subscription.java
│   │   ├── Store.java
│   │   ├── Role.java, Permission.java
│   │   └── AuditLog.java
│   │
│   ├── usecase/
│   │   ├── UserService.java              ← Interface
│   │   ├── ProductService.java
│   │   ├── OrderService.java
│   │   ├── InventoryService.java
│   │   ├── DebtService.java
│   │   ├── ReportService.java
│   │   ├── SubscriptionService.java
│   │   ├── AIGatewayService.java
│   │   └── (impl folders with @Service classes)
│   │
│   └── exception/
│       ├── BusinessException.java        ← Custom exceptions
│       ├── ValidationException.java
│       ├── NotFoundException.java
│       └── UnauthorizedException.java
│
├── infrastructure/
│   ├── persistence/
│   │   └── repository/
│   │       ├── UserRepository.java       ← JpaRepository
│   │       ├── ProductRepository.java
│   │       ├── OrderRepository.java
│   │       ├── CustomerRepository.java
│   │       ├── InventoryRepository.java
│   │       ├── DebtRepository.java
│   │       ├── PaymentRepository.java
│   │       ├── DraftOrderRepository.java
│   │       └── (more repositories)
│   │
│   ├── cache/
│   │   └── CacheService.java             ← Redis operations
│   │
│   ├── file/
│   │   ├── FileService.java              ← Upload/download
│   │   └── InvoiceGenerator.java         ← PDF generation
│   │
│   ├── ai/
│   │   └── AIGatewayClient.java          ← Gemini API calls
│   │
│   ├── notification/
│   │   ├── NotificationService.java      ← WebSocket/Firebase
│   │   └── NotificationHandler.java
│   │
│   └── external/
│       ├── FirebaseClient.java
│       └── S3Client.java
│
├── presentation/
│   ├── controller/
│   │   ├── AuthController.java           ← Login/Register
│   │   ├── UserController.java           ← User CRUD
│   │   ├── ProductController.java
│   │   ├── OrderController.java
│   │   ├── CustomerController.java
│   │   ├── InventoryController.java
│   │   ├── DebtController.java
│   │   ├── ReportController.java
│   │   ├── SubscriptionController.java
│   │   ├── AIController.java
│   │   └── FileController.java
│   │
│   ├── dto/
│   │   ├── request/
│   │   │   ├── LoginRequest.java
│   │   │   ├── CreateProductRequest.java
│   │   │   ├── CreateOrderRequest.java
│   │   │   └── (more request DTOs)
│   │   ├── response/
│   │   │   ├── ApiResponse.java          ← Wrapper for all responses
│   │   │   ├── LoginResponse.java
│   │   │   ├── ProductResponse.java
│   │   │   ├── OrderResponse.java
│   │   │   └── (more response DTOs)
│   │   └── mapper/
│   │       ├── ProductMapper.java
│   │       ├── OrderMapper.java
│   │       └── (more mappers)
│   │
│   ├── filter/
│   │   ├── JwtRequestFilter.java         ← JWT validation
│   │   └── CorsFilter.java
│   │
│   ├── handler/
│   │   ├── GlobalExceptionHandler.java   ← @ExceptionHandler
│   │   ├── WebSocketHandler.java         ← WebSocket events
│   │   └── ValidationHandler.java
│   │
│   └── validator/
│       ├── OrderValidator.java
│       └── ProductValidator.java
│
└── util/
    ├── JwtUtil.java                      ← Token generation/validation
    ├── PaginationUtil.java               ← Page & sort
    ├── CurrencyUtil.java                 ← Vietnamese currency formatting
    └── DateUtil.java
```

---

## 3. Dependency Rules (Clean Architecture)

### 3.1 Layer Dependencies

**STRICT Rule**: Higher layers CAN ONLY call lower layers.

```
Presentation → Application → Domain ← Infrastructure
                   ↓
            (uses exceptions
             from Domain)

Infrastructure CANNOT depend on Presentation
Domain CANNOT depend on any other layer
```

### 3.2 Concrete Rules

| Layer | Can Depend On | Cannot Depend On |
|-------|---------------|-----------------|
| **Presentation (Controller, DTO)** | Application (Service), Util | Domain (except exception) |
| **Application (Service, Mapper)** | Domain, Infrastructure | Presentation |
| **Domain (Entity, UseCase Interface)** | Nothing (self-contained) | Any layer |
| **Infrastructure (Repository, Config)** | Domain | Presentation, Application |

### 3.3 Example: OrderService

**❌ WRONG**:
```java
// ❌ OrderService should NOT call OrderRepository directly
@Service
public class OrderService {
    @Autowired private OrderRepository repo;
    
    public Order createOrder(OrderRequest req) {
        // Business logic mixed with DB calls
        Order order = new Order();
        return repo.save(order);  // ❌ Direct repo call
    }
}
```

**✅ CORRECT**:
```java
// ✅ OrderService (usecase) delegates to repository via port interface
@Service
public class OrderServiceImpl implements OrderService {
    @Autowired private OrderPort orderPort;  // Abstraction
    @Autowired private StockPort stockPort;
    
    @Override
    @Transactional
    public Order createOrder(CreateOrderRequest req) {
        // 1. Validate
        validateOrder(req);
        
        // 2. Business logic
        Order order = new Order();
        order.setCustomerId(req.getCustomerId());
        order.setTotal(calculateTotal(req.getItems()));
        
        // 3. Call ports (abstraction)
        order = orderPort.save(order);
        
        // 4. Side effects
        for (OrderItem item : req.getItems()) {
            stockPort.reduceStock(item.getProductId(), item.getQuantity());
        }
        
        return order;
    }
}

// Port interface (Domain layer)
public interface OrderPort {
    Order save(Order order);
}

// Implementation (Infrastructure layer)
@Repository
public class OrderRepositoryImpl implements OrderPort {
    @Autowired private OrderRepository jpaRepo;
    
    @Override
    public Order save(Order order) {
        return jpaRepo.save(order);
    }
}
```

---

## 4. Caching Strategy

### 4.1 Cache Layers

```
┌──────────────────────────────┐
│   CLIENT (Browser/Mobile)     │  [HTTP Cache headers]
└────────────────┬─────────────┘
                 │
┌────────────────▼─────────────┐
│     APPLICATION LEVEL        │  [Spring Cache]
│     (ProductService)          │
└────────────────┬─────────────┘
                 │
            @Cacheable("products")
                 │
┌────────────────▼─────────────┐
│   DISTRIBUTED CACHE          │  [Redis]
│   (Shared across instances)   │
│   TTL: 1 hour for catalog     │
│   TTL: 15 min for dashboard   │
└────────────────┬─────────────┘
                 │
┌────────────────▼─────────────┐
│   DATABASE (MySQL/Postgres)   │  [Primary source of truth]
└──────────────────────────────┘
```

### 4.2 Caching Policy

| Data | Cache Type | TTL | Invalidation |
|------|-----------|-----|--------------|
| **Product Catalog** | Redis | 1 hour | On product create/update/delete |
| **Product Stock** | Redis | 5 min | After every stock movement |
| **Dashboard Metrics** | Redis | 15 min | On order create/payment/stock change |
| **User Permissions** | Redis | 30 min | On role/permission change |
| **Session/JWT** | (Session) | Token expiry | Manual logout |
| **Customer Debt** | Redis | 10 min | After payment |

### 4.3 Cache Invalidation Strategy

**Event-Driven Invalidation**:
```java
@Service
public class ProductServiceImpl implements ProductService {
    @Autowired private CacheManager cacheManager;
    
    @Override
    public Product updateProduct(Long id, UpdateProductRequest req) {
        Product product = productRepository.findById(id).orElseThrow();
        product.setName(req.getName());
        product = productRepository.save(product);
        
        // Invalidate cache
        cacheManager.getCache("products").evict(id);
        cacheManager.getCache("productList").clear();  // Invalidate list cache
        
        return product;
    }
}
```

---

## 5. Security Architecture

### 5.1 Authentication Flow (JWT)

```
Client: POST /auth/login { username, password }
        │
        ▼
Backend: AuthController
        ├─ AuthenticationManager.authenticate()
        │  └─ UserDetailsService.loadUserByUsername() [fetch user from DB]
        │  └─ PasswordEncoder.matches(password, hashedPassword) [verify]
        │
        ├─ JwtUtil.generateToken(userDetails)
        │  └─ Sign token with HS256 secret key
        │  └─ Add claims: username, role, permissions
        │
        └─ Return { accessToken, refreshToken (optional), expiresIn }

Client: Store token in localStorage/SharedPreferences

Client: GET /products + header "Authorization: Bearer <token>"
        │
        ▼
Backend: JwtRequestFilter
        ├─ Extract token from header
        ├─ JwtUtil.validateToken(token)
        │  └─ Verify signature
        │  └─ Check expiry
        │
        ├─ Extract claims (username, role)
        ├─ Load UserDetails
        ├─ SecurityContextHolder.setAuthentication(auth)
        │
        └─ Chain proceeds to Controller

Backend: ProductController.listProducts()
        ├─ SecurityConfig: @PreAuthorize("hasRole('OWNER')")
        │  └─ Check if user role includes OWNER
        │
        └─ If authorized: execute; if not: 403 Forbidden
```

### 5.2 Authorization Patterns

**Option A: Role-based (@PreAuthorize)**
```java
@GetMapping
@PreAuthorize("hasRole('OWNER') or hasRole('EMPLOYEE')")
public ResponseEntity<?> listProducts(@RequestParam int page) {
    // Both OWNER and EMPLOYEE can call
}
```

**Option B: Permission-based (Fine-grained)**
```java
@PostMapping
@PreAuthorize("hasAuthority('PRODUCT_CREATE')")
public ResponseEntity<?> createProduct(@RequestBody CreateProductRequest req) {
    // Only users with PRODUCT_CREATE permission
}
```

**Option C: Custom annotation**
```java
@PostMapping
@RequireRole(Role.OWNER)
@RequirePermission(Permission.PRODUCT_CREATE)
public ResponseEntity<?> createProduct(@RequestBody CreateProductRequest req) {
    // Combined role + permission check
}
```

### 5.3 Multi-Tenant Isolation

**Problem**: Employee of Store A should NOT see data of Store B

**Solution**: Include `storeId` in JWT claims + filter all queries
```java
@Component
public class JwtRequestFilter extends OncePerRequestFilter {
    
    @Override
    protected void doFilterInternal(HttpServletRequest req, ...) {
        // Extract storeId from JWT
        String storeId = jwtUtil.extractStoreClaim(token);
        
        // Store in SecurityContext for later access
        StoreContext.setCurrentStore(storeId);
    }
}

@Service
public class ProductServiceImpl {
    @Autowired private ProductRepository repo;
    
    public List<Product> listProducts() {
        Long storeId = StoreContext.getCurrentStore();
        
        // Filter by current user's store
        return repo.findByStoreId(storeId);
    }
}
```

---

## 6. Transaction Management

### 6.1 Transaction Boundaries

**Complex Business Operation** = 1 Transaction

```java
@Service
public class OrderServiceImpl implements OrderService {
    
    @Autowired private OrderRepository orderRepo;
    @Autowired private StockRepository stockRepo;
    @Autowired private DebtRepository debtRepo;
    @Autowired private EventPublisher eventPublisher;
    
    @Override
    @Transactional  // ← Everything in this method is 1 atomic transaction
    public Order createOrder(CreateOrderRequest req) {
        // 1. Create Order
        Order order = new Order();
        order.setCustomerId(req.getCustomerId());
        order.setTotal(calculateTotal(req.getItems()));
        order = orderRepo.save(order);
        
        // 2. Reduce Stock (all items)
        for (OrderRequest.Item item : req.getItems()) {
            Stock stock = stockRepo.findByProductId(item.getProductId())
                .orElseThrow();
            
            if (stock.getQuantity() < item.getQuantity()) {
                throw new InsufficientStockException(...);  // Rollback all
            }
            
            stock.setQuantity(stock.getQuantity() - item.getQuantity());
            stockRepo.save(stock);
        }
        
        // 3. Create Debt (if credit)
        if (req.getPaymentType() == PaymentType.CREDIT) {
            Debt debt = new Debt();
            debt.setCustomerId(req.getCustomerId());
            debt.setAmount(order.getTotal());
            debtRepo.save(debt);
        }
        
        // 4. Publish event (AFTER transaction commits)
        eventPublisher.publishOrderCreated(order.getId());
        
        return order;
        // ← If any exception: rollback all 1, 2, 3
        // ← If all success: commit all
    }
}
```

### 6.2 Propagation & Isolation

| Scenario | Propagation | Isolation Level |
|----------|------------|-----------------|
| **OrderService calls StockService** | REQUIRED | READ_COMMITTED |
| **ReportService (long-running)** | REQUIRES_NEW | SERIALIZABLE |
| **Logging (not critical)** | REQUIRES_NEW | READ_UNCOMMITTED |

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void auditLog(String action) {
    // Commit independently
}
```

---

## 7. API Response Pattern

### 7.1 Universal Response Wrapper

```
┌─────────────────────────────────┐
│      ApiResponse<T>             │
├─────────────────────────────────┤
│ + code: int (1000, 400, 401...) │
│ + message: String               │
│ + result: T (generic)           │
│ + timestamp: LocalDateTime      │
│ + errors: List<Error>           │
└─────────────────────────────────┘
```

**Success Response (200 OK)**:
```json
{
  "code": 1000,
  "message": "Success",
  "result": { "id": 1, "name": "Xi măng", ... },
  "timestamp": "2025-01-01T10:30:00Z",
  "errors": null
}
```

**Error Response (400 Bad Request)**:
```json
{
  "code": 4000,
  "message": "Validation error",
  "result": null,
  "timestamp": "2025-01-01T10:30:00Z",
  "errors": [
    { "field": "name", "message": "must not be blank" },
    { "field": "price", "message": "must be greater than 0" }
  ]
}
```

**Unauthorized (401)**:
```json
{
  "code": 4010,
  "message": "Invalid or expired token",
  "result": null,
  "timestamp": "2025-01-01T10:30:00Z"
}
```

### 7.2 Error Code Convention

| Range | Category | Example |
|-------|----------|---------|
| 1000 | Success | 1000 (OK) |
| 2000 | Informational | 2000 (No content) |
| 4000 | Client Error - Validation | 4000 (Invalid input) |
| 4010 | Client Error - Auth | 4010 (Invalid token) |
| 4030 | Client Error - Permission | 4030 (Forbidden) |
| 4040 | Client Error - Not Found | 4040 (Resource not found) |
| 5000 | Server Error | 5000 (Internal error) |

---

## 8. Event-Driven Architecture

### 8.1 Event Publishing & Listening

```
OrderService.createOrder()
    │
    ├─ Save to DB
    │
    ├─ Publish: OrderCreatedEvent
    │  │
    │  ├─→ StockService.onOrderCreated() [reduce stock]
    │  │
    │  ├─→ NotificationService.onOrderCreated() [send WebSocket event]
    │  │
    │  └─→ ReportService.onOrderCreated() [invalidate cache]
    │
    └─ Return Order
```

**Implementation** (Spring Events):
```java
// Event definition
public class OrderCreatedEvent extends ApplicationEvent {
    private Order order;
    
    public OrderCreatedEvent(Object source, Order order) {
        super(source);
        this.order = order;
    }
}

// Publisher
@Service
public class OrderServiceImpl {
    @Autowired private ApplicationEventPublisher eventPublisher;
    
    public Order createOrder(...) {
        Order order = orderRepository.save(new Order());
        eventPublisher.publishEvent(new OrderCreatedEvent(this, order));
        return order;
    }
}

// Listener 1
@Service
public class StockServiceImpl {
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        // Reduce stock
    }
}

// Listener 2
@Service
public class NotificationServiceImpl {
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        // Send WebSocket notification
    }
}
```

---

## 9. Monitoring & Observability

### 9.1 Logging Strategy

```
Level | Usage | Output |
------|-------|--------|
DEBUG | Development: detailed method entry/exit | console, file |
INFO  | Production: key milestones (login, order create) | file, centralized logging |
WARN  | Recoverable issues (retry, fallback) | alert system |
ERROR | Unrecoverable issues (DB connection fail) | alert + incident ticket |
```

**Example**:
```java
@Service
public class OrderServiceImpl {
    private static final Logger logger = LoggerFactory.getLogger(...);
    
    public Order createOrder(CreateOrderRequest req) {
        logger.info("Creating order for customer={}, items_count={}", 
            req.getCustomerId(), req.getItems().size());
        
        try {
            Order order = orderRepository.save(...);
            logger.info("Order created successfully: orderId={}, total={}", 
                order.getId(), order.getTotal());
            return order;
            
        } catch (InsufficientStockException e) {
            logger.error("Insufficient stock for order creation", e);
            throw e;
        }
    }
}
```

### 9.2 Metrics (Spring Boot Actuator)

**Exposed Endpoints**:
- `GET /actuator/health` → DB, cache, app status
- `GET /actuator/metrics` → JVM memory, GC, HTTP requests
- `GET /actuator/metrics/http.server.requests` → API latency by endpoint

---

## 10. Database Design Principles

### 10.1 Schema Guidelines

- **Naming**: snake_case for tables & columns
- **Primary Key**: `id` (BIGINT auto-increment)
- **Timestamps**: `created_at`, `updated_at` (UTC, nullable)
- **Audit**: `created_by`, `updated_by` (user ID)
- **Soft Delete**: `deleted_at` (nullable) instead of physical deletion
- **Indexes**: On frequently queried columns (FK, search fields, date ranges)

### 10.2 Relationships

| Relation | Example | Type |
|----------|---------|------|
| **One-to-Many** | User → Orders | `user_id` FK in orders table |
| **Many-to-Many** | Role ↔ Permission | Separate `role_permissions` junction table |
| **One-to-One** | User ↔ Store | `user_id` unique FK in stores table |

---

## 11. Testing Strategy

### 11.1 Test Pyramid

```
         ▲
        /│\
       / │ \
      /  │  \       E2E Tests (few)
     /   │   \      - Full flow: login → create order → payment
    /    │    \     - Selenium/Postman
   ┌─────┴─────┐
   │     │     │     Integration Tests (medium)
   │     │     │     - AuthController + UserService + DB
   │     │     │     - OrderService + repositories
   │     │     │
   └─────┼─────┘
         │         Unit Tests (many)
         │         - Service/Service impl logic
         │         - DTO validation
         │         - Util/Helper methods
         ▼
```

### 11.2 Test File Organization

```
src/test/java/com/bizflow/backend/
├── unit/
│   ├── core/usecase/
│   │   ├── UserServiceTest.java
│   │   ├── ProductServiceTest.java
│   │   └── OrderServiceTest.java
│   ├── infrastructure/cache/
│   │   └── CacheServiceTest.java
│   └── util/
│       └── JwtUtilTest.java
│
├── integration/
│   ├── controller/
│   │   ├── AuthControllerTest.java
│   │   ├── ProductControllerTest.java
│   │   └── OrderControllerTest.java
│   └── repository/
│       ├── UserRepositoryTest.java
│       └── OrderRepositoryTest.java
│
└── e2e/
    └── OrderE2ETest.java
```

---

## 12. Deployment Architecture

### 12.1 Environment Progression

```
Development (Local)
    ├─ MySQL (Docker)
    ├─ Redis (Docker)
    └─ Spring Boot (embedded Tomcat)

Staging (Pre-production)
    ├─ MySQL (Managed RDS)
    ├─ Redis (ElastiCache)
    └─ Spring Boot (container)

Production
    ├─ MySQL (RDS Multi-AZ)
    ├─ Redis (ElastiCache cluster)
    └─ Spring Boot (load balanced, auto-scaling)
```

### 12.2 Configuration Management

```
application.properties (default)
├── application-dev.properties
├── application-staging.properties
└── application-prod.properties

Environment Variables (override properties):
    ├─ DB_URL
    ├─ DB_USERNAME
    ├─ DB_PASSWORD
    ├─ JWT_SECRET
    ├─ REDIS_URL
    ├─ GEMINI_API_KEY
    └─ AWS_ACCESS_KEY / AWS_SECRET_KEY
```

---

**Last Updated**: December 13, 2025  
**Version**: 1.0.0  
**Status**: Active
