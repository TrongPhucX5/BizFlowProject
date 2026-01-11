package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private Long id;
    private String name;
    private String sku;
    private BigDecimal price;
    private BigDecimal costPrice;

    // --- BẮT BUỘC PHẢI CÓ DÒNG NÀY MỚI HẾT LỖI 'cannot find symbol method stock' ---
    private Integer stock;
    // -----------------------------------------------------------------------------

    private Long categoryId;
    private String categoryName;

    private Long unitId;
    private String unitName;

    private String description;
    private String imageUrl;
    private String status;
    private Long storeId;
}