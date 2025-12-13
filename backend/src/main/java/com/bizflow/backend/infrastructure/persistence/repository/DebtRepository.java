package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Debt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DebtRepository extends JpaRepository<Debt, Long> {
    Page<Debt> findByStoreId(Long storeId, Pageable pageable);
    Page<Debt> findByCustomerId(Long customerId, Pageable pageable);
    Page<Debt> findByStatus(Debt.DebtStatus status, Pageable pageable);
}
