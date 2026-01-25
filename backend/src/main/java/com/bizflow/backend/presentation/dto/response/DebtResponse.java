package com.bizflow.backend.presentation.dto.response;

import com.bizflow.backend.core.domain.Debt;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DebtResponse {
    private Long id;
    private Long customerId;
    private String customerName;
    private String customerPhone;
    private Long orderId;
    private BigDecimal originalAmount;
    private BigDecimal paidAmount;
    private BigDecimal unpaidAmount;
    private Debt.DebtStatus status;
    private LocalDate dueDate;
    private LocalDateTime createdAt;
    
    public static DebtResponse from(Debt debt, String customerName, String customerPhone) {
        return DebtResponse.builder()
                .id(debt.getId())
                .customerId(debt.getCustomerId())
                .customerName(customerName)
                .customerPhone(customerPhone)
                .orderId(debt.getOrderId())
                .originalAmount(debt.getOriginalAmount())
                .paidAmount(debt.getPaidAmount())
                .unpaidAmount(debt.getUnpaidAmount())
                .status(debt.getStatus())
                .dueDate(debt.getDueDate())
                .createdAt(debt.getCreatedAt())
                .build();
    }
}
