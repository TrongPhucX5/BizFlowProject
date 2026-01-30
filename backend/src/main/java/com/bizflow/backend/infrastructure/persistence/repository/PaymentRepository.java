package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Payment;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByDebtId(Long debtId);

    List<Payment> findByCustomerId(Long customerId);

    Page<Payment> findByCustomerId(Long customerId, org.springframework.data.domain.Pageable pageable);

    // TT88: Tổng đã trả TRƯỚC ngày from
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.storeId = :storeId AND p.customerId = :customerId AND p.createdAt < :date")
    BigDecimal sumAmountBefore(@Param("storeId") Long storeId, @Param("customerId") Long customerId, @Param("date") LocalDateTime date);

    // TT88: Tổng đã trả TRONG KHOẢNG from - to
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.storeId = :storeId AND p.customerId = :customerId AND p.createdAt BETWEEN :from AND :to")
    BigDecimal sumAmountBetween(@Param("storeId") Long storeId, @Param("customerId") Long customerId, @Param("from") LocalDateTime from, @Param("to") LocalDateTime to);
}
