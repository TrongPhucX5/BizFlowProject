package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TT88DebtRow {
    private Integer stt;
    private String customerName;
    private String phone;
    private BigDecimal openingDebt;   // nợ đầu kỳ
    private BigDecimal newDebt;       // phát sinh
    private BigDecimal paid;          // đã trả
    private BigDecimal closingDebt;   // nợ cuối kỳ
}
