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
            // Log error but do NOT clear context immediately if it's a Redis connection failure
            // This allows the request to proceed, potentially failing later if Redis is strictly required,
            // but preventing a complete blockage if Redis is only used for caching/session storage in a stateless JWT setup.
            // However, for JWT validation itself, if it fails, we should clear context.
            // The user reported RedisConnectionFailureException.
            // If JwtUtil uses Redis (e.g. for blacklisting), then this catch block is hit.
            // If JwtUtil is purely stateless (which it seems to be based on JwtUtil.java content),
            // then Redis might be used elsewhere or implicitly by Spring Session/Security if configured.

            // Based on the user log: "Resolved [org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis]"
            // This exception seems to be bubbling up to the ExceptionHandlerExceptionResolver, meaning it might not be caught here
            // OR it is caught here, logged, and then something else triggers it or it's rethrown?
            // Actually, the log says "Resolved ... ExceptionHandlerExceptionResolver", which usually means it was thrown from a Controller
            // or somewhere further down the chain, NOT swallowed here.

            // BUT, if the filter chain continues (filterChain.doFilter), and the exception happens LATER,
            // then the issue is likely in a service that uses Redis.

            // Wait, the user says "sao web chạy lên ko có dữ liệu luôn" (why web runs but no data).
            // And the log shows "JWT authenticated user: admin". So authentication PASSED.
            // Then "Resolved ... RedisConnectionFailureException".
            // This means the request went through the filter, got authenticated, reached the controller/service,
            // and THEN failed because of Redis.

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
