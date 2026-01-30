package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.StockMovement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

@Repository
public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    Page<StockMovement> findByStoreIdAndProductId(Long storeId, Long productId, Pageable pageable);

    // TT88: Tồn đầu kỳ (Tổng quantity trước ngày from)
    @Query("SELECT COALESCE(SUM(s.quantity), 0) FROM StockMovement s WHERE s.storeId = :storeId AND s.productId = :productId AND s.createdAt < :date")
    Integer sumQuantityBefore(@Param("storeId") Long storeId, @Param("productId") Long productId, @Param("date") LocalDateTime date);

    // TT88: Tổng nhập trong kỳ (Tổng quantity dương trong khoảng from-to)
    @Query("SELECT COALESCE(SUM(s.quantity), 0) FROM StockMovement s WHERE s.storeId = :storeId AND s.productId = :productId AND s.createdAt BETWEEN :from AND :to AND s.quantity > 0")
    Integer sumImportBetween(@Param("storeId") Long storeId, @Param("productId") Long productId, @Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    // TT88: Tổng xuất trong kỳ (Tổng ABS(quantity) âm trong khoảng from-to)
    @Query("SELECT COALESCE(SUM(ABS(s.quantity)), 0) FROM StockMovement s WHERE s.storeId = :storeId AND s.productId = :productId AND s.createdAt BETWEEN :from AND :to AND s.quantity < 0")
    Integer sumExportBetween(@Param("storeId") Long storeId, @Param("productId") Long productId, @Param("from") LocalDateTime from, @Param("to") LocalDateTime to);
}
