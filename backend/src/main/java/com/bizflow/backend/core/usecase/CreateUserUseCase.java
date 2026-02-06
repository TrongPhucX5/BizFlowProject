package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Store;
import com.bizflow.backend.core.domain.Subscription;
import com.bizflow.backend.core.domain.SubscriptionPlan;
import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.StoreRepository;
import com.bizflow.backend.infrastructure.persistence.repository.SubscriptionPlanRepository;
import com.bizflow.backend.infrastructure.persistence.repository.SubscriptionRepository;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import com.bizflow.backend.presentation.dto.request.RegisterRequest;
import com.bizflow.backend.presentation.dto.response.UserDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class CreateUserUseCase {

    private final UserRepository userRepository;
    private final StoreRepository storeRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
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

            // Tự động gán gói Free cho Store mới
            createDefaultFreeSubscription(savedStore.getId());
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
     */
    private UserDTO mapToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole().name())
                .storeId(user.getStoreId())
                .status(user.getStatus() != null ? user.getStatus().name() : null)
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    /**
     * Tạo gói thuê bao Miễn phí mặc định cho Store mới
     */
    private void createDefaultFreeSubscription(Long storeId) {
        // 1. Tìm gói Free (Tên chính xác như trong seed data)
        SubscriptionPlan freePlan = subscriptionPlanRepository.findAll()
                .stream()
                .filter(p -> p.getName().equalsIgnoreCase("Free"))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Hệ thống chưa cấu hình gói dịch vụ 'Free'"));

        // 2. Tạo Subscription (Thời hạn mặc định: số tháng trong gói, hoặc 1 tháng)
        int durationMonths = freePlan.getDurationMonths() != null ? freePlan.getDurationMonths() : 1;
        
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = startDate.plusMonths(durationMonths);

        Subscription subscription = Subscription.builder()
                .id(generateSubscriptionId())
                .storeId(storeId)
                .planId(freePlan.getId())
                .startDate(startDate)
                .endDate(endDate)
                .status(Subscription.SubscriptionStatus.ACTIVE)
                .createdBy("system")
                .build();

        subscriptionRepository.save(subscription);
    }

    /**
     * Sinh ID thuê bao theo format: SUB-YYYYMMDD-XXXX
     */
    private String generateSubscriptionId() {
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomPart = String.format("%04d", new Random().nextInt(10000));
        return "SUB-" + datePart + "-" + randomPart;
    }
}
