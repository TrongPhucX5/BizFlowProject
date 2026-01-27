package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Order;
import com.bizflow.backend.presentation.dto.response.RevenueChartDto;
import com.bizflow.backend.presentation.dto.response.StatusChartDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    // --- 1. CÁC HÀM TRUY VẤN CƠ BẢN ---

    // Tìm đơn hàng theo mã (VD: ORD-123)
    Optional<Order> findByOrderNumber(String orderNumber);

    // Tìm tất cả đơn hàng theo Store
    Page<Order> findByStoreId(Long storeId, Pageable pageable);

    // Tìm đơn hàng của khách cụ thể
    Page<Order> findByCustomerId(Long customerId, Pageable pageable);

    // --- 2. PHƯƠNG THỨC LỌC ĐA NĂNG (Dùng cho trang danh sách) ---
    @Query("SELECT o FROM Order o WHERE " +
            "o.storeId = :storeId AND " +
            "(:status IS NULL OR o.status = :status) AND " +
            "(:customerId IS NULL OR o.customerId = :customerId) AND " +
            "(:startDate IS NULL OR o.createdAt >= :startDate) AND " +
            "(:endDate IS NULL OR o.createdAt <= :endDate)")
    Page<Order> findAllWithFilters(
            @Param("storeId") Long storeId,
            @Param("status") Order.OrderStatus status,
            @Param("customerId") Long customerId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);

    // --- 3. CÁC HÀM THỐNG KÊ BÁO CÁO ---

    // Thống kê tổng doanh thu (Trừ các đơn đã hủy)
    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
            "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate " +
            "AND o.status <> com.bizflow.backend.core.domain.Order.OrderStatus.CANCELLED")
    BigDecimal sumTotalRevenue(@Param("storeId") Long storeId,
                               @Param("startDate") LocalDateTime startDate,
                               @Param("endDate") LocalDateTime endDate);

    // Đếm tổng số đơn hàng (Trừ các đơn đã hủy)
    @Query("SELECT COUNT(o) FROM Order o " +
            "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate " +
            "AND o.status <> com.bizflow.backend.core.domain.Order.OrderStatus.CANCELLED")
    Long countOrders(@Param("storeId") Long storeId,
                     @Param("startDate") LocalDateTime startDate,
                     @Param("endDate") LocalDateTime endDate);

    // Đếm đơn theo một trạng thái cụ thể
    @Query("SELECT COUNT(o) FROM Order o " +
            "WHERE o.storeId = :storeId AND o.status = :status " +
            "AND o.createdAt BETWEEN :startDate AND :endDate")
    Long countOrdersByStatus(@Param("storeId") Long storeId,
                             @Param("status") Order.OrderStatus status,
                             @Param("startDate") LocalDateTime startDate,
                             @Param("endDate") LocalDateTime endDate);

    // Tính tổng tiền nợ khách hàng đang nợ store
    @Query("SELECT COALESCE(SUM(d.unpaidAmount), 0) FROM Debt d " +
            "WHERE d.storeId = :storeId AND d.status = 'UNPAID'")
    BigDecimal sumPendingPayment(@Param("storeId") Long storeId);

    // --- 4. DỮ LIỆU BIỂU ĐỒ (CHARTS DATA) ---

    // Gom nhóm đơn hàng theo trạng thái để vẽ biểu đồ tròn
    @Query("SELECT new com.bizflow.backend.presentation.dto.response.StatusChartDto(o.status, COUNT(o)) " +
            "FROM Order o " +
            "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate " +
            "GROUP BY o.status")
    List<StatusChartDto> getOrdersGroupedByStatus(
            @Param("storeId") Long storeId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    // Gom nhóm doanh thu theo ngày để vẽ biểu đồ đường
    @Query("SELECT new com.bizflow.backend.presentation.dto.response.RevenueChartDto( " +
            "   FUNCTION('DATE', o.createdAt), " +
            "   SUM(o.totalAmount), " +
            "   COUNT(o) " +
            ") " +
            "FROM Order o " +
            "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate " +
            "AND o.status <> com.bizflow.backend.core.domain.Order.OrderStatus.CANCELLED " +
            "GROUP BY FUNCTION('DATE', o.createdAt) " +
            "ORDER BY FUNCTION('DATE', o.createdAt) ASC")
    List<RevenueChartDto> getRevenueChartData(
            @Param("storeId") Long storeId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
}