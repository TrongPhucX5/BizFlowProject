package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.AdminDashboardService;
import com.bizflow.backend.presentation.dto.response.AdminDashboardStatsResponse;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/admin/dashboard")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final AdminDashboardService dashboardService;

    @GetMapping("/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<AdminDashboardStatsResponse>> getDashboardStats(
            @RequestParam(defaultValue = "this-month") String period) {

        AdminDashboardStatsResponse stats = dashboardService.getDashboardStats(period);
        return ResponseEntity.ok(ApiResponse.success(stats, "Lấy dữ liệu thống kê thành công"));
    }
}
