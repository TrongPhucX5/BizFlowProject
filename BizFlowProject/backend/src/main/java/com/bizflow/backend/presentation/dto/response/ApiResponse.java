package com.bizflow.backend.presentation.dto.response;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    @Builder.Default
    private int code = 1000; // Mã mặc định thành công
    private String message;  // Thông báo (VD: "Thành công")
    private T result;        // Dữ liệu (User, Product, List...)
}