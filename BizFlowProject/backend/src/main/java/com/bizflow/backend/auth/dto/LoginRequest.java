package com.bizflow.backend.auth.dto;

import lombok.Data;

@Data // Dùng Lombok để tạo getter/setter
public class LoginRequest {
    private String username;
    private String password;
}