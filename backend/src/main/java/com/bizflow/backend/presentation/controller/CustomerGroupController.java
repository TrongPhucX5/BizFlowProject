package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.CustomerGroup;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerGroupRepository;
import com.bizflow.backend.presentation.dto.response.ApiResponse;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/v1/customer-groups")
@RequiredArgsConstructor
public class CustomerGroupController {

    private final CustomerGroupRepository customerGroupRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<List<CustomerGroup>>> getCustomerGroups() {
        Long storeId = UserContext.getCurrentStoreId();
        List<CustomerGroup> groups = customerGroupRepository.findByStoreId(storeId);
        return ResponseEntity.ok(ApiResponse.success(groups, "Lấy danh sách nhóm khách hàng thành công"));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<CustomerGroup>> createCustomerGroup(@RequestBody Map<String, Object> request) {
        Long storeId = UserContext.getCurrentStoreId();
        String name = (String) request.get("name");

        CustomerGroup group = CustomerGroup.builder()
                .name(name)
                .storeId(storeId)
                .build();

        CustomerGroup saved = customerGroupRepository.save(group);

        // Note: Logic add customerIds to group is omitted for simplicity as per
        // requirement to fix errors first

        return ResponseEntity.ok(ApiResponse.success(saved, "Tạo nhóm khách hàng thành công"));
    }
}
