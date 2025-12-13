package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import org.springframework.security.core.userdetails.UserDetailsService;

import java.util.List;
import java.util.Optional;

/**
 * UserService: User management (authentication, authorization, CRUD)
 * 
 * Extends UserDetailsService for Spring Security integration
 */
public interface UserService extends UserDetailsService {
    
    // ========== Authentication ==========
    /**
     * Login user with username and password
     * Returns JWT access token and refresh token
     */
    LoginResponse login(LoginRequest request);
    
    /**
     * Register new user
     * Returns newly created user DTO
     */
    UserDTO register(RegisterRequest request);
    
    /**
     * Refresh access token using refresh token
     */
    LoginResponse refreshToken(String refreshToken);
    
    // ========== User Management ==========
    /**
     * Get user by ID
     */
    Optional<User> getUserById(Long id);
    
    /**
     * Get user by username
     */
    Optional<User> getUserByUsername(String username);
    
    /**
     * Get all users in a store
     */
    List<UserDTO> getUsersByStore(Long storeId);
    
    /**
     * Update user profile
     */
    UserDTO updateUser(Long userId, UserDTO updateDTO);
    
    /**
     * Change user password
     */
    void changePassword(Long userId, String oldPassword, String newPassword);
    
    /**
     * Get all users (admin only)
     */
    List<UserDTO> getAllUsers();
    
    /**
     * Create new user (admin/owner)
     */
    UserDTO createUser(RegisterRequest request);
    
    /**
     * Delete user
     */
    void deleteUser(Long userId);
}