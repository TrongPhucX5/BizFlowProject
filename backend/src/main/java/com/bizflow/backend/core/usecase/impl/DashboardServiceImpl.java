package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Order;
import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.presentation.dto.response.DashboardSummaryDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Service
@Slf4j
@RequiredArgsConstructor
public class DashboardServiceImpl {

    private final OrderRepository orderRepository;

    @Cacheable(value = "dashboard_summary", key = "#storeId")
    public DashboardSummaryDto getOrderSummary(Long storeId) {
        log.info("Calculating dashboard summary for storeId: {}", storeId);

        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        // 1. Total Orders Today
        Long totalOrders = orderRepository.countOrders(storeId, startOfDay, endOfDay);

        // 2. Total Revenue Today
        BigDecimal totalRevenue = orderRepository.sumTotalRevenue(storeId, startOfDay, endOfDay);

        // 3. Completed Orders Today
        Long completedOrders = orderRepository.countOrdersByStatus(
                storeId,
                Order.OrderStatus.PAID,
                startOfDay,
                endOfDay);

        // 4. Pending Payment (All time or today? Usually pending is current liability,
        // so all time)
        // Adjust logic if "Today's pending" is required, but typically Dashboard shows
        // current outstanding debt.
        BigDecimal pendingPayment = orderRepository.sumPendingPayment(storeId);

        return DashboardSummaryDto.builder()
                .totalOrders(totalOrders != null ? totalOrders : 0)
                .totalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO)
                .completedOrders(completedOrders != null ? completedOrders : 0)
                .pendingPayment(pendingPayment != null ? pendingPayment : BigDecimal.ZERO)
                .build();
    }
    // --- 2. Chart Methods ---

    @Cacheable(value = "dashboard_status_chart", key = "#storeId")
    public java.util.List<com.bizflow.backend.presentation.dto.response.StatusChartDto> getOrderStatusChart(
            Long storeId) {
        log.info("Calculating status chart for storeId: {}", storeId);
        // Default to last 30 days for distribution
        LocalDateTime startDate = LocalDate.now().minusDays(30).atStartOfDay();
        LocalDateTime endDate = LocalDate.now().atTime(LocalTime.MAX);

        return orderRepository.getOrdersGroupedByStatus(storeId, startDate, endDate);
    }

    @Cacheable(value = "dashboard_revenue_chart", key = "#storeId + ':' + #range")
    public java.util.List<com.bizflow.backend.presentation.dto.response.RevenueChartDto> getRevenueChart(Long storeId,
            String range) {
        log.info("Calculating revenue chart for storeId: {}, range: {}", storeId, range);
        LocalDateTime startDate = resolveStartDate(range);
        LocalDateTime endDate = LocalDate.now().atTime(LocalTime.MAX);

        return orderRepository.getRevenueChartData(storeId, startDate, endDate);
    }

    // Reuse RevenueChartDto or create new? Reuse is fine as it contains orderCount.
    // Ideally this API might return just date & count, but returning full object is
    // flexible.
    @Cacheable(value = "dashboard_daily_count_chart", key = "#storeId + ':' + #range")
    public java.util.List<com.bizflow.backend.presentation.dto.response.RevenueChartDto> getDailyCountChart(
            Long storeId, String range) {
        log.info("Calculating daily count chart for storeId: {}, range: {}", storeId, range);
        LocalDateTime startDate = resolveStartDate(range);
        LocalDateTime endDate = LocalDate.now().atTime(LocalTime.MAX);

        return orderRepository.getRevenueChartData(storeId, startDate, endDate);
    }

    private LocalDateTime resolveStartDate(String range) {
        if ("30d".equals(range)) {
            return LocalDate.now().minusDays(30).atStartOfDay();
        }
        // Default 7 days
        return LocalDate.now().minusDays(7).atStartOfDay();
    }
}
