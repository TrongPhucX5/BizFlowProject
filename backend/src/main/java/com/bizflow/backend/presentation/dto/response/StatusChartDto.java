package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StatusChartDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private String status;
    private Long count;

    public StatusChartDto(Object status, Long count) {
        this.status = status != null ? status.toString() : null;
        this.count = count;
    }
}
