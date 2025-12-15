package com.bizflow.backend.service.impl;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.core.usecase.UserService;
// Sửa Import UserRepository
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
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil; // Cần thiết để login

    // --- Implementing UserService methods ---

    @Override
    public LoginResponse login(LoginRequest request) {
        // Logic đăng nhập tối giản để fix lỗi build trước
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Wrong password");
        }

        CustomUserDetails userDetails = new CustomUserDetails(
                user.getId(), user.getStoreId(), user.getUsername(), user.getPassword(),
                user.getRole().toString(), true
        );

        String token = jwtUtil.generateAccessToken(userDetails);

        return LoginResponse.builder()
                .token(token)
                .username(user.getUsername())
                .role(user.getRole().toString())
                .build();
    }

    @Override
    public UserDTO register(RegisterRequest request) {
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(User.UserRole.EMPLOYEE);
        user.setStatus(User.UserStatus.ACTIVE);

        User saved = userRepository.save(user);
        return mapToDTO(saved);
    }

    @Override
    public LoginResponse refreshToken(String refreshToken) {
        return null; // Tạm thời return null để build được
    }

    @Override
    public UserDTO createUser(RegisterRequest request) {
        return register(request);
    }

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
        return List.of(); // Trả về list rỗng tạm thời
    }

    @Override
    public List<UserDTO> getAllUsers() {
        // Sửa lỗi return type: Chuyển User Entity sang UserDTO
        return userRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public UserDTO updateUser(Long userId, UserDTO updateDTO) {
        return null;
    }

    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
    }

    @Override
    public void deleteUser(Long userId) {
        // Đây là hàm bạn bị thiếu Override
        if (userRepository.existsById(userId)) {
            userRepository.deleteById(userId);
        }
    }

    // --- Spring Security ---
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                // SỬA LỖI: .toString() vì role là Enum
                .roles(user.getRole().toString())
                .build();
    }

    // Helper
    private UserDTO mapToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .role(user.getRole().toString())
                .build();
    }
}