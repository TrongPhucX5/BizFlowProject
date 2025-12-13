package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.math.BigDecimal;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "store_id", nullable = false)
    private Long storeId;

    @Column(name = "order_number", nullable = false, unique = true, length = 50)
    private String orderNumber;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "employee_id")
    private Long employeeId;

    @Column(nullable = false)
    private BigDecimal subtotal;

    @Column(name = "discount_amount")
    private BigDecimal discountAmount;

    @Column(name = "total_amount", nullable = false)
    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_type", columnDefinition = "ENUM('CASH', 'CREDIT', 'TRANSFER') DEFAULT 'CASH'")
    private PaymentType paymentType;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "ENUM('CONFIRMED', 'PAID', 'PAID_PARTIAL', 'UNPAID', 'CANCELLED') DEFAULT 'CONFIRMED'")
    private OrderStatus status;

    @Column(length = 500)
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "created_by", length = 30)
    private String createdBy;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum PaymentType {
        CASH, CREDIT, TRANSFER
    }

    public enum OrderStatus {
        CONFIRMED, PAID, PAID_PARTIAL, UNPAID, CANCELLED
    }
}
