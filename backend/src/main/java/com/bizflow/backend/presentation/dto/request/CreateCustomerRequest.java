package com.bizflow.backend.presentation.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateCustomerRequest {
    @NotBlank(message = "Tên khách hàng không được rỗng")
    @Size(max = 100)
    private String name;

    @Size(max = 15)
    private String phone;

    @Email(message = "Email không hợp lệ")
    @Size(max = 100)
    private String email;

    @Size(max = 255)
    private String address;

    private String type; // RETAIL, WHOLESALE, CORPORATE

    @Size(max = 20)
    private String taxCode;

    @Size(max = 100)
    private String contactPerson;

    @Size(max = 500)
    private String notes;
}
