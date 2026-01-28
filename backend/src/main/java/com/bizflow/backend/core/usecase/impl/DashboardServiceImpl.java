package com.bizflow.backend.core.usecase.impl;

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
    private final com.bizflow.backend.infrastructure.persistence.repository.ProductRepository productRepository;
    private final com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository customerRepository;

    public java.util.List<com.bizflow.backend.presentation.dto.response.OrderDTO> getRecentOrders(Long storeId) {
        log.info("Fetching recent orders for storeId: {}", storeId);
        java.util.List<Order> orders = orderRepository.findTop5ByStoreIdOrderByCreatedAtDesc(storeId);

        java.util.List<Long> customerIds = orders.stream().map(Order::getCustomerId)
                .collect(java.util.stream.Collectors.toList());
        java.util.List<com.bizflow.backend.core.domain.Customer> customers = customerRepository
                .findAllById(customerIds);
        java.util.Map<Long, String> customerMap = customers.stream()
                .collect(java.util.stream.Collectors.toMap(com.bizflow.backend.core.domain.Customer::getId,
                        com.bizflow.backend.core.domain.Customer::getName));

        return orders.stream().map(order -> com.bizflow.backend.presentation.dto.response.OrderDTO.builder()
                .id(order.getId())
                .orderCode(order.getOrderNumber())
                .customerId(order.getCustomerId())
                .customerName(customerMap.getOrDefault(order.getCustomerId(), "Unknown"))
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus().name())
                .createdAt(order.getCreatedAt())
                .paymentType(order.getPaymentType() != null ? order.getPaymentType().name() : "N/A")
                .build()).collect(java.util.stream.Collectors.toList());
    }

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

        // 5. Product Stats
        long lowStockCount = productRepository.countByStoreIdAndStockQuantityLessThanEqual(storeId, 10);
        long totalProducts = productRepository.countByStoreId(storeId);

        return DashboardSummaryDto.builder()
                .totalOrders(totalOrders != null ? totalOrders : 0)
                .totalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO)
                .completedOrders(completedOrders != null ? completedOrders : 0)
                .pendingPayment(pendingPayment != null ? pendingPayment : BigDecimal.ZERO)
                .lowStockCount(lowStockCount)
                .totalProducts(totalProducts)
                .build();
    }

    @Cacheable(value = "dashboard_low_stock", key = "#storeId")
    public java.util.List<com.bizflow.backend.presentation.dto.response.ProductDTO> getLowStockProducts(Long storeId) {
        log.info("Fetching low stock products for storeId: {}", storeId);
        // Pageable to limit results, e.g., top 10
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 50);

        java.util.List<com.bizflow.backend.core.domain.Product> products = productRepository
                .findByStoreIdAndStockQuantityLessThanEqual(storeId, 10, pageable);

        // Convert to DTO manually or use mapper (manual for now to avoid dependency
        // checks)
        return products.stream().map(p -> com.bizflow.backend.presentation.dto.response.ProductDTO.builder()
                .id(p.getId())
                .name(p.getName())
                .sku(p.getSku())
                .price(p.getPrice())
                .stock(p.getStockQuantity())
                .unitName(p.getUnitName())
                .imageUrl(p.getImageUrl())
                // Add other fields as necessary
                .build()).collect(java.util.stream.Collectors.toList());
    }
    // --- 2. Chart Methods ---

    @Cacheable(value = "dashboard_status_chart", key = "#storeId")
    public java.util.List<com.bizflow.backend.presentation.dto.response.StatusChartDto> getOrderStatusChart(
            Long storeId) {
        log.info("Calculating order status chart for storeId: {}", storeId);
        LocalDateTime endDate = LocalDate.now().atTime(LocalTime.MAX);
        LocalDateTime startDate = LocalDate.now().minusDays(30).atStartOfDay(); // Default 30 days for status chart
        return orderRepository.getOrdersGroupedByStatus(storeId, startDate, endDate);
    }

    @Cacheable(value = "dashboard_revenue_chart", key = "#storeId + ':' + #range")
    public java.util.List<com.bizflow.backend.presentation.dto.response.RevenueChartDto> getRevenueChart(Long storeId,
            String range) {
        log.info("Calculating revenue chart for storeId: {}, range: {}", storeId, range);
        LocalDateTime[] dates = resolveDateRange(range);
        return orderRepository.getRevenueChartData(storeId, dates[0], dates[1]);
    }

    // Reuse RevenueChartDto or create new? Reuse is fine as it contains orderCount.
    // Ideally this API might return just date & count, but returning full object is
    // flexible.
    @Cacheable(value = "dashboard_daily_count_chart", key = "#storeId + ':' + #range")
    public java.util.List<com.bizflow.backend.presentation.dto.response.RevenueChartDto> getDailyCountChart(
            Long storeId, String range) {
        log.info("Calculating daily count chart for storeId: {}, range: {}", storeId, range);
        LocalDateTime[] dates = resolveDateRange(range);
        return orderRepository.getRevenueChartData(storeId, dates[0], dates[1]);
    }

    @Cacheable(value = "dashboard_top_customers", key = "#storeId + ':' + #range")
    public java.util.List<com.bizflow.backend.presentation.dto.response.TopCustomerDto> getTopCustomers(Long storeId,
            String range) {
        log.info("Fetching top customers for storeId: {}, range: {}", storeId, range);
        LocalDateTime[] dates = resolveDateRange(range);

        // Return top 5
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(0, 5);
        return orderRepository.findTopCustomers(storeId, dates[0], dates[1], pageable);
    }

    public java.util.List<com.bizflow.backend.presentation.dto.response.OrderDTO> getOrdersByDate(Long storeId,
            java.time.LocalDate date) {
        log.info("Fetching orders for storeId: {}, date: {}", storeId, date);
        LocalDateTime startDate = date.atStartOfDay();
        LocalDateTime endDate = date.atTime(LocalTime.MAX);
        java.util.List<com.bizflow.backend.core.domain.Order> orders = orderRepository
                .findByStoreIdAndCreatedAtBetweenOrderByCreatedAtDesc(storeId, startDate, endDate);

        // Map to DTO
        if (orders.isEmpty()) {
            return java.util.Collections.emptyList();
        }

        java.util.List<Long> customerIds = orders.stream().map(com.bizflow.backend.core.domain.Order::getCustomerId)
                .collect(java.util.stream.Collectors.toList());
        java.util.List<com.bizflow.backend.core.domain.Customer> customers = customerRepository
                .findAllById(customerIds);
        java.util.Map<Long, String> customerMap = customers.stream()
                .collect(java.util.stream.Collectors.toMap(com.bizflow.backend.core.domain.Customer::getId,
                        com.bizflow.backend.core.domain.Customer::getName));

        return orders.stream().map(order -> com.bizflow.backend.presentation.dto.response.OrderDTO.builder()
                .id(order.getId())
                .orderCode(order.getOrderNumber())
                .customerId(order.getCustomerId())
                .customerName(customerMap.getOrDefault(order.getCustomerId(), "Unknown"))
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus().name())
                .createdAt(order.getCreatedAt())
                .paymentType(order.getPaymentType() != null ? order.getPaymentType().name() : "N/A")
                .build()).collect(java.util.stream.Collectors.toList());
    }

    private LocalDateTime[] resolveDateRange(String range) {
        LocalDateTime endDate = LocalDate.now().atTime(LocalTime.MAX);
        LocalDateTime startDate = LocalDate.now().minusDays(7).atStartOfDay(); // Default

        if (range == null) {
            return new LocalDateTime[] { startDate, endDate };
        }

        if (range.startsWith("custom:")) {
            // Format: custom:yyyy-MM-dd:yyyy-MM-dd
            try {
                String[] parts = range.split(":");
                if (parts.length >= 3) {
                    startDate = LocalDate.parse(parts[1]).atStartOfDay();
                    endDate = LocalDate.parse(parts[2]).atTime(LocalTime.MAX);
                }
            } catch (Exception e) {
                log.error("Error parsing custom date range: {}", range, e);
            }
        } else {
            switch (range) {
                case "today":
                    startDate = LocalDate.now().atStartOfDay();
                    break;
                case "week":
                    startDate = LocalDate.now().minusDays(7).atStartOfDay();
                    break;
                case "month":
                case "30d":
                    startDate = LocalDate.now().minusDays(30).atStartOfDay();
                    break;
                default:
                    // Default is week
                    startDate = LocalDate.now().minusDays(7).atStartOfDay();
                    break;
            }
        }

        return new LocalDateTime[] { startDate, endDate };
    }
}
