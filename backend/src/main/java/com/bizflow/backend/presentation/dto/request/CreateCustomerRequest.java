package com.bizflow.backend.presentation.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateCustomerRequest {

    @NotBlank(message = "Tên khách hàng không được để trống")
    @Pattern(regexp = "^[^0-9]*$", message = "Tên khách hàng không được chứa chữ số")
    @Size(max = 100)
    @JsonProperty("fullName")
    private String fullName;

    @NotBlank(message = "Số điện thoại không được để trống")
    @Pattern(regexp = "^[0-9]*$", message = "Số điện thoại chỉ được chứa chữ số")
    @Size(min = 10, max = 15, message = "Số điện thoại phải từ 10-15 ký tự")
    private String phone;

    @Email(message = "Email không hợp lệ")
    @Size(max = 100)
    private String email;

    @Size(max = 255)
    private String address;

    private String gender;

    private String dob;

    private Long groupId;

    private String type; // RETAIL, WHOLESALE, CORPORATE

    @Size(max = 20)
    @JsonProperty("taxCode")
    private String taxCode;

    @Size(max = 100)
    private String contactPerson;

    @Size(max = 500)
    private String notes;

    // --- BỔ SUNG CÁC TRƯỜNG TÀI CHÍNH ĐỂ KHỚP VỚI SERVICE ---

    @JsonProperty("totalDebt")
    private BigDecimal totalDebt;

    @JsonProperty("totalPurchaseAmount")
    private BigDecimal totalPurchaseAmount;

    @JsonProperty("totalOrders")
    private Integer totalOrders;
}