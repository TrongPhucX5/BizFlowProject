package com.bizflow.backend.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor // Dùng Lombok để tạo constructor
public class LoginResponse {
    private final String jwt;
    private final String role;
}