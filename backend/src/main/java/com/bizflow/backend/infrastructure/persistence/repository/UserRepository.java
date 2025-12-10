package com.bizflow.backend.infrastructure.persistence;

import com.bizflow.backend.core.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Hàm này giúp tìm User trong database bằng tên đăng nhập
    Optional<User> findByUsername(String username);
}