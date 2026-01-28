package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdminDashboardStatsResponse {
    private BigDecimal revenue;
    private long newStores;
    private long activeTenants;
    private long totalOrders;
    private List<StoreDTO> recentTenants;
    private List<RevenueChartData> revenueData;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RevenueChartData {
        private String name;
        private BigDecimal total;
    }
}
