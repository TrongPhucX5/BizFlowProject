package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "notifications")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "ENUM('ORDER_CREATED', 'PAYMENT_RECEIVED', 'DRAFT_READY', 'STOCK_LOW', 'DEBT_OVERDUE', 'SYSTEM')")
    private NotificationType type;

    @Column(length = 100)
    private String title;

    @Column(length = 500)
    private String message;

    @Column(name = "reference_id")
    private Long referenceId;

    @Column(name = "reference_type", length = 50)
    private String referenceType;

    @Column(name = "is_read")
    private Boolean isRead;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public enum NotificationType {
        ORDER_CREATED, PAYMENT_RECEIVED, DRAFT_READY, STOCK_LOW, DEBT_OVERDUE, SYSTEM
    }
}
