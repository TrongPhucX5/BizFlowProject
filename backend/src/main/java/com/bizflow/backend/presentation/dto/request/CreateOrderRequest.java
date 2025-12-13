package com.bizflow.backend.presentation.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateOrderRequest {
    @NotNull(message = "ID khách hàng không được rỗng")
    private Long customerId;

    @NotEmpty(message = "Đơn hàng phải có ít nhất 1 sản phẩm")
    @Valid
    private List<OrderItemRequest> items;

    @DecimalMin(value = "0", message = "Tiền chiết khấu không được âm")
    private BigDecimal discountAmount;

    private String paymentType; // CASH, CREDIT, TRANSFER

    @jakarta.validation.constraints.Size(max = 500)
    private String notes;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class OrderItemRequest {
        @NotNull
        private Long productId;

        @NotNull(message = "Số lượng không được rỗng")
        @DecimalMin(value = "1", message = "Số lượng phải >= 1")
        private Integer quantity;
    }
}
