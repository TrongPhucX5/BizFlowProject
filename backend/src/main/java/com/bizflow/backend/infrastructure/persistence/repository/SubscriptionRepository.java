package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, String> {
    Optional<Subscription> findByStoreId(Long storeId);
}
