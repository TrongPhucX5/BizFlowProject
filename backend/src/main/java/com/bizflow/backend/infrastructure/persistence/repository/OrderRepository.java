package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Debt;
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

        // --- 1. CÁC HÀM CƠ BẢN (Sửa lỗi Service của bạn ở đây) ---

        // Hàm này đang bị thiếu khiến OrderService báo lỗi
        Page<Order> findByStoreId(Long storeId, Pageable pageable);

        // Tìm đơn hàng theo mã (VD: ORD-123)
        Optional<Order> findByOrderNumber(String orderNumber);

        // Tìm đơn hàng của khách cụ thể
        Page<Order> findByCustomerId(Long customerId, Pageable pageable);

        // --- 2. CÁC HÀM BÁO CÁO (Level 4 - Giữ nguyên) ---

        // Thống kê tổng doanh thu
        @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
                        "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED'")
        BigDecimal sumTotalRevenue(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Đếm tổng đơn hàng
        @Query("SELECT COUNT(o) FROM Order o " +
                        "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED'")
        Long countOrders(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Đếm đơn theo trạng thái
        @Query("SELECT COUNT(o) FROM Order o " +
                        "WHERE o.storeId = :storeId AND o.status = :status AND o.createdAt BETWEEN :startDate AND :endDate")
        Long countOrdersByStatus(@Param("storeId") Long storeId,
                        @Param("status") Order.OrderStatus status,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Tính tổng tiền chờ thanh toán (remainingAmount)
        // Giả sử logic: Đơn chưa hoàn thành thanh toán -> remainingAmount > 0
        // Hoặc query theo debt?
        // Theo OrderDTO logic trước đó: remainingAmount được tính toán runtime hoặc từ
        // Debt.
        // Tuy nhiên để query nhanh, ta có thể join bảng Debt.
        // Nhưng hiện tại Order chưa có field remainingAmount trong DB (chỉ có trong
        // DTO).
        // Giải pháp: Query bảng Debt join Order.
        @Query("SELECT COALESCE(SUM(d.unpaidAmount), 0) FROM Debt d " +
                        "WHERE d.storeId = :storeId AND d.status = 'UNPAID'")
        BigDecimal sumPendingPayment(@Param("storeId") Long storeId);

        // --- 3. CHARTS DATA (New) ---

        // Biểu đồ trạng thái (Status Chart)
        @Query("SELECT new com.bizflow.backend.presentation.dto.response.StatusChartDto(o.status, COUNT(o)) " +
                        "FROM Order o " +
                        "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate " +
                        "GROUP BY o.status")
        List<StatusChartDto> getOrdersGroupedByStatus(
                        @Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Biểu đồ doanh thu (Revenue Chart)
        @Query("SELECT new com.bizflow.backend.presentation.dto.response.RevenueChartDto( " +
                        "   FUNCTION('DATE', o.createdAt), " +
                        "   SUM(o.totalAmount), " +
                        "   COUNT(o) " +
                        ") " +
                        "FROM Order o " +
                        "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED' "
                        +
                        "GROUP BY FUNCTION('DATE', o.createdAt) " +
                        "ORDER BY FUNCTION('DATE', o.createdAt) ASC")
        List<RevenueChartDto> getRevenueChartData(
                        @Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);
}