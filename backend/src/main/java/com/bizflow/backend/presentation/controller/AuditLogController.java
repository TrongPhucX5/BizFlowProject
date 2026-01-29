package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.AuditLogService;
import com.bizflow.backend.presentation.dto.response.AuditLogDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * AuditLogController: REST API for audit logs
 * Only accessible by SUPER_ADMIN role
 */
@RestController
@RequestMapping("/v1/audit-logs")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AuditLogController {

    private final AuditLogService auditLogService;

    /**
     * Get all audit logs with pagination
     * GET /v1/audit-logs?page=0&size=50
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getAllLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        log.info("GET /v1/audit-logs - page: {}, size: {}", page, size);
        
        Page<AuditLogDTO> logs = auditLogService.getLogs(page, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("result", logs.getContent());
        response.put("currentPage", logs.getNumber());
        response.put("totalItems", logs.getTotalElements());
        response.put("totalPages", logs.getTotalPages());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get audit logs by action filter
     * GET /v1/audit-logs/by-action?action=CREATE&page=0&size=50
     */
    @GetMapping("/by-action")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getLogsByAction(
            @RequestParam String action,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        log.info("GET /v1/audit-logs/by-action - action: {}, page: {}, size: {}", action, page, size);
        
        Page<AuditLogDTO> logs = auditLogService.getLogsByAction(action, page, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("result", logs.getContent());
        response.put("currentPage", logs.getNumber());
        response.put("totalItems", logs.getTotalElements());
        response.put("totalPages", logs.getTotalPages());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get audit logs by entity type filter
     * GET /v1/audit-logs/by-entity?entityType=PRODUCT&page=0&size=50
     */
    @GetMapping("/by-entity")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getLogsByEntity(
            @RequestParam String entityType,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        log.info("GET /v1/audit-logs/by-entity - entityType: {}, page: {}, size: {}", entityType, page, size);
        
        Page<AuditLogDTO> logs = auditLogService.getLogsByEntity(entityType, page, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("result", logs.getContent());
        response.put("currentPage", logs.getNumber());
        response.put("totalItems", logs.getTotalElements());
        response.put("totalPages", logs.getTotalPages());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get audit logs by user ID filter
     * GET /v1/audit-logs/by-user?userId=1&page=0&size=50
     */
    @GetMapping("/by-user")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getLogsByUser(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        log.info("GET /v1/audit-logs/by-user - userId: {}, page: {}, size: {}", userId, page, size);
        
        Page<AuditLogDTO> logs = auditLogService.getLogsByUser(userId, page, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("result", logs.getContent());
        response.put("currentPage", logs.getNumber());
        response.put("totalItems", logs.getTotalElements());
        response.put("totalPages", logs.getTotalPages());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get specific audit log by ID
     * GET /v1/audit-logs/{id}
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getLogById(@PathVariable Long id) {
        log.info("GET /v1/audit-logs/{}", id);
        
        AuditLogDTO log = auditLogService.getLogById(id);
        
        Map<String, Object> response = new HashMap<>();
        response.put("result", log);
        
        return ResponseEntity.ok(response);
    }
}
