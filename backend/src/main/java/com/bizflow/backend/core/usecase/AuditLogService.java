package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.AuditLog;
import com.bizflow.backend.presentation.dto.response.AuditLogDTO;
import org.springframework.data.domain.Page;

import java.time.LocalDateTime;

/**
 * AuditLogService: Service for managing audit logs
 * Provides methods to retrieve and filter audit logs with pagination
 */
public interface AuditLogService {
    
    /**
     * Get all audit logs with pagination
     * @param page Page number (0-indexed)
     * @param size Number of items per page
     * @return Page of AuditLogDTO
     */
    Page<AuditLogDTO> getLogs(int page, int size);
    
    /**
     * Get audit logs filtered by action type
     * @param action Action type to filter (e.g., "CREATE", "UPDATE", "DELETE")
     * @param page Page number
     * @param size Page size
     * @return Page of AuditLogDTO
     */
    Page<AuditLogDTO> getLogsByAction(String action, int page, int size);
    
    /**
     * Get audit logs filtered by entity type
     * @param entityType Entity type to filter (e.g., "PRODUCT", "CUSTOMER")
     * @param page Page number
     * @param size Page size
     * @return Page of AuditLogDTO
     */
    Page<AuditLogDTO> getLogsByEntity(String entityType, int page, int size);
    
    /**
     * Get audit logs filtered by user ID
     * @param userId User ID to filter
     * @param page Page number
     * @param size Page size
     * @return Page of AuditLogDTO
     */
    Page<AuditLogDTO> getLogsByUser(Long userId, int page, int size);
    
    /**
     * Get audit logs by date range
     * @param startDate Start date
     * @param endDate End date
     * @param page Page number
     * @param size Page size
     * @return Page of AuditLogDTO
     */
    Page<AuditLogDTO> getLogsByDateRange(LocalDateTime startDate, LocalDateTime endDate, int page, int size);
    
    /**
     * Get audit logs with multiple filters
     * @param action Action filter (nullable)
     * @param entityType Entity type filter (nullable)
     * @param userId User ID filter (nullable)
     * @param page Page number
     * @param size Page size
     * @return Page of AuditLogDTO
     */
    Page<AuditLogDTO> getLogsByFilters(String action, String entityType, Long userId, int page, int size);
    
    /**
     * Create a new audit log entry
     * @param log AuditLog entity to save
     */
    void createLog(AuditLog log);
    
    /**
     * Get a specific audit log by ID
     * @param id Audit log ID
     * @return AuditLogDTO
     */
    AuditLogDTO getLogById(Long id);
}
