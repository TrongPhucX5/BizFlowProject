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

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    Order findByOrderNumber(String orderNumber);

    Page<Order> findByStoreId(Long storeId, Pageable pageable);

    Page<Order> findByCustomerId(Long customerId, Pageable pageable);

    // --- PHƯƠNG THỨC LỌC ĐA NĂNG (ĐÃ CẬP NHẬT STOREID) ---
    @Query("SELECT o FROM Order o WHERE " +
            "o.storeId = :storeId AND " + // Đảm bảo an toàn dữ liệu Multi-Tenancy
            "(:status IS NULL OR o.status = :status) AND " + // JPA sẽ tự map Enum ở đây
            "(:customerId IS NULL OR o.customerId = :customerId) AND " +
            "(:startDate IS NULL OR o.createdAt >= :startDate) AND " +
            "(:endDate IS NULL OR o.createdAt <= :endDate) " +
            "ORDER BY o.createdAt DESC")
    Page<Order> findAllWithFilters(
            @Param("storeId") Long storeId, // Tham số thứ 1
            @Param("status") String status,  // Tham số thứ 2
            @Param("customerId") Long customerId, // Tham số thứ 3
            @Param("startDate") LocalDateTime startDate, // Tham số thứ 4
            @Param("endDate") LocalDateTime endDate, // Tham số thứ 5
            Pageable pageable); // Tham số thứ 6

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED'")
    BigDecimal sumTotalRevenue(@Param("storeId") Long storeId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED'")
    Long countOrders(@Param("storeId") Long storeId, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}