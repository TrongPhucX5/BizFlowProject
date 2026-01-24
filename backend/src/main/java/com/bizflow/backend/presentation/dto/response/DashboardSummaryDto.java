package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummaryDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private long totalOrders;
    private BigDecimal totalRevenue;
    private BigDecimal pendingPayment;
    private long completedOrders;
}
