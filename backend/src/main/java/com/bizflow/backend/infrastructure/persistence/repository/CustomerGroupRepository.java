package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.CustomerGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CustomerGroupRepository extends JpaRepository<CustomerGroup, Long> {
    List<CustomerGroup> findByStoreId(Long storeId);
}
