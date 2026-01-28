package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RevenueChartDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private LocalDate date;
    private BigDecimal revenue;
    private Long orderCount;
    private BigDecimal profit;

    public RevenueChartDto(Object date, BigDecimal revenue, Long orderCount, BigDecimal profit) {
        if (date instanceof java.sql.Date) {
            this.date = ((java.sql.Date) date).toLocalDate();
        } else if (date instanceof LocalDate) {
            this.date = (LocalDate) date;
        } else if (date != null) {
            // Fallback strategy if needed
            this.date = LocalDate.parse(date.toString());
        }
        this.revenue = revenue;
        this.orderCount = orderCount;
        this.profit = profit != null ? profit : BigDecimal.ZERO;
    }
}
