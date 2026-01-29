package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
    
    // Find all logs with pagination, ordered by creation time descending
    Page<AuditLog> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    // Find logs by action type
    Page<AuditLog> findByActionContainingIgnoreCaseOrderByCreatedAtDesc(String action, Pageable pageable);
    
    // Find logs by entity type
    Page<AuditLog> findByEntityTypeOrderByCreatedAtDesc(String entityType, Pageable pageable);
    
    // Find logs by user ID
    Page<AuditLog> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
    
    // Find logs by user name
    Page<AuditLog> findByUserNameContainingIgnoreCaseOrderByCreatedAtDesc(String userName, Pageable pageable);
    
    // Find logs by date range
    @Query("SELECT a FROM AuditLog a WHERE a.createdAt BETWEEN :startDate AND :endDate ORDER BY a.createdAt DESC")
    Page<AuditLog> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                    @Param("endDate") LocalDateTime endDate, 
                                    Pageable pageable);
    
    // Find logs by multiple filters
    @Query("SELECT a FROM AuditLog a WHERE " +
           "(:action IS NULL OR UPPER(a.action) LIKE UPPER(CONCAT('%', :action, '%'))) AND " +
           "(:entityType IS NULL OR a.entityType = :entityType) AND " +
           "(:userId IS NULL OR a.userId = :userId) " +
           "ORDER BY a.createdAt DESC")
    Page<AuditLog> findByFilters(@Param("action") String action,
                                  @Param("entityType") String entityType,
                                  @Param("userId") Long userId,
                                  Pageable pageable);
}
