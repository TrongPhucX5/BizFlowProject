package com.bizflow.backend.presentation.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRequest {
    @NotBlank(message = "Username không được rỗng")
    @Size(min = 3, max = 30, message = "Username phải từ 3-30 ký tự")
    private String username;

    @NotBlank(message = "Mật khẩu không được rỗng")
    @Size(min = 6, message = "Mật khẩu phải ít nhất 6 ký tự")
    private String password;
}
