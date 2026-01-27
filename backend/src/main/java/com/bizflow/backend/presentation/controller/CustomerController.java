package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.CustomerService;
import com.bizflow.backend.presentation.dto.request.CreateCustomerRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/v1/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping
    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Page<CustomerDTO>>> getAllCustomers(
            @RequestParam(required = false) String search,
            Pageable pageable) {

        // Gọi service lấy danh sách (đã được fix trong UserContext/Service)
        // Lưu ý: UserContext.getCurrentStoreId() có thể trả về null, Service đã handle
        // việc này
        Long storeId = com.bizflow.backend.core.common.UserContext.getCurrentStoreId();
        Page<CustomerDTO> customers = customerService.getCustomersByStore(storeId, search, pageable);
        return ResponseEntity.ok(ApiResponse.success(customers, "Lấy danh sách thành công"));
    }

    @GetMapping("/{id}")
    @org.springframework.security.access.prepost.PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<CustomerDTO>> getCustomerById(@PathVariable Long id) {
        return customerService.getCustomerById(id)
                .map(customer -> {
                    // SỬA LỖI TẠI ĐÂY: Dùng fullName thay vì name
                    CustomerDTO dto = CustomerDTO.builder()
                            .id(customer.getId())
                            .fullName(customer.getName()) // Entity: getName(), DTO: fullName()
                            .phone(customer.getPhone())
                            .email(customer.getEmail())
                            .address(customer.getAddress())
                            .type(customer.getType() != null ? customer.getType().toString() : "RETAIL")
                            .taxCode(customer.getTaxCode())
                            .contactPerson(customer.getContactPerson())
                            .status(customer.getStatus() != null ? customer.getStatus().toString() : "ACTIVE")
                            .notes(customer.getNotes())

                            // Thêm totalDebt để không bị null
                            .totalDebt(customer.getTotalDebt() != null ? customer.getTotalDebt() : BigDecimal.ZERO)
                            .totalPurchaseAmount(BigDecimal.ZERO)
                            .totalOrders(0)

                            .createdAt(customer.getCreatedAt())
                            .updatedAt(customer.getUpdatedAt())
                            .build();
                    return ResponseEntity.ok(ApiResponse.success(dto, "Lấy thông tin thành công"));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CustomerDTO>> createCustomer(@Valid @RequestBody CreateCustomerRequest request) {
        CustomerDTO customer = customerService.createCustomer(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(customer, "Tạo khách hàng thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CustomerDTO>> updateCustomer(
            @PathVariable Long id,
            @Valid @RequestBody CreateCustomerRequest request) {
        CustomerDTO customer = customerService.updateCustomer(id, request);
        return ResponseEntity.ok(ApiResponse.success(customer, "Cập nhật thành công"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCustomer(@PathVariable Long id) {
        customerService.deleteCustomer(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Xóa thành công"));
    }
}