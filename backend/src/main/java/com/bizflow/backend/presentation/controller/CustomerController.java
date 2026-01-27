package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.CustomerService;
import com.bizflow.backend.presentation.dto.request.CreateCustomerRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import com.bizflow.backend.core.common.UserContext;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/v1/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    /**
     * Lấy danh sách khách hàng ACTIVE.
     * Logic trong Service đã được sửa để lấy toàn bộ 19 khách hàng ACTIVE.
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Page<CustomerDTO>>> getAllCustomers(
            @RequestParam(required = false) String search,
            Pageable pageable) {

        // Lấy storeId từ context (nhưng Service của chúng ta hiện tại đang ưu tiên đếm ACTIVE)
        Long storeId = UserContext.getCurrentStoreId();

        // Trả về Page để Frontend đọc được totalElements = 19
        Page<CustomerDTO> customers = customerService.getCustomersByStore(storeId, search, pageable);

        return ResponseEntity.ok(ApiResponse.success(customers, "Lấy danh sách thành công"));
    }

    /**
     * Lấy chi tiết một khách hàng và bản đồ hóa dữ liệu đầy đủ.
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<CustomerDTO>> getCustomerById(@PathVariable Long id) {
        return customerService.getCustomerById(id)
                .map(customer -> {
                    CustomerDTO dto = CustomerDTO.builder()
                            .id(customer.getId())
                            .fullName(customer.getName()) // Đồng bộ c.name -> fullName
                            .phone(customer.getPhone())
                            .email(customer.getEmail())
                            .address(customer.getAddress())
                            .type(customer.getType() != null ? customer.getType().toString() : "RETAIL")
                            .taxCode(customer.getTaxCode())
                            .contactPerson(customer.getContactPerson())
                            .status(customer.getStatus() != null ? customer.getStatus().toString() : "ACTIVE")
                            .notes(customer.getNotes())
                            .totalDebt(customer.getTotalDebt() != null ? customer.getTotalDebt() : BigDecimal.ZERO)
                            .totalPurchaseAmount(customer.getTotalPurchaseAmount() != null ?
                                    customer.getTotalPurchaseAmount() : BigDecimal.ZERO)
                            .totalOrders(customer.getTotalOrders() != null ?
                                    customer.getTotalOrders() : 0)
                            .storeId(customer.getStoreId())
                            .createdAt(customer.getCreatedAt())
                            .updatedAt(customer.getUpdatedAt())
                            .build();
                    return ResponseEntity.ok(ApiResponse.success(dto, "Lấy thông tin thành công"));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<CustomerDTO>> createCustomer(@Valid @RequestBody CreateCustomerRequest request) {
        CustomerDTO customer = customerService.createCustomer(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(customer, "Tạo khách hàng thành công"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<CustomerDTO>> updateCustomer(
            @PathVariable Long id,
            @Valid @RequestBody CreateCustomerRequest request) {
        CustomerDTO customer = customerService.updateCustomer(id, request);
        return ResponseEntity.ok(ApiResponse.success(customer, "Cập nhật thành công"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteCustomer(@PathVariable Long id) {
        customerService.deleteCustomer(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Xóa thành công"));
    }
}