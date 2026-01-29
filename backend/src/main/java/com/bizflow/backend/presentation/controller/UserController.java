package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    /**
     * API: Cập nhật thông tin cá nhân (Profile)
     * Áp dụng cho: Mọi người dùng đã đăng nhập (isAuthenticated)
     */
    @PutMapping("/profile")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<User> updateProfile(@RequestBody User request) {
        // 1. Lấy danh tính người dùng từ Security Context (Token)
        String currentUsername = SecurityContextHolder.getContext().getAuthentication().getName();

        // 2. Tìm người dùng trong database
        User user = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new RuntimeException("Lỗi: Người dùng hiện tại không tồn tại trong hệ thống."));

        // 3. Chỉ cập nhật những trường được phép sửa ở trang Settings
        user.setFullName(request.getFullName());
        user.setPhone(request.getPhone());
        user.setTaxCode(request.getTaxCode()); // Cập nhật Mã số thuế
        user.setAddress(request.getAddress()); // Cập nhật Địa chỉ

        // Lưu ý: Tuyệt đối không set lại role hoặc password ở đây từ request của người dùng

        // 4. Lưu và trả về kết quả
        User updatedUser = userRepository.save(user);

        return ApiResponse.<User>builder()
                .code(1000)
                .message("Cập nhật thông tin cá nhân thành công!")
                .result(updatedUser)
                .build();
    }

    /**
     * API: Tạo User mới (Quản trị viên)
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<User> createUser(@RequestBody User user) {
        User savedUser = userRepository.save(user);
        return ApiResponse.<User>builder()
                .code(1000)
                .message("Tạo tài khoản mới thành công")
                .result(savedUser)
                .build();
    }

    /**
     * API: Lấy toàn bộ danh sách User (Quản trị viên)
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<User>> getAllUsers() {
        List<User> users = userRepository.findAll();
        return ApiResponse.<List<User>>builder()
                .code(1000)
                .result(users)
                .build();
    }
}