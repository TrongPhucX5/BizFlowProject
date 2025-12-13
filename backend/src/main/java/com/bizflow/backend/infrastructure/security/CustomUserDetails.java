package com.bizflow.backend.infrastructure.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

/**
 * CustomUserDetails: Implementation của Spring Security UserDetails
 * 
 * Này sẽ được SET vào Authentication object từ JWT token
 * Giúp UserContext có thể extract storeId, role, v.v.
 */
public class CustomUserDetails implements UserDetails {
    private final Long id;
    private final Long storeId;
    private final String username;
    private final String password;
    private final String role;
    private final Boolean enabled;

    public CustomUserDetails(Long id, Long storeId, String username, String password, String role, Boolean enabled) {
        this.id = id;
        this.storeId = storeId;
        this.username = username;
        this.password = password;
        this.role = role;
        this.enabled = enabled;
    }

    // ========== Getters for UserContext ==========
    public Long getId() {
        return id;
    }

    public Long getStoreId() {
        return storeId;
    }

    public String getRole() {
        return role;
    }

    // ========== Spring Security UserDetails Implementation ==========
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Return role as authority (e.g., "ROLE_ADMIN", "ROLE_OWNER")
        return Collections.singletonList(
                (GrantedAuthority) () -> "ROLE_" + role.toUpperCase()
        );
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return enabled;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
