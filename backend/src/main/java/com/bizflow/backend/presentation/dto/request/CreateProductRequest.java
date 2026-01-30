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

    @Size(max = 1024)
    private String description;

    // Xóa bỏ validation @Size để cho phép lưu chuỗi Base64
    private String imageUrl;

    private Boolean trackStock;

    // Thêm trường tồn kho ban đầu (hỗ trợ nhiều tên trường khác nhau từ frontend)
    private Integer initialStock;
    private Integer stock;
    private Integer quantity;

    public Integer getInitialStock() {
        if (initialStock != null) return initialStock;
        if (stock != null) return stock;
        if (quantity != null) return quantity;
        return 0;
    }
}