package com.bizflow.backend.config;

import com.bizflow.backend.infrastructure.security.JwtRequestFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * SecurityConfig: Spring Security configuration with JWT authentication
 * 
 * ARCHITECTURE:
 * 1. CORS enabled for web/mobile clients
 * 2. JWT filter validates token on every request
 * 3. Stateless session (no cookies, token-based auth)
 * 4. Public endpoints: /auth/login, /auth/register
 * 5. Protected endpoints: require valid JWT token in Authorization header
 * 
 * TOKEN EXTRACTION FLOW:
 * Client sends: Authorization: Bearer <token>
 *   ↓
 * JwtRequestFilter extracts and validates token
 *   ↓
 * CustomUserDetails created from token claims
 *   ↓
 * SecurityContext populated → UserContext.getCurrentUserId() works
 * 
 * CRITICAL SECURITY RULE:
 * - storeId/userId NEVER from request parameter
 * - ALWAYS extracted from JWT token in JwtRequestFilter
 * - Prevents multi-tenancy data leak vulnerability
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true) // Enables @PreAuthorize, @PostAuthorize
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtRequestFilter jwtRequestFilter;

    /**
     * Configure HTTP security with JWT authentication
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                // 1. Enable CORS for web/mobile clients
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                
                // 2. Disable CSRF (not needed for stateless JWT auth)
                .csrf(AbstractHttpConfigurer::disable)
                
                // 3. Stateless session policy (no session cookies)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                
                // 4. Define authorization rules
                .authorizeHttpRequests(auth -> auth
                        // Public endpoints (no authentication required)
                        .requestMatchers(
                                "/api/v1/auth/login",
                                "/api/v1/auth/register",
                                "/api/v1/auth/refresh",
                                "/api/v1/health",
                                "/swagger-ui.html",
                                "/swagger-ui/**",
                                "/v3/api-docs/**"
                        ).permitAll()
                        
                        // All other endpoints require authentication
                        .anyRequest().authenticated()
                )
                
                // 5. Add JWT filter BEFORE UsernamePasswordAuthenticationFilter
                // This ensures token is processed before Spring's default authentication
                .addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * CORS Configuration: Allow web and mobile clients
     * 
     * ORIGINS:
     * - http://localhost:3000      : NextJS web admin (dev)
     * - http://localhost:8081      : Flutter web (dev)
     * - http://10.0.2.2:8080       : Android emulator (dev)
     * 
     * In production, replace with actual domain names
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Allowed origins (clients that can call this API)
        configuration.setAllowedOrigins(Arrays.asList(
                "http://localhost:3000",           // NextJS web admin
                "http://localhost:8081",           // Flutter web
                "http://10.0.2.2:8080",            // Android emulator
                "http://localhost:8100"            // Ionic dev
        ));
        
        // Allowed HTTP methods
        configuration.setAllowedMethods(Arrays.asList(
                HttpMethod.GET.toString(),
                HttpMethod.POST.toString(),
                HttpMethod.PUT.toString(),
                HttpMethod.DELETE.toString(),
                HttpMethod.PATCH.toString(),
                HttpMethod.OPTIONS.toString()
        ));
        
        // Allowed headers (including Authorization for JWT)
        configuration.setAllowedHeaders(Arrays.asList(
                "Content-Type",
                "Authorization",
                "X-Requested-With",
                "Accept",
                "Origin"
        ));
        
        // Allow credentials (cookies, authorization headers)
        configuration.setAllowCredentials(true);
        
        // Cache preflight requests for 1 hour
        configuration.setMaxAge(3600L);
        
        // Expose headers to client (e.g., for custom response headers)
        configuration.setExposedHeaders(Arrays.asList(
                "Authorization",
                "Content-Type"
        ));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}