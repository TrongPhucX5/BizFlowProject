package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.usecase.ReportService;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/v1/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/dashboard-metrics")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboardMetrics() {
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Object> metrics = reportService.getDashboardMetrics(storeId);
        return ResponseEntity.ok(ApiResponse.success(metrics, "Dashboard metrics retrieved successfully"));
    }

    @GetMapping("/sales")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSalesReport(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Object> report = reportService.getSalesReport(storeId, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));
        return ResponseEntity.ok(ApiResponse.success(report, "Sales report retrieved successfully"));
    }

    @GetMapping("/revenue-by-category")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Double>>> getRevenueByCategory(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Double> report = reportService.getRevenueByCategory(storeId, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));
        return ResponseEntity.ok(ApiResponse.success(report, "Revenue by category retrieved successfully"));
    }

    @GetMapping("/top-products")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getTopProducts(
            @RequestParam(defaultValue = "10") int limit,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Object> products = reportService.getTopProducts(storeId, limit, startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));
        return ResponseEntity.ok(ApiResponse.success(products, "Top products retrieved successfully"));
    }

    @GetMapping("/inventory-valuation")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getInventoryValuation() {
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Object> report = reportService.getInventoryValuation(storeId);
        return ResponseEntity.ok(ApiResponse.success(report, "Inventory valuation retrieved successfully"));
    }

    @GetMapping("/daily-sales-trend")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDailySalesTrend() {
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Object> trend = reportService.getDailySalesTrend(storeId);
        return ResponseEntity.ok(ApiResponse.success(trend, "Daily sales trend retrieved successfully"));
    }
}
