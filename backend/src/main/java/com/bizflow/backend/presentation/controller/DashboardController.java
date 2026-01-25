package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.usecase.impl.DashboardServiceImpl;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.DashboardSummaryDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.bizflow.backend.presentation.dto.response.RevenueChartDto;
import com.bizflow.backend.presentation.dto.response.StatusChartDto;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@RestController
@RequestMapping("/v1/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardServiceImpl dashboardService;

    @GetMapping("/orders/summary")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<DashboardSummaryDto>> getOrderSummary() {
        Long storeId = UserContext.getCurrentStoreId();
        DashboardSummaryDto summary = dashboardService.getOrderSummary(storeId);
        return ResponseEntity.ok(ApiResponse.success(summary, "Dashboard summary retrieved successfully"));
    }

    @GetMapping("/orders/status-chart")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<List<StatusChartDto>>> getOrderStatusChart() {
        Long storeId = UserContext.getCurrentStoreId();
        List<StatusChartDto> chart = dashboardService.getOrderStatusChart(storeId);
        return ResponseEntity.ok(ApiResponse.success(chart, "Status chart retrieved successfully"));
    }

    @GetMapping("/orders/revenue-chart")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<List<RevenueChartDto>>> getRevenueChart(
            @RequestParam(defaultValue = "7d") String range) {
        Long storeId = UserContext.getCurrentStoreId();
        List<RevenueChartDto> chart = dashboardService.getRevenueChart(storeId, range);
        return ResponseEntity.ok(ApiResponse.success(chart, "Revenue chart retrieved successfully"));
    }

    @GetMapping("/orders/daily-count-chart")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<List<RevenueChartDto>>> getDailyCountChart(
            @RequestParam(defaultValue = "30d") String range) {
        Long storeId = UserContext.getCurrentStoreId();
        List<RevenueChartDto> chart = dashboardService.getDailyCountChart(storeId, range);
        return ResponseEntity.ok(ApiResponse.success(chart, "Daily count chart retrieved successfully"));
    }

    @GetMapping("/products/low-stock")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<com.bizflow.backend.presentation.dto.response.ApiResponse<List<com.bizflow.backend.presentation.dto.response.ProductDTO>>> getLowStockProducts() {
        Long storeId = UserContext.getCurrentStoreId();
        List<com.bizflow.backend.presentation.dto.response.ProductDTO> products = dashboardService
                .getLowStockProducts(storeId);
        return ResponseEntity.ok(ApiResponse.success(products, "Low stock products retrieved successfully"));
    }
}
