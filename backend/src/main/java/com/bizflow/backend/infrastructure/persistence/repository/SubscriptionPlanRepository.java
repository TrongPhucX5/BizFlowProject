package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.SubscriptionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubscriptionPlanRepository extends JpaRepository<SubscriptionPlan, Long> {
    List<SubscriptionPlan> findByStatus(SubscriptionPlan.PlanStatus status);

    @Query(value = "SELECT COUNT(*) FROM subscriptions WHERE plan_id = :planId", nativeQuery = true)
    long countSubscriptionsByPlanId(@Param("planId") Long planId);
}
