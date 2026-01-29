package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.domain.AuditLog;
import com.bizflow.backend.core.usecase.AuditLogService;
import com.bizflow.backend.infrastructure.persistence.repository.AuditLogRepository;
import com.bizflow.backend.presentation.dto.response.AuditLogDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Override
    public Page<AuditLogDTO> getLogs(int page, int size) {
        log.debug("Getting audit logs - page: {}, size: {}", page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> auditLogs = auditLogRepository.findAllByOrderByCreatedAtDesc(pageable);
        return auditLogs.map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getLogsByAction(String action, int page, int size) {
        log.debug("Getting audit logs by action: {} - page: {}, size: {}", action, page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> auditLogs = auditLogRepository.findByActionContainingIgnoreCaseOrderByCreatedAtDesc(action, pageable);
        return auditLogs.map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getLogsByEntity(String entityType, int page, int size) {
        log.debug("Getting audit logs by entity type: {} - page: {}, size: {}", entityType, page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> auditLogs = auditLogRepository.findByEntityTypeOrderByCreatedAtDesc(entityType, pageable);
        return auditLogs.map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getLogsByUser(Long userId, int page, int size) {
        log.debug("Getting audit logs by user ID: {} - page: {}, size: {}", userId, page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> auditLogs = auditLogRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return auditLogs.map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getLogsByDateRange(LocalDateTime startDate, LocalDateTime endDate, int page, int size) {
        log.debug("Getting audit logs by date range: {} to {} - page: {}, size: {}", startDate, endDate, page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> auditLogs = auditLogRepository.findByDateRange(startDate, endDate, pageable);
        return auditLogs.map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getLogsByFilters(String action, String entityType, Long userId, int page, int size) {
        log.debug("Getting audit logs with filters - action: {}, entityType: {}, userId: {} - page: {}, size: {}", 
                  action, entityType, userId, page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> auditLogs = auditLogRepository.findByFilters(action, entityType, userId, pageable);
        return auditLogs.map(this::convertToDTO);
    }

    @Override
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void createLog(AuditLog auditLog) {
        log.debug("Creating audit log: {}", auditLog);
        auditLogRepository.save(auditLog);
    }

    @Override
    public AuditLogDTO getLogById(Long id) {
        log.debug("Getting audit log by ID: {}", id);
        AuditLog auditLog = auditLogRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Audit log not found with ID: " + id));
        return convertToDTO(auditLog);
    }

    /**
     * Convert AuditLog entity to AuditLogDTO
     */
    private AuditLogDTO convertToDTO(AuditLog auditLog) {
        return AuditLogDTO.builder()
                .id(auditLog.getId())
                .userId(auditLog.getUserId())
                .userName(auditLog.getUserName())
                .userFullName(auditLog.getUserFullName())
                .action(auditLog.getAction())
                .entityType(auditLog.getEntityType())
                .entityId(auditLog.getEntityId())
                .oldValue(auditLog.getOldValue())
                .newValue(auditLog.getNewValue())
                .ipAddress(auditLog.getIpAddress())
                .createdAt(auditLog.getCreatedAt())
                .build();
    }
}
