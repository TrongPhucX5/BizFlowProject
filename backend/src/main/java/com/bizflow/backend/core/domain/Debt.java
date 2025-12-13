package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.math.BigDecimal;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "debts")
public class Debt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "store_id", nullable = false)
    private Long storeId;

    @Column(name = "order_id")
    private Long orderId;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "original_amount", nullable = false)
    private BigDecimal originalAmount;

    @Column(name = "paid_amount")
    private BigDecimal paidAmount;

    @Column(name = "unpaid_amount")
    private BigDecimal unpaidAmount;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "ENUM('UNPAID', 'PAID', 'PAID_PARTIAL', 'OVERDUE', 'CANCELLED') DEFAULT 'UNPAID'")
    private DebtStatus status;

    @Column(name = "due_date")
    private LocalDate dueDate;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum DebtStatus {
        UNPAID, PAID, PAID_PARTIAL, OVERDUE, CANCELLED
    }
}
