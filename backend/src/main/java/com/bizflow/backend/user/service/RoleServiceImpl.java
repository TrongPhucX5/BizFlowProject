package com.bizflow.backend.user.service;

import com.bizflow.backend.core.domain.Permission;
import com.bizflow.backend.core.domain.Role;
import com.bizflow.backend.core.usecase.RoleService;
import com.bizflow.backend.infrastructure.persistence.repository.PermissionRepository;
import com.bizflow.backend.infrastructure.persistence.repository.RoleRepository;
import com.bizflow.backend.presentation.dto.response.PermissionDTO;
import com.bizflow.backend.presentation.dto.response.RoleDTO;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;

    @Override
    @Transactional(readOnly = true)
    public List<RoleDTO> getAllRoles() {
        return roleRepository.findAll().stream()
                .map(this::mapToRoleDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public RoleDTO createRole(RoleDTO roleDto) {
        Role role = Role.builder()
                .name(roleDto.getName())
                .description(roleDto.getDescription())
                .build();

        assignPermissions(role, roleDto.getPermissions());

        return mapToRoleDTO(roleRepository.save(role));
    }

    @Override
    @Transactional
    public RoleDTO updateRole(Long id, RoleDTO roleDto) {
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + id));

        role.setDescription(roleDto.getDescription());
        // Updating name might break things if name is used as code. Assuming name is editable or handled.
        // For security, system roles like ADMIN/OWNER usually shouldn't change name.
        // But for custom roles, it might be fine.

        assignPermissions(role, roleDto.getPermissions());

        return mapToRoleDTO(roleRepository.save(role));
    }

    @Override
    @Transactional
    public void deleteRole(Long id) {
        if (!roleRepository.existsById(id)) {
            throw new ResourceNotFoundException("Role not found with id: " + id);
        }
        roleRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PermissionDTO> getAllPermissions() {
        return permissionRepository.findAll().stream()
                .map(this::mapToPermissionDTO)
                .collect(Collectors.toList());
    }

    private void assignPermissions(Role role, List<String> permissionNames) {
        if (permissionNames != null) {
            Set<Permission> permissions = new HashSet<>();
            for (String permName : permissionNames) {
                permissionRepository.findByName(permName)
                    .ifPresent(permissions::add);
            }
            role.setPermissions(permissions);
        }
    }

    private RoleDTO mapToRoleDTO(Role role) {
        List<String> permissionNames = role.getPermissions().stream()
                .map(Permission::getName)
                .collect(Collectors.toList());

        return RoleDTO.builder()
                .id(role.getId())
                .name(role.getName())
                .description(role.getDescription())
                .permissions(permissionNames)
                .createdAt(role.getCreatedAt())
                .build();
    }

    private PermissionDTO mapToPermissionDTO(Permission permission) {
        return PermissionDTO.builder()
                .id(permission.getId())
                .name(permission.getName())
                .description(permission.getDescription())
                .module(permission.getModule())
                .build();
    }
}
