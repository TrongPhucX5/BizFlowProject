package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    Page<Customer> findByStoreId(Long storeId, Pageable pageable);
    Customer findByStoreIdAndPhone(Long storeId, String phone);
    long countByStoreId(Long storeId);
}
