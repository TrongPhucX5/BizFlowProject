package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.User;
import org.springframework.security.core.userdetails.UserDetailsService; // Quan trọng

import java.util.List;
import java.util.Optional;

// MẤU CHỐT SỬA LỖI: Phải kế thừa UserDetailsService
public interface UserService extends UserDetailsService {
    User createUser(User user);
    List<User> getAllUsers();

    // Thêm hàm này để tìm user lúc đăng nhập
    Optional<User> findByUsername(String username);
}