package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TT88RevenueRow {
    private Integer stt;
    private LocalDate date;
    private String orderCode;
    private String customerName;
    private BigDecimal amount;
    private String note;
}
