package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Store;
import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.StoreRepository;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CreateUserUseCase {

    private final UserRepository userRepository;
    private final StoreRepository storeRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public UserDTO execute(RegisterRequest request) {
        // 1. Kiểm tra trùng lặp username
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Tên đăng nhập đã tồn tại");
        }

        // 2. Map dữ liệu từ Request sang Entity
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());

        // 3. Gán các giá trị mặc định
        user.setStatus(User.UserStatus.ACTIVE);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        // 4. Gán Store ID và Role
        if (request.getStoreId() == null) {
            // Nếu không có storeId, tạo Store mới và gán user làm OWNER
            Store newStore = Store.builder()
                    .name("Cửa hàng của " + request.getFullName())
                    .status(Store.StoreStatus.ACTIVE)
                    .createdAt(LocalDateTime.now())
                    .build();
            Store savedStore = storeRepository.save(newStore);
            
            user.setStoreId(savedStore.getId());
            user.setRole(User.UserRole.OWNER);
        } else {
            // Nếu có storeId, gán user làm EMPLOYEE
            // Kiểm tra store có tồn tại không
            if (!storeRepository.existsById(request.getStoreId())) {
                throw new RuntimeException("Cửa hàng không tồn tại");
            }
            user.setStoreId(request.getStoreId());
            user.setRole(User.UserRole.EMPLOYEE);
        }

        // 5. Lưu xuống Database
        User savedUser = userRepository.save(user);

        return mapToDTO(savedUser);
    }

    /**
     * Chuyển đổi từ Entity sang DTO để trả về Frontend
     * Đã cập nhật bổ sung trường phone và status
     */
    private UserDTO mapToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())        // <--- ĐÃ CẬP NHẬT: Thêm dòng này
                .role(user.getRole().name())
                .storeId(user.getStoreId())
                .status(user.getStatus() != null ? user.getStatus().name() : null) // Bổ sung status
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}