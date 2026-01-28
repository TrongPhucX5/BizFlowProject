package com.bizflow.backend.core.usecase;

import com.bizflow.backend.presentation.dto.response.PermissionDTO;
import com.bizflow.backend.presentation.dto.response.RoleDTO;
import java.util.List;

public interface RoleService {
    List<RoleDTO> getAllRoles();
    RoleDTO createRole(RoleDTO roleDto);
    RoleDTO updateRole(Long id, RoleDTO roleDto); // This will handle permission assignment
    void deleteRole(Long id);
    List<PermissionDTO> getAllPermissions();
}
