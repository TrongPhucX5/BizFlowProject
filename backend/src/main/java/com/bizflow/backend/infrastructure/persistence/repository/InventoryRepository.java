package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {
    Optional<Inventory> findByStoreIdAndProductId(Long storeId, Long productId);

    long countByStoreIdAndQuantityLessThanEqual(Long storeId, Integer quantity);

    @org.springframework.data.jpa.repository.Query("SELECT SUM(i.quantity) FROM Inventory i WHERE i.storeId = :storeId")
    Integer sumQuantityByStoreId(@org.springframework.data.repository.query.Param("storeId") Long storeId);
}
