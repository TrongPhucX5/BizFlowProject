package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StoreRepository extends JpaRepository<Store, Long> {
    Store findByTaxCode(String taxCode);
}
