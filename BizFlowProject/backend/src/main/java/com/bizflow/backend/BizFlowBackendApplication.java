package com.bizflow.backend;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.UserRepository;
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

	// --- DÁN ĐOẠN NÀY VÀO ---
	@Bean
	CommandLineRunner initData(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		return args -> {
			// Kiểm tra nếu chưa có admin thì tạo mới
			if (userRepository.findByUsername("admin").isEmpty()) {
				User admin = new User();
				admin.setUsername("admin");
				// Quan trọng: Mã hóa mật khẩu "123456" thành chuỗi BCrypt
				admin.setPassword(passwordEncoder.encode("123456"));
				admin.setRole("ADMIN"); // Hoặc "OWNER" tùy code ông quy định
				admin.setFullName("Admin Hệ Thống");

				userRepository.save(admin);
				System.out.println(">>> 🟢 ĐÃ TẠO USER MẪU: admin / 123456");
			}
		};
	}
}