package com.bizflow.backend.presentation.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateProductRequest {
    @NotBlank(message = "Tên sản phẩm không được rỗng")
    @Size(max = 100)
    private String name;

    @NotBlank(message = "SKU không được rỗng")
    @Size(max = 50)
    private String sku;

    @NotNull(message = "Giá không được rỗng")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá phải lớn hơn 0")
    private BigDecimal price;

    private BigDecimal costPrice;

    private Long categoryId;

    private Long unitId;

    private Integer reorderLevel;

    @Size(max = 500)
    private String description;

    @Size(max = 500)
    private String imageUrl;
}
