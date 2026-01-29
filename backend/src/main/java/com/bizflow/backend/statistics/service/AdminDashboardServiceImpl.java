package com.bizflow.backend.statistics.service;

import com.bizflow.backend.core.domain.Store;
import com.bizflow.backend.core.usecase.AdminDashboardService;
import com.bizflow.backend.infrastructure.persistence.repository.OrderRepository;
import com.bizflow.backend.infrastructure.persistence.repository.StoreRepository;
import com.bizflow.backend.presentation.dto.response.AdminDashboardStatsResponse;
import com.bizflow.backend.presentation.dto.response.RevenueChartDto;
import com.bizflow.backend.presentation.dto.response.StoreDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminDashboardServiceImpl implements AdminDashboardService {

    private final StoreRepository storeRepository;
    private final OrderRepository orderRepository;

    @Override
    public AdminDashboardStatsResponse getDashboardStats(String period) {
        LocalDateTime startDate;
        LocalDateTime endDate = LocalDateTime.now();

        switch (period) {
            case "today":
                startDate = LocalDate.now().atStartOfDay();
                break;
            case "this-week":
                startDate = LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).atStartOfDay();
                break;
            case "this-month":
                startDate = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth()).atStartOfDay();
                break;
            case "this-quarter":
                startDate = LocalDate.now().with(LocalDate.now().getMonth().firstMonthOfQuarter()).with(TemporalAdjusters.firstDayOfMonth()).atStartOfDay();
                break;
            case "this-year":
                startDate = LocalDate.now().with(TemporalAdjusters.firstDayOfYear()).atStartOfDay();
                break;
            default: // Default "this-month"
                startDate = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth()).atStartOfDay();
        }

        BigDecimal revenue = orderRepository.calculateTotalRevenue(startDate, endDate);
        if (revenue == null) revenue = BigDecimal.ZERO;

        long newStores = storeRepository.countNewStores(startDate, endDate);
        long activeTenants = storeRepository.countActiveTenants();
        long totalOrders = orderRepository.countOrders(startDate, endDate);

        List<Store> recentStores = storeRepository.findTop5ByOrderByCreatedAtDesc();
        List<StoreDTO> recentStoreDtos = recentStores.stream().map(store -> StoreDTO.builder()
                .id(store.getId())
                .name(store.getName())
                .email(store.getEmail())
                .status(store.getStatus().toString())
                .createdAt(store.getCreatedAt())
                .build()).collect(Collectors.toList());

        List<RevenueChartDto> chartData = orderRepository.getGlobalRevenueChartData(startDate, endDate);
        List<AdminDashboardStatsResponse.RevenueChartData> revenueData = chartData.stream()
                .map(dto -> new AdminDashboardStatsResponse.RevenueChartData(
                        dto.getDate().toString(),
                        dto.getRevenue()
                ))
                .collect(Collectors.toList());

        return AdminDashboardStatsResponse.builder()
                .revenue(revenue)
                .newStores(newStores)
                .activeTenants(activeTenants)
                .totalOrders(totalOrders)
                .recentTenants(recentStoreDtos)
                .revenueData(revenueData)
                .build();
    }
}
