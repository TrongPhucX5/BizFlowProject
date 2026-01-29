package com.bizflow.backend.infrastructure.aspect;

import com.bizflow.backend.core.annotation.AuditAction;
import com.bizflow.backend.core.domain.AuditLog;
import com.bizflow.backend.core.usecase.AuditLogService;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import org.springframework.context.ApplicationContext;
import org.springframework.data.jpa.repository.JpaRepository;
import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.util.Optional;

@Aspect
@Component
@Slf4j
@RequiredArgsConstructor
public class AuditAspect {

    private final ApplicationContext applicationContext;
    private final AuditLogService auditLogService;
    private final ObjectMapper objectMapper;

    @Around("@annotation(com.bizflow.backend.core.annotation.AuditAction)")
    public Object logAuditAction(ProceedingJoinPoint joinPoint) throws Throwable {
        Object result = joinPoint.proceed();

        try {
            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Method method = signature.getMethod();
            AuditAction auditAction = method.getAnnotation(AuditAction.class);

            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            
            if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
                
                String ipAddress = getClientIp();
                Long entityId = null;
                String oldValue = null;
                
                // 1. Resolve Entity ID (Before action for DELETES)
                Object[] args = joinPoint.getArgs();
                if (args.length > 0 && args[0] instanceof Long) {
                    entityId = (Long) args[0];
                }

                // 2. Fetch Old Value if needed (e.g., for DELETE)
                if (auditAction.action().contains("DELETE") && entityId != null) {
                    try {
                        String repoName = auditAction.entityType().toLowerCase() + "Repository";
                        Object repo = applicationContext.getBean(repoName);
                        if (repo instanceof JpaRepository) {
                            Method findByIdMethod = repo.getClass().getMethod("findById", Object.class);
                            Optional<?> entity = (Optional<?>) findByIdMethod.invoke(repo, entityId);
                            if (entity.isPresent()) {
                                oldValue = toJson(entity.get());
                            }
                        }
                    } catch (Exception e) {
                        log.warn("Could not fetch old value for audit log: {}", e.getMessage());
                    }
                }

                // Proceed with action (if not already done)
                // Actually, the current Around advice proceeds FIRST (line 35)
                // Let's re-think: result is for CREATE/UPDATE. For DELETE, result is void.

                // 3. Resolve Entity ID from Result (for CREATE/UPDATED)
                if (entityId == null && result != null) {
                    try {
                        Method getIdMethod = result.getClass().getMethod("getId");
                        Object idObj = getIdMethod.invoke(result);
                        if (idObj instanceof Long) {
                            entityId = (Long) idObj;
                        }
                    } catch (Exception ignored) {}
                }

                AuditLog logEntry = AuditLog.builder()
                        .userId(userDetails.getId())
                        .userName(userDetails.getUsername())
                        .userFullName(userDetails.getFullName())
                        .action(auditAction.action())
                        .entityType(auditAction.entityType())
                        .entityId(entityId)
                        .ipAddress(ipAddress)
                        .createdAt(LocalDateTime.now())
                        .oldValue(oldValue)
                        .newValue(toJson(result))
                        .build();

                auditLogService.createLog(logEntry);
                log.info("Audit log created for action: {} by user: {}", auditAction.action(), userDetails.getUsername());
            }
        } catch (Exception e) {
            log.error("Failed to create audit log", e);
        }

        return result;
    }

    private String getClientIp() {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String xForwardedFor = request.getHeader("X-Forwarded-For");
                if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
                    return xForwardedFor.split(",")[0];
                }
                return request.getRemoteAddr();
            }
        } catch (Exception ignored) {}
        return "UNKNOWN";
    }

    private String toJson(Object obj) {
        try {
            if (obj == null) return null;
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return "Error converting to JSON";
        }
    }
    

}
