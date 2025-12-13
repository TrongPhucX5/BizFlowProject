package com.bizflow.backend.infrastructure.security;

import com.bizflow.backend.core.domain.User;
import com.bizflow.backend.infrastructure.persistence.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.io.IOException;

/**
 * JwtRequestFilter: Validate JWT token on every request
 * 
 * Flow:
 * 1. Extract token from Authorization header: "Bearer <token>"
 * 2. Validate token signature & expiration
 * 3. Extract user info from claims (userId, storeId, role)
 * 4. Load user from database
 * 5. Create CustomUserDetails and set into SecurityContext
 * 
 * This filter runs ONCE per request (extends OncePerRequestFilter)
 * 
 * CRITICAL ARCHITECTURAL RULE:
 * - User info comes from JWT token ONLY (not from request parameter)
 * - Ensures multi-tenancy cannot be bypassed by client manipulation
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtRequestFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            // 1. Extract token from Authorization header
            String token = extractTokenFromRequest(request);

            // 2. Validate token
            if (token != null && jwtUtil.validateToken(token)) {
                // 3. Extract user info from token
                String username = jwtUtil.getUsernameFromToken(token);
                Long userId = jwtUtil.getUserIdFromToken(token);
                Long storeId = jwtUtil.getStoreIdFromToken(token);
                String role = jwtUtil.getRoleFromToken(token);

                // 4. Load user from database (verify user still exists & is active)
                User user = userRepository.findByUsername(username).orElse(null);
                
                if (user != null && isUserActive(user)) {
                    // 5. Create CustomUserDetails with info from BOTH token and database
                    CustomUserDetails userDetails = new CustomUserDetails(
                            userId,
                            storeId,
                            username,
                            user.getPassword(),
                            role,
                            user.getStatus() == User.UserStatus.ACTIVE
                    );

                    // 6. Create authentication token
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities()
                            );

                    // 7. Set into SecurityContext
                    // Now UserContext.getCurrentUserId() will work in service layer
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    log.debug("JWT authenticated user: {} (storeId: {})", username, storeId);
                } else {
                    log.warn("User from token not found or inactive: {}", username);
                    SecurityContextHolder.clearContext();
                }
            }
        } catch (Exception e) {
            log.error("Error processing JWT token: {}", e.getMessage());
            SecurityContextHolder.clearContext();
        }

        // Continue with filter chain regardless of token validation result
        // (public endpoints will handle missing auth, secured endpoints will reject)
        filterChain.doFilter(request, response);
    }

    /**
     * Extract JWT token from Authorization header
     * Expected format: "Bearer <token>"
     */
    private String extractTokenFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader(AUTHORIZATION_HEADER);
        
        if (authHeader != null && authHeader.startsWith(BEARER_PREFIX)) {
            return authHeader.substring(BEARER_PREFIX.length());
        }
        
        return null;
    }

    /**
     * Check if user account is active (not locked/deleted)
     */
    private boolean isUserActive(User user) {
        return user.getStatus() == User.UserStatus.ACTIVE;
    }
}
