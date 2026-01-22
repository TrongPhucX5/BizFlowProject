package com.bizflow.backend.interfaces.web; // Hoặc package controller của bạn

import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderItemRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequestMapping("/api/v1/reports") // Khớp với axiosClient
@CrossOrigin(origins = "*")
public class ReportController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;

    public ReportController(OrderRepository orderRepository, OrderItemRepository orderItemRepository) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
    }

    // 1. API DOANH THU (BIỂU ĐỒ)
    @GetMapping("/revenue")
    public ResponseEntity<?> getRevenueReport(@RequestParam(defaultValue = "week") String period) {
        Long storeId = 1L; // Hardcode store 1 hoặc lấy từ UserContext
        LocalDateTime endDate = LocalDateTime.now();
        LocalDateTime startDate = calculateStartDate(period, endDate);

        List<Object[]> data = orderRepository.getRevenueChartData(storeId, startDate, endDate);

        // Map Object[] sang JSON: { date: "2023-01-01", totalAmount: 100000, orderCount: 5 }
        List<Map<String, Object>> result = new ArrayList<>();
        for (Object[] row : data) {
            Map<String, Object> item = new HashMap<>();
            item.put("date", row[0].toString());
            item.put("totalAmount", row[1]);
            item.put("orderCount", row[2]);
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    // 2. API THỐNG KÊ TỔNG QUAN (4 ô vuông đầu trang)
    @GetMapping("/dashboard-stats")
    public ResponseEntity<?> getDashboardStats() {
        Long storeId = 1L;
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startToday = LocalDate.now().atStartOfDay();

        Double revenueToday = orderRepository.sumTotalRevenue(storeId, startToday, now).doubleValue();
        Long ordersToday = orderRepository.countOrders(storeId, startToday, now);

        Map<String, Object> stats = new HashMap<>();
        stats.put("revenueToday", revenueToday);
        stats.put("ordersToday", ordersToday);
        stats.put("totalDebt", 0); // TODO: Query từ DebtRepository
        stats.put("warningProducts", 0); // TODO: Query từ ProductRepository

        return ResponseEntity.ok(stats);
    }

    // 3. API TOP SẢN PHẨM BÁN CHẠY
    @GetMapping("/best-selling")
    public ResponseEntity<?> getBestSelling() {
        Long storeId = 1L;
        // Lấy 30 ngày gần nhất
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(30);

        // Gọi Repo lấy Top 5 (Giả sử bạn đã có hàm này ở Level 4)
        List<Object[]> topData = orderItemRepository.findTopSellingProducts(storeId, start, end, PageRequest.of(0, 10));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Object[] row : topData) {
            Map<String, Object> item = new HashMap<>();
            // row[0]=productId, row[1]=qty, row[2]=revenue -> Cần join lấy tên Product
            // Để đơn giản, giả sử Repo trả về cả tên (Bạn cần chỉnh Repo nếu chưa có)
            item.put("productId", row[0]);
            item.put("sales", row[1]);
            item.put("revenue", row[2]);
            // Tạm thời hardcode tên nếu Repo chưa trả về tên
            item.put("name", "Sản phẩm #" + row[0]);
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    // Hàm phụ tính ngày bắt đầu
    private LocalDateTime calculateStartDate(String period, LocalDateTime endDate) {
        switch (period) {
            case "today": return LocalDate.now().atStartOfDay();
            case "week": return endDate.minusDays(7);
            case "month": return endDate.minusDays(30);
            case "year": return endDate.minusDays(365);
            default: return endDate.minusDays(7);
        }
    }
}