package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Spring Data JPA tự động hiểu, không cần viết SQL
    boolean existsByUsername(String username);
}