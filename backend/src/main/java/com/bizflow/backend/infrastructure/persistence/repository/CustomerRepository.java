package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    /**
     * FIX LỖI: findFirstByNameContainingIgnoreCase
     * Dùng cho AIController để tìm khách hàng nhanh theo tên khi lên đơn AI
     */
    Optional<Customer> findFirstByNameContainingIgnoreCase(String name);

    /**
     * ĐẾM TẤT CẢ KHÁCH HÀNG ACTIVE
     * Dùng để hiển thị con số 19 trên Dashboard
     */
    long countByStatus(Customer.CustomerStatus status);

    /**
     * TÌM KIẾM THEO TRẠNG THÁI ACTIVE
     */
    @Query(
            value = "SELECT c FROM Customer c WHERE c.status = 'ACTIVE' AND (" +
                    "LOWER(c.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
                    "c.phone LIKE CONCAT('%', :search, '%'))",
            countQuery = "SELECT count(c) FROM Customer c WHERE c.status = 'ACTIVE' AND (" +
                    "LOWER(c.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
                    "c.phone LIKE CONCAT('%', :search, '%'))"
    )
    Page<Customer> findAllActiveWithSearch(
            @Param("search") String search,
            Pageable pageable
    );

    // Các hàm bổ trợ khác
    Page<Customer> findByStoreId(Long storeId, Pageable pageable);

    Page<Customer> findByStoreIdAndStatus(Long storeId, Customer.CustomerStatus status, Pageable pageable);

    Customer findByStoreIdAndPhone(Long storeId, String phone);

    Optional<Customer> findByNameContainingIgnoreCase(String name);
}