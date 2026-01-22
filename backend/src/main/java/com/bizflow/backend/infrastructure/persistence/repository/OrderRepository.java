package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Order;
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

    // Lấy dữ liệu biểu đồ
    @Query("SELECT FUNCTION('DATE', o.createdAt) as reportDate, SUM(o.totalAmount), COUNT(o) " +
            "FROM Order o " +
            "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED' " +
            "GROUP BY FUNCTION('DATE', o.createdAt) " +
            "ORDER BY reportDate ASC")
    List<Object[]> getRevenueChartData(@Param("storeId") Long storeId,
                                       @Param("startDate") LocalDateTime startDate,
                                       @Param("endDate") LocalDateTime endDate);
}