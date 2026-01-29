package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StoreRepository extends JpaRepository<Store, Long> {
    Store findByTaxCode(String taxCode);

    @org.springframework.data.jpa.repository.Query("SELECT s FROM Store s WHERE " +
            "(:search IS NULL OR LOWER(s.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
            "s.taxCode LIKE CONCAT('%', :search, '%'))")
    org.springframework.data.domain.Page<Store> searchStores(String search, org.springframework.data.domain.Pageable pageable);

    @org.springframework.data.jpa.repository.Query("SELECT COUNT(s) FROM Store s WHERE s.status = 'ACTIVE'")
    long countActiveTenants();

    @org.springframework.data.jpa.repository.Query("SELECT COUNT(s) FROM Store s WHERE (:startDate IS NULL OR s.createdAt >= :startDate) AND (:endDate IS NULL OR s.createdAt <= :endDate)")
    long countNewStores(@org.springframework.data.repository.query.Param("startDate") java.time.LocalDateTime startDate, @org.springframework.data.repository.query.Param("endDate") java.time.LocalDateTime endDate);

    List<Store> findTop5ByOrderByCreatedAtDesc();
}
