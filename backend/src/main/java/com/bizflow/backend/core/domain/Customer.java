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

    // Giữ nguyên là name để khớp với Database hiện tại
    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 20)
    private String phone;

    @Column(length = 100)
    private String email;

    @Column(length = 255)
    private String address;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private CustomerType type;

    @Column(name = "tax_code", length = 20)
    private String taxCode;

    @Column(name = "contact_person", length = 100)
    private String contactPerson;

    // --- BỔ SUNG TRƯỜNG NÀY ĐỂ HẾT LỖI getTotalDebt() ---
    @Column(name = "total_debt")
    private BigDecimal totalDebt;
    // ----------------------------------------------------

    @Enumerated(EnumType.STRING)
    private CustomerStatus status;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum CustomerType {
        RETAIL, WHOLESALE
    }

    public enum CustomerStatus {
        ACTIVE, INACTIVE
    }
}