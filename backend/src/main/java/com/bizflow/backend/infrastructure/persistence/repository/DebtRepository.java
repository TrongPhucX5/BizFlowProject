package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Debt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface DebtRepository extends JpaRepository<Debt, Long> {
        // Tìm theo khách hàng
        Page<Debt> findByCustomerId(Long customerId, Pageable pageable);

        // Tìm theo order
        Optional<Debt> findByOrderId(Long orderId);

        // Lấy danh sách nợ chưa trả hết (UNPAID + PAID_PARTIAL)
        Page<Debt> findByStoreIdAndStatusIn(Long storeId, java.util.Collection<Debt.DebtStatus> statuses,
                        Pageable pageable);

        // Tính tổng công nợ theo danh sách trạng thái
        @Query("SELECT COALESCE(SUM(d.unpaidAmount), 0) FROM Debt d WHERE d.storeId = :storeId AND d.status IN :statuses")
        BigDecimal sumByStoreIdAndStatusIn(@Param("storeId") Long storeId,
                        @Param("statuses") java.util.Collection<Debt.DebtStatus> statuses);

        // Tìm debt chưa thanh toán của khách hàng
        java.util.List<Debt> findByCustomerIdAndStoreIdAndStatusNot(Long customerId, Long storeId,
                        Debt.DebtStatus status);

        // Tính tổng công nợ còn lại của một khách hàng (SUM unpaidAmount)
        @Query("SELECT COALESCE(SUM(d.unpaidAmount), 0) FROM Debt d WHERE d.customerId = :customerId AND d.status IN ('UNPAID', 'PAID_PARTIAL', 'OVERDUE')")
        BigDecimal sumUnpaidByCustomerId(@Param("customerId") Long customerId);

        // TT88: Tổng nợ gốc phát sinh TRƯỚC ngày from
        @Query("SELECT COALESCE(SUM(d.originalAmount), 0) FROM Debt d WHERE d.storeId = :storeId AND d.customerId = :customerId AND d.createdAt < :date")
        BigDecimal sumOriginalAmountBefore(@Param("storeId") Long storeId, @Param("customerId") Long customerId,
                        @Param("date") LocalDateTime date);

        // TT88: Tổng nợ gốc phát sinh TRONG KHOẢNG from - to
        @Query("SELECT COALESCE(SUM(d.originalAmount), 0) FROM Debt d WHERE d.storeId = :storeId AND d.customerId = :customerId AND d.createdAt BETWEEN :from AND :to")
        BigDecimal sumOriginalAmountBetween(@Param("storeId") Long storeId, @Param("customerId") Long customerId,
                        @Param("from") LocalDateTime from, @Param("to") LocalDateTime to);
}
