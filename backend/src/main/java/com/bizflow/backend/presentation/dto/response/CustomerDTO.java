package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerDTO {
    private Long id;
    private String name; // Tương thích với Mobile cũ
    private String fullName; // Dùng cho web và mobile mới
    private String phone;
    private String email;
    private String address;
    private String type;
    private String taxCode;
    private String contactPerson;
    private String status;
    private String notes;

    private String gender;
    private String dob;
    private Long groupId; // Để hiển thị nhóm khách hàng nếu cần

    // --- CÁC TRƯỜNG THỐNG KÊ (Đã sửa tên khớp Frontend) ---
    private BigDecimal totalDebt; // Tổng nợ
    private BigDecimal totalPurchaseAmount; // Tổng tiền mua (Khớp với frontend đang gọi)
    private Integer totalOrders; // Tổng đơn hàng
    // ------------------------------------------------------

    private Long storeId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}