package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;
// Đường dẫn: src/main/java/com/bizflow/backend/infrastructure/persistence/repository/CustomerRepository.java

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    @Query("SELECT c FROM Customer c WHERE c.storeId = :storeId AND c.status = :status AND (" +
            "LOWER(c.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
            "c.phone LIKE CONCAT('%', :search, '%'))")
    Page<Customer> findByStoreIdAndStatusWithSearch(
            @Param("storeId") Long storeId,
            @Param("status") Customer.CustomerStatus status,
            @Param("search") String search,
            Pageable pageable
    );
    Page<Customer> findByStoreIdAndStatus(Long storeId, Customer.CustomerStatus status, Pageable pageable);

    Page<Customer> findByStoreId(Long storeId, Pageable pageable);
    Customer findByStoreIdAndPhone(Long storeId, String phone);
    long countByStoreId(Long storeId);
}