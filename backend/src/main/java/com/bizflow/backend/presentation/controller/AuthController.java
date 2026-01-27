package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.UserService;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.RefreshTokenRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * AuthController: Authentication endpoints
 * 
 * Endpoints:
 * - POST /auth/login - Login with username/password
 * - POST /auth/register - Register new user account
 * - POST /auth/refresh - Refresh access token
 * 
 * Security:
 * - All endpoints are PUBLIC (no JWT required)
 * - Credentials validated via UserService
 * - JWT tokens generated on successful auth
 */
@Slf4j
@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    /**
     * POST /auth/login
     * 
     * Login user with username and password
     * Returns JWT access token + refresh token
     * 
     * Request: { "username": "admin", "password": "admin123" }
     * Response: { "userId": 1, "username": "admin", "token": "eyJ0eX...", "refreshToken": "eyJ0eX..." }
     * Status: 200 OK
     * 
     * Error Cases:
     * - Invalid username: 401 Unauthorized
     * - Invalid password: 401 Unauthorized
     * - User account inactive: 400 Bad Request
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        log.info("Login request for user: {}", request.getUsername());

        LoginResponse response = userService.login(request);

        log.info("Login successful for user: {}", request.getUsername());

        return ResponseEntity.ok(
                ApiResponse.success(
                        response,
                        "Login successful"
                )
        );
    }

    /**
     * POST /auth/register
     * 
     * Register new user account
     * Automatically sets default store_id and role (EMPLOYEE)
     * Password is hashed using BCrypt
     * 
     * Request: {
     *   "username": "newuser",
     *   "password": "password123",
     *   "fullName": "Ngô Văn Tú",
     *   "email": "tu@example.com",
     *   "phone": "0909123456",
     *   "storeId": 1
     * }
     * Response: { "id": 5, "username": "newuser", "email": "tu@example.com", "role": "EMPLOYEE" }
     * Status: 201 Created
     * 
     * Error Cases:
     * - Username already exists: 400 Bad Request (code 4009)
     * - Email already exists: 400 Bad Request (code 4010)
     * - Invalid input: 400 Bad Request
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserDTO>> register(
            @Valid @RequestBody RegisterRequest request) {
        log.info("Register request for user: {}", request.getUsername());

        UserDTO response = userService.register(request);

        log.info("User registered successfully: {}", request.getUsername());

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(
                        response,
                        "User registered successfully"
                ));
    }

    /**
     * POST /auth/refresh
     * 
     * Refresh access token using refresh token
     * Used when access token expires (every 24 hours)
     * Refresh token must be valid (not expired)
     * 
     * Request: { "refreshToken": "eyJ0eXAiOiJKV1QiLCJhbGc..." }
     * Response: { "userId": 1, "username": "admin", "token": "eyJ0eX..." }
     * Status: 200 OK
     * 
     * Error Cases:
     * - Invalid refresh token: 401 Unauthorized
     * - Expired refresh token: 401 Unauthorized
     * - User not found: 404 Not Found
     * - User account inactive: 400 Bad Request
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<LoginResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request) {
        log.info("Token refresh request");

        LoginResponse response = userService.refreshToken(request.getRefreshToken());

        log.info("Token refreshed successfully");

        return ResponseEntity.ok(
                ApiResponse.success(
                        response,
                        "Token refreshed successfully"
                )
        );
    }

    /**
     * GET /auth/verify
     * 
     * Verify JWT token is valid
     * Requires JWT authentication (JWT is validated by JwtRequestFilter)
     * 
     * Response: { "valid": true, "userId": 1, "username": "admin" }
     * Status: 200 OK
     * 
     * Security: Requires valid JWT token in Authorization header
     */
    @GetMapping("/verify")
    public ResponseEntity<ApiResponse<String>> verifyToken() {
        log.info("Token verification successful");

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Token is valid",
                        "Token verification successful"
                )
        );
    }

    /**
     * GET /auth/me
     * 
     * Get current authenticated user details
     * Extracted from JWT token (populated by JwtRequestFilter)
     * 
     * Response: { "id": 1, "username": "admin", "email": "admin@example.com", "role": "ADMIN" }
     * Status: 200 OK
     * 
     * Security: Requires valid JWT token in Authorization header
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDTO>> getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(HttpStatus.UNAUTHORIZED.value(), "User not authenticated"));
        }

        Object principal = authentication.getPrincipal();
        if (!(principal instanceof CustomUserDetails userDetails)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(HttpStatus.UNAUTHORIZED.value(), "Invalid authentication principal"));
        }

        return userService.getUserById(userDetails.getId())
                .map(user -> {
                    UserDTO userDTO = UserDTO.builder()
                            .id(user.getId())
                            .username(user.getUsername())
                            .fullName(user.getFullName())
                            .email(user.getEmail())
                            .phone(user.getPhone())
                            .role(user.getRole().toString())
                            .storeId(user.getStoreId())
                            .status(user.getStatus().toString())
                            .createdAt(user.getCreatedAt())
                            .updatedAt(user.getUpdatedAt())
                            .build();

                    return ResponseEntity.ok(ApiResponse.success(userDTO, "Lấy thông tin người dùng thành công"));
                })
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(HttpStatus.NOT_FOUND.value(), "User not found")));
    }
}
