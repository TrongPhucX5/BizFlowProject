package com.bizflow.backend.core.common;

import com.bizflow.backend.infrastructure.security.CustomUserDetails;
import com.bizflow.backend.presentation.exception.UnauthorizedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * UserContext: Extract user information from JWT Token
 * 
 * ARCHITECTURAL RULE: 
 * - NEVER trust storeId from request body/path variable
 * - ALWAYS extract storeId from authenticated user's JWT token
 * - This prevents multi-tenancy data leak vulnerability
 * 
 * Usage in Service:
 *   Long storeId = UserContext.getCurrentStoreId();
 *   productRepository.findByIdAndStoreId(id, storeId);
 */
public class UserContext {

    /**
     * Get current authenticated user's Store ID from JWT token
     * @return storeId of authenticated user
     * @throws UnauthorizedException if user not authenticated or storeId missing
     */
    public static Long getCurrentStoreId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("User not authenticated");
        }

        if (auth.getPrincipal() instanceof CustomUserDetails userDetails) {
            Long storeId = userDetails.getStoreId();
            if (storeId == null) {
                // ADMIN users might have null storeId (system-wide access)
                throw new UnauthorizedException("User has no store assigned");
            }
            return storeId;
        }

        throw new UnauthorizedException("Invalid authentication principal");
    }

    /**
     * Get current authenticated user's ID from JWT token
     * @return userId of authenticated user
     * @throws UnauthorizedException if user not authenticated
     */
    public static Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("User not authenticated");
        }

        if (auth.getPrincipal() instanceof CustomUserDetails userDetails) {
            return userDetails.getId();
        }

        throw new UnauthorizedException("Invalid authentication principal");
    }

    /**
     * Get current authenticated user's role from JWT token
     * @return user's role (ADMIN, OWNER, EMPLOYEE)
     * @throws UnauthorizedException if user not authenticated
     */
    public static String getCurrentRole() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("User not authenticated");
        }

        if (auth.getPrincipal() instanceof CustomUserDetails userDetails) {
            return userDetails.getRole();
        }

        throw new UnauthorizedException("Invalid authentication principal");
    }

    /**
     * Get current authenticated username from JWT token
     * @return username of authenticated user
     * @throws UnauthorizedException if user not authenticated
     */
    public static String getCurrentUsername() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("User not authenticated");
        }

        if (auth.getPrincipal() instanceof CustomUserDetails userDetails) {
            return userDetails.getUsername();
        }

        throw new UnauthorizedException("Invalid authentication principal");
    }

    /**
     * Check if current user has specific role
     * @param role role to check (ADMIN, OWNER, EMPLOYEE)
     * @return true if user has this role
     */
    public static boolean hasRole(String role) {
        try {
            return role.equals(getCurrentRole());
        } catch (UnauthorizedException e) {
            return false;
        }
    }

    /**
     * Check if current user is ADMIN (system-wide access)
     * @return true if user is ADMIN
     */
    public static boolean isAdmin() {
        return hasRole("ADMIN");
    }

    /**
     * Check if current user is OWNER (store owner, full store access)
     * @return true if user is OWNER
     */
    public static boolean isOwner() {
        return hasRole("OWNER");
    }

    /**
     * Check if current user is EMPLOYEE (store employee, limited access)
     * @return true if user is EMPLOYEE
     */
    public static boolean isEmployee() {
        return hasRole("EMPLOYEE");
    }
}
