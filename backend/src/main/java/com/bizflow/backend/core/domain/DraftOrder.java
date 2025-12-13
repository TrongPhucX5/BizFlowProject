package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.math.BigDecimal;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "draft_orders")
public class DraftOrder {
    @Id
    @Column(length = 50)
    private String id;

    @Column(name = "store_id", nullable = false)
    private Long storeId;

    @Column(name = "customer_id")
    private Long customerId;

    @Column(name = "employee_id", nullable = false)
    private Long employeeId;

    @Column()
    private BigDecimal subtotal;

    @Column(name = "total_amount")
    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_type", columnDefinition = "ENUM('CASH', 'CREDIT') DEFAULT 'CASH'")
    private PaymentType paymentType;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "ENUM('DRAFT', 'CONFIRMED', 'REJECTED', 'EXPIRED') DEFAULT 'DRAFT'")
    private DraftStatus status;

    @Column(name = "related_order_id")
    private Long relatedOrderId;

    @Column(name = "ai_confidence")
    private java.math.BigDecimal aiConfidence;

    @Column(name = "ai_parsed_data", columnDefinition = "JSON")
    private String aiParsedData;

    @Column(name = "ai_request_text", length = 1000)
    private String aiRequestText;

    @Column(name = "rejection_reason", length = 500)
    private String rejectionReason;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "created_by", length = 30)
    private String createdBy;

    @Column(name = "confirmed_at")
    private LocalDateTime confirmedAt;

    public enum PaymentType {
        CASH, CREDIT
    }

    public enum DraftStatus {
        DRAFT, CONFIRMED, REJECTED, EXPIRED
    }
}
