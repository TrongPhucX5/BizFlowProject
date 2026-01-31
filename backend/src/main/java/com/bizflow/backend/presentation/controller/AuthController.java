package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.domain.AuditLog;
import com.bizflow.backend.core.usecase.AuditLogService;
import com.bizflow.backend.core.usecase.CreateUserUseCase;
import com.bizflow.backend.core.usecase.UserService;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.PasswordUpdateRequest;
import com.bizflow.backend.presentation.dto.request.RefreshTokenRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;

/**
 * AuthController: Authentication and User management endpoints
 */
@Slf4j
@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

        private final UserService userService;
        private final CreateUserUseCase createUserUseCase;
        private final AuditLogService auditLogService;
        private final ObjectMapper objectMapper;

        /**
         * POST /v1/auth/login
         */
        @PostMapping("/login")
        public ResponseEntity<ApiResponse<LoginResponse>> login(
                        @Valid @RequestBody LoginRequest request,
                        HttpServletRequest servletRequest) {
                log.info("Login request for user: {}", request.getUsername());
                LoginResponse response = userService.login(request);
                log.info("Login successful for user: {}", request.getUsername());

                // Ghi nhật ký đăng nhập thủ công
                try {
                    String ipAddress = servletRequest.getHeader("X-Forwarded-For");
                    if (ipAddress == null || ipAddress.isEmpty()) {
                        ipAddress = servletRequest.getRemoteAddr();
                    } else {
                        ipAddress = ipAddress.split(",")[0];
                    }

                    AuditLog logEntry = AuditLog.builder()
                            .userId(response.getUser().getId())
                            .userName(response.getUser().getUsername())
                            .userFullName(response.getUser().getFullName())
                            .action("LOGIN")
                            .entityType("USER")
                            .entityId(response.getUser().getId())
                            .ipAddress(ipAddress)
                            .createdAt(LocalDateTime.now())
                            .newValue(objectMapper.writeValueAsString(java.util.Map.of(
                                    "status", "Thành công",
                                    "message", "Người dùng đăng nhập thành công",
                                    "loginTime", LocalDateTime.now().toString()
                            )))
                            .build();

                    auditLogService.createLog(logEntry);
                } catch (Exception e) {
                    log.error("Failed to create login audit log", e);
                }

                return ResponseEntity.ok(
                                ApiResponse.success(response, "Login successful"));
        }

        /**
         * POST /v1/auth/register
         */
        @PostMapping("/register")
        public ResponseEntity<ApiResponse<UserDTO>> register(
                @Valid @RequestBody RegisterRequest request) {
                log.info("Register request for user: {}", request.getUsername());

                UserDTO response = createUserUseCase.execute(request);

                log.info("User registered successfully: {}", request.getUsername());

                return ResponseEntity
                        .status(HttpStatus.CREATED)
                        .body(ApiResponse.success(response, "User registered successfully"));
        }

        /**
         * PATCH /v1/auth/change-password
         * Endpoint xử lý đổi mật khẩu cho người dùng hiện tại
         */
        @PatchMapping("/change-password")
        public ResponseEntity<ApiResponse<Void>> changePassword(
                @AuthenticationPrincipal CustomUserDetails userDetails,
                @Valid @RequestBody PasswordUpdateRequest request) {

                log.info("Change password request for user ID: {}", userDetails.getId());

                userService.changePassword(userDetails.getId(), request);

                log.info("Password updated successfully for user ID: {}", userDetails.getId());

                return ResponseEntity.ok(
                        ApiResponse.success(null, "Đổi mật khẩu thành công"));
        }

        /**
         * POST /v1/auth/refresh
         */
        @PostMapping("/refresh")
        public ResponseEntity<ApiResponse<LoginResponse>> refreshToken(
                @Valid @RequestBody RefreshTokenRequest request) {
                log.info("Token refresh request");
                LoginResponse response = userService.refreshToken(request.getRefreshToken());
                log.info("Token refreshed successfully");

                return ResponseEntity.ok(
                        ApiResponse.success(response, "Token refreshed successfully"));
        }

        /**
         * GET /v1/auth/verify
         */
        @GetMapping("/verify")
        public ResponseEntity<ApiResponse<String>> verifyToken() {
                log.info("Token verification successful");
                return ResponseEntity.ok(
                        ApiResponse.success("Token is valid", "Token verification successful"));
        }

        /**
         * GET /v1/auth/me
         */
        @GetMapping("/me")
        public ResponseEntity<ApiResponse<UserDTO>> getCurrentUser() {
                Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

                if (authentication == null || !authentication.isAuthenticated()) {
                        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                                .body(ApiResponse.error(HttpStatus.UNAUTHORIZED.value(),
                                        "User not authenticated"));
                }

                Object principal = authentication.getPrincipal();
                if (!(principal instanceof CustomUserDetails userDetails)) {
                        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                                .body(ApiResponse.error(HttpStatus.UNAUTHORIZED.value(),
                                        "Invalid authentication principal"));
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

                                return ResponseEntity.ok(ApiResponse.success(userDTO,
                                        "Lấy thông tin người dùng thành công"));
                        })
                        .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                                .body(ApiResponse.error(HttpStatus.NOT_FOUND.value(),
                                        "User not found")));
        }
}