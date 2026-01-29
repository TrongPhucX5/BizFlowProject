package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponse {
    private String token;
    private String refreshToken;
    private String username;
    private String role;
    private Long expiresIn;
    private LocalDateTime issuedAt;

    // THÊM: Đối tượng chứa chi tiết thông tin người dùng (fullName, email, phone...)
    private UserDTO user;

    // Giữ lại các trường phẳng nếu Frontend của bạn đang gọi trực tiếp từ cấp ngoài
    private Long userId;
    private String fullName;
    private String email;
    private String phone; // Bổ sung thêm phone ở đây cho đồng bộ
}