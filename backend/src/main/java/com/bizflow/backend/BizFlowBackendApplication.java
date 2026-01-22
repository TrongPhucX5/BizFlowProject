package com.bizflow.backend;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class BizFlowBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(BizFlowBackendApplication.class, args);
	}

	@Bean
	CommandLineRunner initData(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		return args -> {
			if (userRepository.findByUsername("admin").isEmpty()) {
				User admin = new User();
				admin.setUsername("admin");
				admin.setPassword(passwordEncoder.encode("123456"));
				admin.setRole(User.UserRole.ADMIN);
				admin.setFullName("Admin Hệ Thống");
				admin.setStatus(User.UserStatus.ACTIVE);

				// --- SỬA LỖI TẠI ĐÂY: Gán storeId mặc định cho admin ---
				admin.setStoreId(1L); // Giả sử cửa hàng mặc định có ID là 1

				userRepository.save(admin);
				System.out.println(">>> 🟢 ĐÃ TẠO USER MẪU: admin / 123456 với storeId=1");
			}
		};
	}
}
