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

    public RevenueChartDto(Object date, BigDecimal revenue, Long orderCount) {
        if (date instanceof java.sql.Date) {
            this.date = ((java.sql.Date) date).toLocalDate();
        } else if (date instanceof LocalDate) {
            this.date = (LocalDate) date;
        } else if (date != null) {
            // Fallback strategy if needed, or just toString() parser?
            // For now, assume it's one of the date types.
            this.date = LocalDate.parse(date.toString());
        }
        this.revenue = revenue;
        this.orderCount = orderCount;
    }
}
