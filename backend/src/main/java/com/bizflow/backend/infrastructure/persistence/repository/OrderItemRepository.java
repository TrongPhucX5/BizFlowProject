package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.OrderItem;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    List<OrderItem> findByOrderId(Long orderId);

    // --- PHƯƠNG THỨC XÓA (Đã sửa vị trí) ---
    @Modifying
    @Transactional
    @Query("DELETE FROM OrderItem oi WHERE oi.orderId = :orderId")
    void deleteByOrderId(@Param("orderId") Long orderId);

    // --- PHƯƠNG THỨC THỐNG KÊ ---
    @Query("SELECT oi.productId, SUM(oi.quantity) as totalQty, SUM(oi.totalAmount) as totalRevenue " +
            "FROM OrderItem oi JOIN Order o ON oi.orderId = o.id " +
            "WHERE o.storeId = :storeId AND o.createdAt BETWEEN :startDate AND :endDate AND o.status != 'CANCELLED' " +
            "GROUP BY oi.productId " +
            "ORDER BY totalQty DESC")
    List<Object[]> findTopSellingProducts(@Param("storeId") Long storeId,
                                          @Param("startDate") LocalDateTime startDate,
                                          @Param("endDate") LocalDateTime endDate,
                                          Pageable pageable);
}