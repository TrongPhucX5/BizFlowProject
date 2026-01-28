package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Payment;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByDebtId(Long debtId);

    List<Payment> findByCustomerId(Long customerId);

    Page<Payment> findByCustomerId(Long customerId, org.springframework.data.domain.Pageable pageable);
}
