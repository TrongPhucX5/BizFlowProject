package com.bizflow.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable) // Tắt CSRF để Postman gọi được
                .authorizeHttpRequests(auth -> auth
                        // Cho phép truy cập tự do vào API tạo User và xem User
                        .requestMatchers("/api/v1/users/**").permitAll()
                        // Những cái khác bắt buộc phải đăng nhập (tính sau)
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}