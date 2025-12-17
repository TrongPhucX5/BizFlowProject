package com.bizflow.backend.service.impl;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.core.usecase.UserService;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.bizflow.backend.infrastructure.security.JwtUtil;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import com.bizflow.backend.presentation.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // --- Implementing UserService methods ---

    @Override
    public LoginResponse login(LoginRequest request) {
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
                .build(); // Lưu ý: Nếu LoginResponse có field userId thì nên thêm vào đây
    }

    @Override
    public UserDTO register(RegisterRequest request) {
        User user = new User();

        // --- ĐÂY LÀ PHẦN BẠN BỊ THIẾU TRƯỚC ĐÓ ---
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        // !!! QUAN TRỌNG: Phải set fullName nếu không sẽ lỗi SQL NOT NULL !!!
        user.setFullName(request.getFullName());

        // Set thêm các trường khác cho đủ data
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setStoreId(request.getStoreId());

        // Mặc định
        user.setRole(User.UserRole.EMPLOYEE);
        user.setStatus(User.UserStatus.ACTIVE);

        User saved = userRepository.save(user);
        return mapToDTO(saved);
    }

    @Override
    public LoginResponse refreshToken(String refreshToken) {
        return null;
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
        return List.of();
    }

    @Override
    public List<UserDTO> getAllUsers() {
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
                .roles(user.getRole().toString())
                .build();
    }

    // Helper: Map Entity -> DTO
    private UserDTO mapToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName()) // Mapping thêm fullName để trả về cho đẹp
                .email(user.getEmail())       // Mapping thêm email
                .role(user.getRole().toString())
                .storeId(user.getStoreId())
                .build();
    }
}