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
    private final com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository customerRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<List<CustomerGroup>>> getCustomerGroups() {
        Long storeId = UserContext.getCurrentStoreId();
        List<CustomerGroup> groups = customerGroupRepository.findByStoreId(storeId);
        // Populate customer count
        groups.forEach(g -> g.setCustomerCount(customerRepository.countByGroupId(g.getId())));
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

        // Xử lý thêm thành viên vào nhóm
        if (request.containsKey("customerIds")) {
            List<Integer> customerIds = (List<Integer>) request.get("customerIds");
            if (customerIds != null && !customerIds.isEmpty()) {
                for (Number id : customerIds) {
                    customerRepository.findById(id.longValue()).ifPresent(customer -> {
                        customer.setGroupId(saved.getId());
                        customerRepository.save(customer);
                    });
                }
            }
        }

        // Return saved with count 0 (since just created) or actual count if we want to
        // be safe
        // Simply return 0 or calculate if needed. The request 'customerIds' list is
        // local to if block
        int count = 0;
        if (request.containsKey("customerIds")) {
            List<?> ids = (List<?>) request.get("customerIds");
            if (ids != null)
                count = ids.size();
        }
        saved.setCustomerCount(count);

        return ResponseEntity.ok(ApiResponse.success(saved, "Tạo nhóm khách hàng thành công"));
    }
}
