package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Debt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface DebtRepository extends JpaRepository<Debt, Long> {
    Page<Debt> findByStoreId(Long storeId, Pageable pageable);

    Page<Debt> findByCustomerId(Long customerId, Pageable pageable);

    Page<Debt> findByStatus(Debt.DebtStatus status, Pageable pageable);

    Optional<Debt> findByOrderId(Long orderId);

    // Tính tổng công nợ chưa thanh toán của một cửa hàng
    @Query("SELECT COALESCE(SUM(d.unpaidAmount), 0) FROM Debt d WHERE d.storeId = :storeId AND d.status = 'UNPAID'")
    BigDecimal sumUnpaidDebtByStoreId(@Param("storeId") Long storeId);
}
