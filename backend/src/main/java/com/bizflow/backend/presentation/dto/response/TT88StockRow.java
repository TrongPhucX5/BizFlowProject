package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TT88StockRow {
    private Integer stt;
    private String productCode;
    private String productName;
    private Integer openingStock;
    private Integer imported;
    private Integer exported;
    private Integer closingStock;
}
