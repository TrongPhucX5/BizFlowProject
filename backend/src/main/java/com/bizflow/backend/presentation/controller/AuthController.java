package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.UserService;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.RefreshTokenRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    public ResponseEntity<ApiResponse<String>> getCurrentUser() {
        log.info("Get current user called");

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Current user details",
                        "User information retrieved successfully"
                )
        );
    }
}
