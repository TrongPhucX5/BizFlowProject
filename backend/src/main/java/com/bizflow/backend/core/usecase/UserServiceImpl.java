package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.bizflow.backend.infrastructure.security.JwtUtil;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import com.bizflow.backend.presentation.exception.BusinessException;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import com.bizflow.backend.presentation.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * UserServiceImpl: User authentication and management
 * 
 * KEY RESPONSIBILITIES:
 * 1. Authentication (login, register, token refresh)
 * 2. Password hashing (BCrypt via PasswordEncoder)
 * 3. JWT token generation (via JwtUtil)
 * 4. User CRUD operations
 * 5. User details loading (for Spring Security)
 * 
 * PATTERN:
 * - Validate input → Check business rules → Build entity → Persist → Return DTO
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    // ========== Authentication Methods ==========

    /**
     * Login: Verify username/password and return JWT tokens
     * 
     * Flow:
     * 1. Find user by username
     * 2. Verify password matches (BCrypt)
     * 3. Verify user is active (not locked/deleted)
     * 4. Generate access token + refresh token
     * 5. Update last_login_at
     * 6. Return LoginResponse with tokens
     */
    @Transactional
    @Override
    public LoginResponse login(LoginRequest request) {
        log.info("Login attempt for user: {}", request.getUsername());

        // 1. Find user
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UnauthorizedException("Invalid username or password"));

        // 2. Verify password (compare request password with BCrypt hash)
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Invalid username or password");
        }

        // 3. Verify user is active
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new BusinessException(4008, "User account is not active. Status: " + user.getStatus());
        }

        // 4. Create CustomUserDetails (for JWT token)
        CustomUserDetails userDetails = new CustomUserDetails(
                user.getId(),
                user.getStoreId(),
                user.getUsername(),
                user.getPassword(),
                user.getRole().toString(),
                true
        );

        // 5. Generate tokens
        String accessToken = jwtUtil.generateAccessToken(userDetails);
        String refreshToken = jwtUtil.generateRefreshToken(userDetails);

        // 6. Update last login timestamp
        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        log.info("Login successful for user: {}", request.getUsername());

        // 7. Build response
        return LoginResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole().toString())
                .token(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(86400000L) // 24 hours in milliseconds
                .issuedAt(LocalDateTime.now())
                .build();
    }

    /**
     * Register: Create new user account
     * 
     * Flow:
     * 1. Validate username not already taken
     * 2. Validate email not already taken (if provided)
     * 3. Hash password using BCrypt
     * 4. Create User entity
     * 5. Persist to database
     * 6. Return UserDTO
     */
    @Transactional
    @Override
    public UserDTO register(RegisterRequest request) {
        log.info("Register attempt for username: {}", request.getUsername());

        // 1. Check username already exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BusinessException(4009, "Username already exists: " + request.getUsername());
        }

        // 2. Check email already exists (if provided)
        if (request.getEmail() != null) {
            Optional<User> existingEmail = userRepository.findByEmail(request.getEmail());
            if (existingEmail.isPresent()) {
                throw new BusinessException(4010, "Email already registered: " + request.getEmail());
            }
        }

        // 3. Hash password
        String hashedPassword = passwordEncoder.encode(request.getPassword());

        // 4. Create User entity
        User user = User.builder()
                .storeId(request.getStoreId())
                .username(request.getUsername())
                .password(hashedPassword)
                .fullName(request.getFullName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .role(User.UserRole.EMPLOYEE) // Default role
                .status(User.UserStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        // 5. Persist
        User savedUser = userRepository.save(user);

        log.info("User registered successfully: {}", request.getUsername());

        // 6. Return DTO
        return mapToDTO(savedUser);
    }

    /**
     * Refresh Token: Generate new access token using refresh token
     * 
     * Flow:
     * 1. Validate refresh token signature & expiration
     * 2. Extract username from refresh token
     * 3. Load user from database (verify still exists & active)
     * 4. Generate new access token (NOT refresh token)
     * 5. Return new access token
     */
    @Override
    public LoginResponse refreshToken(String refreshToken) {
        // 1. Validate token
        if (!jwtUtil.validateToken(refreshToken)) {
            throw new UnauthorizedException("Invalid or expired refresh token");
        }

        // 2. Extract username
        String username = jwtUtil.getUsernameFromToken(refreshToken);

        // 3. Load user
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));

        // 4. Verify active
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new BusinessException(4008, "User account is not active");
        }

        // 5. Create CustomUserDetails
        CustomUserDetails userDetails = new CustomUserDetails(
                user.getId(),
                user.getStoreId(),
                user.getUsername(),
                user.getPassword(),
                user.getRole().toString(),
                true
        );

        // 6. Generate new access token
        String newAccessToken = jwtUtil.generateAccessToken(userDetails);

        log.info("Token refreshed for user: {}", username);

        return LoginResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole().toString())
                .token(newAccessToken)
                .expiresIn(86400000L)
                .issuedAt(LocalDateTime.now())
                .build();
    }

    // ========== User CRUD Methods ==========

    @Override
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    @Override
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public List<UserDTO> getUsersByStore(Long storeId) {
        return userRepository.findByStoreId(storeId, PageRequest.of(0, Integer.MAX_VALUE))
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    @Override
    public UserDTO updateUser(Long userId, UserDTO updateDTO) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        // Update fields
        if (updateDTO.getFullName() != null) {
            user.setFullName(updateDTO.getFullName());
        }
        if (updateDTO.getEmail() != null) {
            user.setEmail(updateDTO.getEmail());
        }
        if (updateDTO.getPhone() != null) {
            user.setPhone(updateDTO.getPhone());
        }

        user.setUpdatedAt(LocalDateTime.now());
        User updated = userRepository.save(user);

        log.info("User updated: {}", userId);

        return mapToDTO(updated);
    }

    @Transactional
    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        // Verify old password
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new UnauthorizedException("Current password is incorrect");
        }

        // Update password
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        log.info("Password changed for user: {}", userId);
    }

    @Override
    public List<UserDTO> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    @Override
    public UserDTO createUser(RegisterRequest request) {
        // Use register logic but set role from request
        return register(request);
    }

    @Transactional
    @Override
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        userRepository.delete(user);

        log.info("User deleted: {}", userId);
    }

    // ========== Spring Security Integration ==========

    /**
     * Load user by username (for Spring Security UserDetailsService)
     * Used during password authentication flow
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return new CustomUserDetails(
                user.getId(),
                user.getStoreId(),
                user.getUsername(),
                user.getPassword(),
                user.getRole().toString(),
                user.getStatus() == User.UserStatus.ACTIVE
        );
    }

    // ========== Helper Methods ==========

    /**
     * Map User entity to UserDTO
     */
    private UserDTO mapToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .storeId(user.getStoreId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole().toString())
                .status(user.getStatus().toString())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
