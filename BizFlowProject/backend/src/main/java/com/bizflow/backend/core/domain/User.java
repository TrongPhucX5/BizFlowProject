package com.bizflow.backend.core.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data // Tự sinh Getter/Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "users") // Tên bảng trong MySQL
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    private String password; // Lưu hash, không lưu plain text

    private String fullName;

    private String role; // OWNER, EMPLOYEE, ADMIN
}