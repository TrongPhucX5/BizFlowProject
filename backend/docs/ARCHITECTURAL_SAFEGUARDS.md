# 🏗️ BizFlow Backend - Architectural Safeguards

## 📋 Overview

Đây là document chi tiết cách khắc phục **3 Critical Rủi ro** được nhận xét bởi Senior Architect:

1. ✅ **Multi-tenancy chỉ ở ý tưởng** → Thực thi bắt buộc via UserContext
2. ✅ **Service layer phình to** → Tách responsibility rõ ràng
3. ✅ **Security đang là nút thắt** → Hoàn thành JWT + RBAC

---

## 🚨 Rủi ro #1: Multi-tenancy Vulnerability

### Problem (Nguy hiểm)
```java
// ❌ SAI: Này sẽ leak dữ liệu giữa các store!
productRepository.findAll();  // Lấy ALL products từ DB

// Hacker có thể manipulate storeId trong request
curl -X GET http://localhost:8080/api/v1/products?storeId=999
// → Có thể nhìn thấy products của cửa hàng khác!
```

### Solution: UserContext Helper
```java
// ✅ ĐÚNG: Lấy storeId từ JWT token (không thể giả mạo)
Long storeId = UserContext.getCurrentStoreId();
productRepository.findByStoreId(storeId);
```

**File**: `core/common/UserContext.java`

```java
public class UserContext {
    public static Long getCurrentStoreId() {
        // Extract storeId from JWT token (SecurityContext)
        // If user not authenticated → throw UnauthorizedException
        // Never trust request parameter!
    }
}
```

### Why This Works?

**Architecture Flow:**
```
1. Client sends JWT token in Authorization header
   Authorization: Bearer eyJhbGc...

2. JwtRequestFilter intercepts request
   - Validate token signature
   - Extract userId, storeId, role from token claims
   - Create CustomUserDetails
   - Set into SecurityContext

3. Service layer calls UserContext.getCurrentStoreId()
   - Safely retrieve storeId from SecurityContext (JWT)
   - Never from request parameter

4. Repository filters all queries by storeId
   - Store A user can ONLY see Store A data
   - Technically impossible to access other store's data
```

### Enforcement Patterns

**Pattern 1: All Repositories must have store-filtered methods**
```java
// Repository MUST have these methods:
Optional<Product> findByIdAndStoreId(Long id, Long storeId);
List<Product> findAllByStoreId(Long storeId);

// NOT allowed:
// Optional<Product> findById(Long id);  ← NO! Can leak data
```

**Pattern 2: Service ALWAYS uses store-filtered methods**
```java
@Service
public class ProductService {
    public ProductDTO getProduct(Long id) {
        Long storeId = UserContext.getCurrentStoreId();  // ← MUST do this
        Product product = productRepository.findByIdAndStoreId(id, storeId)
                .orElseThrow();  // Will be null if doesn't belong to store
        return mapper.toDTO(product);
    }
}
```

**Pattern 3: Every CREATE/UPDATE must set storeId from UserContext**
```java
@Transactional
public ProductDTO createProduct(CreateProductRequest req) {
    Long storeId = UserContext.getCurrentStoreId();  // ← MUST do this
    
    Product product = Product.builder()
            .storeId(storeId)  // ← NOT from request.getStoreId()!
            .name(req.getName())
            .sku(req.getSku())
            .price(req.getPrice())
            .build();
    
    return mapper.toDTO(productRepository.save(product));
}
```

---

## 🚨 Rủi ko #2: Service Layer Bloat

### Problem (Anti-pattern)
```java
// ❌ SAI: 300-line god object method
@Service
public class OrderService {
    public void createOrder(CreateOrderRequest req) {
        // ... 300 lines of mixed concerns
        // - validation logic
        // - calculation logic
        // - database queries
        // - external API calls
        // - notification logic
        // All jumbled together
    }
}
```

**Problems:**
- Hard to test (dependencies jumbled)
- Hard to reuse (logic scattered)
- Hard to maintain (what does it do?)
- Hard to debug (where's the bug?)

### Solution: Separation of Concerns
```java
// ✅ ĐÚNG: Each private method has single responsibility
@Service
@RequiredArgsConstructor
public class OrderService {
    
    // PUBLIC: Main business operation
    @Transactional
    public OrderDTO createOrder(CreateOrderRequest req) {
        Long storeId = UserContext.getCurrentStoreId();
        
        Customer customer = validateCustomerExists(req.getCustomerId(), storeId);
        List<OrderItemData> items = checkAndBuildOrderItems(req.getItems(), storeId);
        BigDecimal total = calculateTotal(items);
        Order order = buildOrder(storeId, customer.getId(), total, req);
        Order saved = orderRepository.save(order);
        persistOrderItems(saved.getId(), items);
        reduceInventory(storeId, items, saved.getId());
        createDebtRecord(storeId, saved);
        
        return mapToDTO(saved);
    }
    
    // PRIVATE VALIDATION: Check data correctness
    private Customer validateCustomerExists(Long customerId, Long storeId) {
        // Single job: Validate customer exists & belongs to store
    }
    
    // PRIVATE CALCULATION: Business logic calculations
    private BigDecimal calculateTotal(List<OrderItemData> items) {
        // Single job: Calculate subtotal + discount
    }
    
    // PRIVATE CONSTRUCTION: Build entities
    private Order buildOrder(...) {
        // Single job: Create Order entity from validated data
    }
    
    // PRIVATE PERSISTENCE: Save to database
    private void persistOrderItems(...) {
        // Single job: Save OrderItem records
    }
    
    // PRIVATE SIDE-EFFECT: Inventory reduction
    private void reduceInventory(...) {
        // Single job: Update stock + create audit trail
    }
}
```

### Responsibility Breakdown

| Method | Purpose | Input | Output |
|--------|---------|-------|--------|
| `validateXxx()` | Data validation | Request data | Validated entity or exception |
| `checkXxx()` | Business rule check | Data to check | true/false or exception |
| `buildXxx()` | Entity construction | DTO/request | Built entity |
| `calculateXxx()` | Business calculation | Input data | Calculated result |
| `persistXxx()` | Database saving | Entity | Saved entity |
| `reduceXxx()` | Side effects | Data | Effects applied |
| `mapToDTO()` | DTO conversion | Entity | DTO |

### Why This Works?

**Testability:**
```java
// Easy to unit test each method independently
@Test
void testValidateCustomer_InvalidStore_ThrowsException() {
    // Mock dependencies
    // Test only validation logic
}

@Test
void testCalculateTotal_WithDiscount() {
    // Test only calculation logic
}
```

**Reusability:**
```java
// Other services can reuse private methods? No!
// But they can extract to shared utilities:

@Component
public class InventoryHelper {
    public void reduceStock(Long storeId, List<OrderItemData> items) {
        // Shared reduction logic
    }
}
```

**Maintainability:**
```java
// Easy to find and fix bugs
// Example: Bug in inventory reduction?
// → Look at reduceInventory() method only
```

---

## 🚨 Rủi ko #3: Security as Blocking Point

### Problem (Dependency Block)
```
Service Layer Implementation
    ↓ (depends on UserContext)
Security Layer (JWT Filter + UserContext)
    ↓ (not yet implemented)
Cannot write service tests without auth!
```

### Solution: Implement Security FIRST

**Done in this update:**

1. ✅ **CustomUserDetails.java** 
   - Holds user info extracted from JWT

2. ✅ **JwtUtil.java**
   - Generate & validate JWT tokens
   - Extract claims (userId, storeId, role)

3. ✅ **JwtRequestFilter.java**
   - Filter that runs on every request
   - Validates token
   - Populates SecurityContext

4. ✅ **UserContext.java**
   - Helper to extract user info from SecurityContext
   - Used by all services

5. ✅ **SecurityConfig.java (Enhanced)**
   - Integrated JwtRequestFilter
   - Configured stateless auth
   - Defined public/protected endpoints

### Auth Flow (Complete)

```
Request with JWT Token
    ↓
JwtRequestFilter
    ├─ Extract token from Authorization header
    ├─ Validate signature & expiration
    ├─ Extract claims (userId, storeId, role, username)
    ├─ Load user from database (verify active)
    ├─ Create CustomUserDetails
    └─ Set into SecurityContext
    ↓
SecurityContextHolder.getContext().getAuthentication()
    ↓
Service layer calls UserContext.getCurrentStoreId()
    ↓
Service has storeId → Can filter all database queries!
```

### Testing Flow

**With security implemented:**
```java
@Test
void testCreateOrder() {
    // 1. Setup test database data
    Store store = createTestStore();
    Customer customer = createTestCustomer(store);
    Product product = createTestProduct(store);
    
    // 2. Create JWT token for test user
    CustomUserDetails testUser = new CustomUserDetails(
        1L, store.getId(), "testuser", "pw", "OWNER", true
    );
    String token = jwtUtil.generateAccessToken(testUser);
    
    // 3. Call service (optionally with @WithMockUser or in test controller)
    // In unit test: Can inject UserContext mock
    // In integration test: Use MockMvc with token header
    
    OrderDTO result = orderService.createOrder(request);
    
    // 4. Verify order belongs to test store
    assertEquals(store.getId(), result.getStoreId());
}
```

---

## 📦 New Files Created (All 5 Critical Safeguards)

| File | Purpose | Status |
|------|---------|--------|
| **UserContext.java** | Extract user info from JWT (Safeguard #1) | ✅ Done |
| **CustomUserDetails.java** | Hold JWT claims in SecurityContext | ✅ Done |
| **JwtUtil.java** | Generate & validate tokens | ✅ Done |
| **JwtRequestFilter.java** | Process JWT on every request | ✅ Done |
| **SecurityConfig.java** | Spring Security configuration | ✅ Enhanced |
| **OrderService.java** | Example service impl (Safeguard #2) | ✅ Done |

---

## ✅ Verification Checklist

Before writing any Service layer code:

- [ ] **Multi-tenancy Safeguard**
  - [ ] All repositories have `findByXxxAndStoreId` methods
  - [ ] Services call `UserContext.getCurrentStoreId()`
  - [ ] Never trust storeId from request body

- [ ] **Service Structure Safeguard**
  - [ ] Public method ~30 lines (delegates to private methods)
  - [ ] Each private method ~15 lines (single responsibility)
  - [ ] Clear names: validate, check, build, calculate, persist, map

- [ ] **Security Safeguard**
  - [ ] Can generate JWT tokens (JwtUtil)
  - [ ] Can validate tokens (JwtRequestFilter)
  - [ ] Can extract user info (UserContext)
  - [ ] Can run tests with mock authentication

---

## 🎯 Next Steps

1. ✅ **Security Foundation** (DONE - this update)
2. 🔄 **Service Layer** (USE OrderService as template)
   - Copy OrderService pattern to other domains
   - Each service: validate → calculate → build → persist → side-effects

3. 🔄 **REST Controllers**
   - Inject service
   - Accept request → call service → return DTO
   - UserContext already has user info (from SecurityContext)

4. 🔄 **Tests**
   - Unit test each private service method
   - Integration test with MockMvc + token header

---

## 📚 Reference

### How to Add New Service (Using OrderService as Template)

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository productRepository;
    private final InventoryRepository inventoryRepository;
    
    // 1. Get storeId from UserContext
    // 2. Validate input
    // 3. Check business rules
    // 4. Build entity
    // 5. Persist to database
    // 6. Handle side effects
    // 7. Map to DTO
    // 8. Return
}
```

### How to Use in Controller

```java
@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<ProductDTO>> createProduct(
            @Valid @RequestBody CreateProductRequest req) {
        // Service has access to UserContext automatically
        ProductDTO result = productService.createProduct(req);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
```

### How SecurityContext is Populated (Behind the Scenes)

```
1. Client sends: GET /api/v1/products
   Header: Authorization: Bearer eyJhbGc...

2. JwtRequestFilter receives request
   ↓
3. Extract token = "eyJhbGc..."
   ↓
4. jwtUtil.validateToken(token) → true
   ↓
5. Extract from claims:
   userId = 123
   storeId = 456
   role = "OWNER"
   username = "owner1"
   ↓
6. Load user from database (verify still active)
   ↓
7. Create CustomUserDetails(123, 456, "owner1", ..., "OWNER", true)
   ↓
8. Create UsernamePasswordAuthenticationToken with CustomUserDetails
   ↓
9. Set into SecurityContextHolder
   ↓
10. Request continues → Controller → Service
    ↓
11. Service calls UserContext.getCurrentStoreId()
    ↓
12. UserContext extracts from SecurityContext
    ↓
13. Returns 456
```

---

## 🔒 Security Recap

**What's Protected:**
- ✅ Multi-tenancy: storeId from JWT only
- ✅ RBAC: Role checked via UserContext.hasRole()
- ✅ Data isolation: All queries filtered by store_id
- ✅ CORS: Only configured origins can call API
- ✅ CSRF: Disabled (stateless JWT auth)
- ✅ Authentication: JWT token validation
- ✅ Password: BCrypt hashing (AppConfig)

**What's NOT yet Protected (Future):**
- [ ] Rate limiting (prevent DoS)
- [ ] Input sanitization (prevent SQL injection)
- [ ] File upload security (prevent malware)
- [ ] API key rotation (for external integrations)
- [ ] Audit trail triggers (automatic logging)

---

**Status**: ✅ All 3 Architectural Safeguards Implemented  
**Next**: Write Services using OrderService pattern  
**Quality**: Production-ready, defense-in-depth design
