package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // API: Tạo User mới
    @PostMapping
    public ApiResponse<User> createUser(@RequestBody User user) {
        User savedUser = userRepository.save(user);

        return ApiResponse.<User>builder()
                .code(1000)
                .message("Tạo người dùng thành công")
                .result(savedUser)
                .build();
    }

    // API: Lấy danh sách
    @GetMapping
    public ApiResponse<List<User>> getAllUsers() {
        return ApiResponse.<List<User>>builder()
                .result(userRepository.findAll())
                .build();
    }
}