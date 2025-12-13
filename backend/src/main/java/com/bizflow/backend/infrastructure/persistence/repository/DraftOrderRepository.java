package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.DraftOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DraftOrderRepository extends JpaRepository<DraftOrder, String> {
    List<DraftOrder> findByStoreIdAndStatus(Long storeId, DraftOrder.DraftStatus status);
}
