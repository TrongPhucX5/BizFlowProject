package com.bizflow.backend.user.service;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.core.usecase.UserService;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.bizflow.backend.infrastructure.security.JwtUtil;
import com.bizflow.backend.presentation.dto.request.LoginRequest;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.request.PasswordUpdateRequest; // Cập nhật import
import com.bizflow.backend.presentation.dto.response.LoginResponse;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import com.bizflow.backend.presentation.dto.response.UserActivityDTO; // Cập nhật import
import com.bizflow.backend.presentation.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // --- ĐỔI MẬT KHẨU (MỚI) ---
    @Override
    @Transactional
    public void changePassword(Long userId, PasswordUpdateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        // 1. Kiểm tra mật khẩu cũ
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("Mật khẩu hiện tại không chính xác");
        }

        // 2. Mã hóa và lưu mật khẩu mới
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(LocalDateTime.now());

        userRepository.save(user);
        log.info("User ID {} changed password successfully", userId);
    }

    // --- LẤY LỊCH SỬ HOẠT ĐỘNG (MỚI - MOCK DATA) ---
    @Override
    public List<UserActivityDTO> getUserActivities(Long userId) {
        // Sau này bạn sẽ truy vấn từ bảng user_activities trong DB.
        // Hiện tại trả về data ảo để bạn hiển thị lên giao diện React.
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        return List.of(
                UserActivityDTO.builder()
                        .time(now)
                        .device("Chrome - Windows 11")
                        .ip("192.168.1.100")
                        .location("TP.HCM, Vietnam")
                        .status("Thành công")
                        .build(),
                UserActivityDTO.builder()
                        .time("26/10/2024 14:20")
                        .device("Safari - iPhone 14")
                        .ip("192.168.1.101")
                        .location("Hà Nội, Vietnam")
                        .status("Thành công")
                        .build()
        );
    }

    // --- ĐĂNG NHẬP ---
    @Override
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UnauthorizedException("Tên đăng nhập không tồn tại"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Sai mật khẩu");
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
                .user(mapToDTO(user))
                .build();
    }

    // --- ĐĂNG KÝ & CRUD ---
    @Override
    @Transactional
    public UserDTO register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Tên đăng nhập đã tồn tại");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setStoreId(request.getStoreId() != null ? request.getStoreId() : 1L);

        user.setRole(User.UserRole.EMPLOYEE);
        user.setStatus(User.UserStatus.ACTIVE);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        User saved = userRepository.save(user);
        return mapToDTO(saved);
    }

    @Override
    @Transactional
    public UserDTO updateUser(Long userId, UserDTO updateDTO) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        if (updateDTO.getFullName() != null) user.setFullName(updateDTO.getFullName());
        if (updateDTO.getPhone() != null) user.setPhone(updateDTO.getPhone());
        if (updateDTO.getEmail() != null) user.setEmail(updateDTO.getEmail());

        user.setUpdatedAt(LocalDateTime.now());
        User saved = userRepository.save(user);
        return mapToDTO(saved);
    }

    @Override public UserDTO createUser(RegisterRequest request) { return register(request); }
    @Override public Optional<User> getUserById(Long id) { return userRepository.findById(id); }
    @Override public Optional<User> getUserByUsername(String username) { return userRepository.findByUsername(username); }

    @Override
    public List<UserDTO> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteUser(Long userId) {
        userRepository.deleteById(userId);
    }

    @Override public LoginResponse refreshToken(String refreshToken) { return null; }
    @Override public List<UserDTO> getUsersByStore(Long storeId) { return List.of(); }

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

    private UserDTO mapToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole().toString())
                .storeId(user.getStoreId())
                .status(user.getStatus() != null ? user.getStatus().name() : null)
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}