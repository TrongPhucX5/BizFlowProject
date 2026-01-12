package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "customers")
@SuppressWarnings("all")
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "store_id", nullable = false)
    private Long storeId;

    @NotBlank(message = "Tên khách hàng không được để trống")
    @Size(min = 6, message = "Tên khách hàng phải có ít nhất 6 ký tự")
    @Pattern(
            regexp = "^[\\p{L} ]+$",
            message = "Tên khách hàng chỉ được phép chứa chữ cái và khoảng trắng"
    )
    @Column(nullable = false, length = 100)
    private String name;

    // --- ĐÃ SỬA: Bỏ NotBlank và Pattern để không bắt buộc nhập 10-11 số ---
    @Column(length = 15)
    private String phone;

    @Column(length = 100)
    private String email;

    @Column(length = 255)
    private String address;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private CustomerType type;

    @Column(name = "tax_code", length = 20)
    private String taxCode;

    @Column(name = "contact_person", length = 100)
    private String contactPerson;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private CustomerStatus status;

    @Column(length = 500)
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
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

    @PrePersist
    protected void onCreate() {
        if (this.type == null) this.type = CustomerType.RETAIL;
        if (this.status == null) this.status = CustomerStatus.ACTIVE;
        if (this.storeId == null) this.storeId = 1L;
    }
}