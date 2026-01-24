package com.bizflow.backend.interfaces.web;

import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.domain.Order;
import com.bizflow.backend.core.domain.OrderItem;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderItemRepository;

import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/v1/ai")
@CrossOrigin(origins = "*")
public class AIController {

    private final RestTemplate restTemplate;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CustomerRepository customerRepository; // Thêm CustomerRepository

    private final String PYTHON_URL = "http://localhost:8000/analyze-order";

    // Inject tất cả Repository cần thiết
    public AIController(RestTemplate restTemplate,
            ProductRepository productRepository,
            OrderRepository orderRepository,
            OrderItemRepository orderItemRepository,
            CustomerRepository customerRepository) {
        this.restTemplate = restTemplate;
        this.productRepository = productRepository;
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.customerRepository = customerRepository;
    }

    @PostMapping("/chat")
    @Transactional // Quan trọng: Đảm bảo tính toàn vẹn dữ liệu
    public ResponseEntity<?> chatWithAI(@RequestBody Map<String, Object> payload) {
        try {
            String message = (String) payload.get("message");
            Object history = payload.get("history");

            // 1. LẤY MENU SẢN PHẨM GỬI CHO AI (Chỉ lấy hàng đang bán)
            List<Product> products = productRepository.findAll();
            List<String> productContext = products.stream()
                    .filter(p -> p.getStatus() == Product.ProductStatus.ACTIVE)
                    .map(p -> String.format("- %s (Giá: %s, ĐVT: %s)", p.getName(), p.getPrice(), p.getUnitName()))
                    .collect(Collectors.toList());

            // 2. GỌI SANG PYTHON
            Map<String, Object> pythonRequest = new HashMap<>();
            pythonRequest.put("message", message);
            pythonRequest.put("history", history);
            pythonRequest.put("products", productContext);

            ResponseEntity<Map> response = restTemplate.postForEntity(PYTHON_URL, pythonRequest, Map.class);
            Map<String, Object> aiResult = response.getBody();

            if (aiResult == null)
                return ResponseEntity.ok(Map.of("reply", "Lỗi kết nối AI Server"));

            // --- LEVEL 3: TẠO ĐƠN HÀNG ---
            if (Boolean.TRUE.equals(aiResult.get("is_order"))) {
                try {
                    // Gọi hàm lưu thông minh
                    String orderNum = saveOrderToDatabase(aiResult, products);

                    String reply = (String) aiResult.get("reply");
                    aiResult.put("reply", reply + "\n✅ Đã tạo đơn: " + orderNum);
                } catch (Exception e) {
                    System.err.println("Lỗi tạo đơn AI: " + e.getMessage());
                    // Trả về lỗi thân thiện cho Chatbox
                    aiResult.put("reply", "⚠️ KHÔNG THỂ TẠO ĐƠN: " + e.getMessage());
                }
            }

            // --- LEVEL 4: XEM BÁO CÁO ---
            else if (Boolean.TRUE.equals(aiResult.get("is_report"))) {
                try {
                    String reportData = generateReport(aiResult, products);
                    String reply = (String) aiResult.get("reply");
                    aiResult.put("reply", reply + "\n" + reportData);
                } catch (Exception e) {
                    aiResult.put("reply", "Lỗi lấy báo cáo: " + e.getMessage());
                }
            }

            return ResponseEntity.ok(aiResult);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    // ========================================================================
    // LOGIC 1: XỬ LÝ ĐƠN HÀNG THÔNG MINH (FUZZY MATCH & DYNAMIC CUSTOMER)
    // ========================================================================
    private String saveOrderToDatabase(Map<String, Object> aiResult, List<Product> allProducts) {
        Map<String, Object> data = (Map<String, Object>) aiResult.get("data");

        if (data == null)
            throw new RuntimeException("Dữ liệu đơn hàng trống.");

        String customerName = (String) data.get("customerName");
        List<Map<String, Object>> items = (List<Map<String, Object>>) data.get("items");

        if (items == null || items.isEmpty()) {
            throw new RuntimeException("Không có sản phẩm nào để lên đơn.");
        }

        // 1. TÌM KHÁCH HÀNG (Nếu chưa có thì tạo mới)
        Customer customer = customerRepository.findFirstByNameContainingIgnoreCase(customerName)
                .orElseGet(() -> {
                    Customer newCus = new Customer();
                    newCus.setName(customerName);
                    newCus.setPhone("Unknown");
                    newCus.setStoreId(1L);
                    newCus.setAddress("Khách vãng lai");
                    return customerRepository.save(newCus);
                });

        // 2. KHỞI TẠO ĐƠN HÀNG
        Order newOrder = new Order();
        newOrder.setStoreId(1L);
        newOrder.setOrderNumber("ORD-" + System.currentTimeMillis());
        newOrder.setCustomerId(customer.getId());
        newOrder.setNotes("AI tạo đơn cho: " + customerName);
        newOrder.setStatus(Order.OrderStatus.CONFIRMED); // CONFIRMED để hiện lên báo cáo
        newOrder.setPaymentType(Order.PaymentType.CASH);
        newOrder.setCreatedAt(LocalDateTime.now());

        // Set tạm 0, tính sau
        newOrder.setSubtotal(BigDecimal.ZERO);
        newOrder.setDiscountAmount(BigDecimal.ZERO);
        newOrder.setTotalAmount(BigDecimal.ZERO);

        Order savedOrder = orderRepository.save(newOrder);

        BigDecimal totalRevenue = BigDecimal.ZERO;
        boolean hasValidItem = false;

        // 3. XỬ LÝ TỪNG SẢN PHẨM (SO KHỚP THÔNG MINH)
        for (Map<String, Object> itemData : items) {
            String aiProductName = (String) itemData.get("productName");
            if (aiProductName == null)
                continue;

            Integer quantity = 1;
            if (itemData.get("quantity") instanceof Number) {
                quantity = ((Number) itemData.get("quantity")).intValue();
            }

            // --- THUẬT TOÁN TÌM KIẾM TƯƠNG ĐỐI ---
            // Chuẩn hóa chuỗi (chữ thường, bỏ khoảng trắng thừa)
            String searchKey = aiProductName.toLowerCase().trim();

            // Tìm sản phẩm trong DB mà tên có chứa từ khóa AI nói (hoặc ngược lại)
            Optional<Product> productOpt = allProducts.stream()
                    .filter(p -> {
                        String dbName = p.getName().toLowerCase();
                        return dbName.contains(searchKey) || searchKey.contains(dbName);
                    })
                    .findFirst();

            if (productOpt.isPresent()) {
                Product product = productOpt.get();

                // Check tồn kho
                if (product.getStockQuantity() < quantity) {
                    throw new RuntimeException("Sản phẩm '" + product.getName() + "' không đủ hàng (Còn: "
                            + product.getStockQuantity() + ")");
                }

                // Trừ kho
                product.setStockQuantity(product.getStockQuantity() - quantity);
                productRepository.save(product);

                // Lưu chi tiết đơn hàng
                OrderItem orderItem = new OrderItem();
                orderItem.setOrderId(savedOrder.getId());
                orderItem.setProductId(product.getId());
                orderItem.setQuantity(quantity);
                orderItem.setUnitPrice(product.getPrice());

                BigDecimal lineTotal = product.getPrice().multiply(BigDecimal.valueOf(quantity));
                orderItem.setTotalAmount(lineTotal);

                orderItemRepository.save(orderItem);

                totalRevenue = totalRevenue.add(lineTotal);
                hasValidItem = true;
            } else {
                System.out.println("❌ AI tìm: " + aiProductName + " -> Không khớp với kho.");
            }
        }

        // 4. KIỂM TRA CUỐI CÙNG
        if (!hasValidItem) {
            // Nếu không bán được gì (sai tên hết) thì xóa đơn rác
            orderRepository.delete(savedOrder);
            throw new RuntimeException("Không tìm thấy sản phẩm nào khớp trong kho. Vui lòng kiểm tra lại tên.");
        }

        // Cập nhật tổng tiền
        savedOrder.setSubtotal(totalRevenue);
        savedOrder.setTotalAmount(totalRevenue);
        orderRepository.save(savedOrder);

        return savedOrder.getOrderNumber();
    }

    // ========================================================================
    // LOGIC 2: XỬ LÝ BÁO CÁO (LEVEL 4)
    // ========================================================================
    private String generateReport(Map<String, Object> aiResult, List<Product> allProducts) {
        Map<String, Object> data = (Map<String, Object>) aiResult.get("data");
        String reportType = (String) data.get("reportType"); // REVENUE, TOP_PRODUCT
        String timeRange = (String) data.get("timeRange"); // TODAY, MONTH, ALL

        LocalDateTime start, end;
        LocalDateTime now = LocalDateTime.now();

        switch (timeRange) {
            case "TODAY":
                start = now.toLocalDate().atStartOfDay();
                end = now.toLocalDate().atTime(LocalTime.MAX);
                break;
            case "MONTH":
                start = now.with(TemporalAdjusters.firstDayOfMonth()).toLocalDate().atStartOfDay();
                end = now.with(TemporalAdjusters.lastDayOfMonth()).toLocalDate().atTime(LocalTime.MAX);
                break;
            default: // ALL
                start = LocalDateTime.of(2000, 1, 1, 0, 0);
                end = now;
        }

        Long storeId = 1L;

        if ("REVENUE".equals(reportType)) {
            BigDecimal revenue = orderRepository.sumTotalRevenue(storeId, start, end);
            Long count = orderRepository.countOrders(storeId, start, end);
            return String.format("💰 Doanh thu: %,.0f VNĐ\n📄 Tổng đơn: %d đơn",
                    revenue != null ? revenue : BigDecimal.ZERO, count);
        }

        else if ("TOP_PRODUCT".equals(reportType)) {
            List<Object[]> topItems = orderItemRepository.findTopSellingProducts(storeId, start, end,
                    PageRequest.of(0, 5));

            if (topItems.isEmpty())
                return "(Chưa có dữ liệu bán hàng)";

            StringBuilder sb = new StringBuilder("🏆 Top sản phẩm bán chạy:\n");
            for (Object[] item : topItems) {
                Long productId = (Long) item[0];
                Long totalQty = (Long) item[1];
                BigDecimal revenue = (BigDecimal) item[2];

                String pName = allProducts.stream()
                        .filter(p -> p.getId().equals(productId))
                        .map(Product::getName)
                        .findFirst().orElse("SP #" + productId);

                sb.append(String.format("- %s: %d (%,.0f đ)\n", pName, totalQty, revenue));
            }
            return sb.toString();
        }

        return "Không rõ loại báo cáo.";
    }
}