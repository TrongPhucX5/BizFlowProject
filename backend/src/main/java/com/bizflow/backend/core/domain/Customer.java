package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "customers")
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "store_id", nullable = false)
    private Long storeId;

    // Giữ nguyên name để khớp với cột trong Database hiện tại
    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 20)
    private String phone;

    @Column(length = 100)
    private String email;

    @Column(length = 255)
    private String address;

    @Enumerated(EnumType.STRING)
    @Column(length = 25)
    private CustomerType type;

    @Column(name = "tax_code", length = 20)
    private String taxCode;

    @Column(name = "contact_person", length = 100)
    private String contactPerson;

    // --- CÁC TRƯỜNG TÀI CHÍNH & THỐNG KÊ ---
    // Khởi tạo giá trị mặc định là ZERO để tránh lỗi null khi tính toán
    @Builder.Default
    @Column(name = "total_debt", precision = 19, scale = 2)
    private BigDecimal totalDebt = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "total_purchase_amount", precision = 19, scale = 2)
    private BigDecimal totalPurchaseAmount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "total_orders")
    private Integer totalOrders = 0;

    // ---------------------------------------

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private CustomerStatus status = CustomerStatus.ACTIVE;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum CustomerType {
        RETAIL, WHOLESALE, CORPORATE
    }

    public enum CustomerStatus {
        ACTIVE, INACTIVE
    }
}