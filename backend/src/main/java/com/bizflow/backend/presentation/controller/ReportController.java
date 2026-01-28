package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.infrastructure.persistence.repository.OrderItemRepository;
import com.bizflow.backend.infrastructure.persistence.repository.DebtRepository;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.presentation.dto.response.RevenueChartDto;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import com.bizflow.backend.core.common.UserContext;

@RestController
@RequestMapping("/v1/reports") // Khớp với axiosClient
@CrossOrigin(origins = "*")
public class ReportController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final DebtRepository debtRepository;
    private final ProductRepository productRepository;

    public ReportController(OrderRepository orderRepository,
            OrderItemRepository orderItemRepository,
            DebtRepository debtRepository,
            ProductRepository productRepository) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.debtRepository = debtRepository;
        this.productRepository = productRepository;
    }

    // 1. API DOANH THU (BIỂU ĐỒ)
    @GetMapping("/revenue")
    public ResponseEntity<?> getRevenueReport(@RequestParam(defaultValue = "week") String period) {
        Long storeId = UserContext.getCurrentStoreId(); // Lấy từ UserContext để đảm bảo bảo mật đa chi nhánh
        LocalDateTime endDate = LocalDateTime.now();
        LocalDateTime startDate = calculateStartDate(period, endDate);

        List<RevenueChartDto> data = orderRepository.getRevenueChartData(storeId, startDate, endDate);

        // Map DTO sang JSON: { date: "2023-01-01", totalAmount: 100000, orderCount: 5 }
        List<Map<String, Object>> result = new ArrayList<>();
        for (RevenueChartDto row : data) {
            Map<String, Object> item = new HashMap<>();
            item.put("date", row.getDate().toString());
            item.put("totalAmount", row.getRevenue());
            item.put("profit", row.getProfit()); // Include profit
            item.put("orderCount", row.getOrderCount());
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    // 2. API THỐNG KÊ TỔNG QUAN (4 ô vuông đầu trang)
    @GetMapping("/dashboard-stats")
    public ResponseEntity<?> getDashboardStats() {
        try {
            Long storeId = UserContext.getCurrentStoreId();
            System.out.println("DEBUG: getDashboardStats called. StoreId=" + storeId);

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime startToday = LocalDate.now().atStartOfDay();
            System.out.println("DEBUG: Querying from " + startToday + " to " + now);

            BigDecimal revenueToday = orderRepository.sumTotalRevenue(storeId, startToday, now);
            Long ordersToday = orderRepository.countOrders(storeId, startToday, now);

            System.out.println("DEBUG: revenueToday=" + revenueToday + ", ordersToday=" + ordersToday);

            // Lấy tổng công nợ thật từ DebtRepository (UNPAID + PAID_PARTIAL)
            BigDecimal totalDebt = debtRepository.sumByStoreIdAndStatusIn(storeId,
                    Arrays.asList(com.bizflow.backend.core.domain.Debt.DebtStatus.UNPAID,
                            com.bizflow.backend.core.domain.Debt.DebtStatus.PAID_PARTIAL));

            // Đếm số sản phẩm có số lượng tồn kho <= mức tối thiểu (reorderLevel)
            long warningProducts = productRepository.countByStoreIdAndStockQuantityLessThanEqual(storeId, 10);

            Map<String, Object> stats = new HashMap<>();
            stats.put("revenueToday", revenueToday != null ? revenueToday.doubleValue() : 0.0);
            stats.put("ordersToday", ordersToday != null ? ordersToday : 0L);
            stats.put("totalDebt", totalDebt != null ? totalDebt.doubleValue() : 0.0);
            stats.put("warningProducts", warningProducts);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            e.printStackTrace();
            // Return empty stats instead of error to avoid crashing frontend
            Map<String, Object> emptyStats = new HashMap<>();
            emptyStats.put("revenueToday", 0);
            emptyStats.put("ordersToday", 0);
            emptyStats.put("totalDebt", 0);
            emptyStats.put("warningProducts", 0);
            return ResponseEntity.ok(emptyStats);
        }
    }

    // 3. API TOP SẢN PHẨM BÁN CHẠY
    @GetMapping("/best-selling")
    public ResponseEntity<?> getBestSelling() {
        Long storeId = UserContext.getCurrentStoreId();
        // Lấy 30 ngày gần nhất
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(30);

        // Gọi Repo lấy Top 10
        List<Object[]> topData = orderItemRepository.findTopSellingProducts(storeId, start, end, PageRequest.of(0, 10));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Object[] row : topData) {
            Map<String, Object> item = new HashMap<>();
            // row[0]=productId, row[1]=productName, row[2]=qty, row[3]=revenue
            item.put("productId", row[0]);
            item.put("name", row[1] != null ? row[1] : "Sản phẩm #" + row[0]); // Fallback nếu không có tên
            item.put("sales", row[2]);
            item.put("revenue", row[3]);
            result.add(item);
        }
        return ResponseEntity.ok(result);
    }

    // 4. API XUẤT BÁO CÁO (CSV)
    @GetMapping("/export/general")
    public ResponseEntity<byte[]> exportGeneralReport() {
        Long storeId = UserContext.getCurrentStoreId();
        StringBuilder csv = new StringBuilder();

        // Header
        csv.append("\uFEFF"); // BOM for UTF-8 Excel support
        csv.append("BAO CAO TONG QUAN CUA HANG\n");
        csv.append("Ngay xuat,").append(LocalDate.now()).append("\n\n");

        // 1. Thong ke chung
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startToday = LocalDate.now().atStartOfDay();

        BigDecimal revenueToday = orderRepository.sumTotalRevenue(storeId, startToday, now);
        Long ordersToday = orderRepository.countOrders(storeId, startToday, now);
        BigDecimal totalDebt = debtRepository.sumByStoreIdAndStatusIn(storeId,
                Arrays.asList(com.bizflow.backend.core.domain.Debt.DebtStatus.UNPAID,
                        com.bizflow.backend.core.domain.Debt.DebtStatus.PAID_PARTIAL));
        long warningProducts = productRepository.countByStoreIdAndStockQuantityLessThanEqual(storeId, 10);

        csv.append("--- THONG KE TRONG NGAY ---\n");
        csv.append("Doanh thu hom nay (VNĐ),Tong don hang,Tong cong no (VNĐ),Canh bao ton kho\n");
        csv.append(revenueToday != null ? revenueToday : 0).append(",")
                .append(ordersToday).append(",")
                .append(totalDebt != null ? totalDebt : 0).append(",")
                .append(warningProducts).append("\n\n");

        // 2. Top San Pham Ban Chay (30 ngay)
        csv.append("--- TOP 10 SAN PHAM BAN CHAY (30 NGAY) ---\n");
        csv.append("Ten San Pham,So Luong Ban,Doanh Thu (VNĐ)\n");

        List<Object[]> topProducts = orderItemRepository.findTopSellingProducts(storeId,
                now.minusDays(30), now,
                PageRequest.of(0, 10));

        for (Object[] row : topProducts) {
            String name = (String) (row[1] != null ? row[1] : "SP #" + row[0]);
            // Escape commas in name
            if (name.contains(","))
                name = "\"" + name + "\"";

            csv.append(name).append(",")
                    .append(row[2]).append(",")
                    .append(row[3]).append("\n");
        }

        byte[] bytes = csv.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=bao-cao-tong-quan.csv")
                .contentType(org.springframework.http.MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(bytes);
    }

    // Hàm phụ tính ngày bắt đầu
    private LocalDateTime calculateStartDate(String period, LocalDateTime endDate) {
        switch (period) {
            case "today":
                return LocalDate.now().atStartOfDay();
            case "week":
                return endDate.minusDays(7);
            case "month":
                return endDate.minusDays(30);
            case "year":
                return endDate.minusDays(365);
            default:
                return endDate.minusDays(7);
        }
    }
}