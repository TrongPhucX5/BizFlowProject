package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.StockMovement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    Page<StockMovement> findByStoreIdAndProductId(Long storeId, Long productId, Pageable pageable);
}
