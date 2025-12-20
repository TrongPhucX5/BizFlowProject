package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductDTO {
    private Long id;
    private String name;
    private String sku;
    private BigDecimal price;
    private BigDecimal costPrice;
    private Long categoryId; // Added categoryId
    private Long unitId;     // Added unitId
    private Integer reorderLevel;
    private String unitName;
    private String description;
    private String status;
    private String imageUrl;
    private Long storeId;    // Added storeId
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
