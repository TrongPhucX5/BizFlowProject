package com.bizflow.backend.presentation.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PayDebtRequest {

    @NotNull(message = "Số tiền trả không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Số tiền trả phải lớn hơn 0")
    private BigDecimal amount;

    private String paymentMethod; // CASH, BANK_TRANSFER, MOMO...

    private String note;
}
