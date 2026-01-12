package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/customers")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CustomerController {

    private final CustomerRepository customerRepository;

    /**
     * Lấy danh sách khách hàng (Có phân trang)
     * Đã sửa lỗi: Trả về Page thay vì List để Frontend xử lý .content chính xác
     */
    @GetMapping
    public ApiResponse<Page<Customer>> getCustomers(
            @RequestParam(defaultValue = "1") Long storeId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size
    ) {
        try {
            // Sắp xếp theo ngày tạo mới nhất để khách hàng vừa thêm hiện lên đầu
            Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
            Page<Customer> pageResult = customerRepository.findByStoreId(storeId, pageable);

            return ApiResponse.success(pageResult, "Lấy danh sách thành công");
        } catch (Exception e) {
            return ApiResponse.error(500, "Lỗi khi lấy danh sách: " + e.getMessage());
        }
    }

    /**
     * Thêm mới khách hàng
     * Đã cập nhật: Thêm @Valid để kích hoạt kiểm tra tên > 5 ký tự và chỉ chứa chữ
     */
    @PostMapping
    public ApiResponse<Customer> createCustomer(@Valid @RequestBody Customer customer) {
        try {
            // Đảm bảo storeId luôn có giá trị mặc định nếu Frontend không gửi
            if (customer.getStoreId() == null) {
                customer.setStoreId(1L);
            }

            Customer savedCustomer = customerRepository.save(customer);
            return ApiResponse.success(savedCustomer, "Thêm khách hàng thành công");
        } catch (Exception e) {
            return ApiResponse.error(500, "Lỗi khi thêm: " + e.getMessage());
        }
    }

    /**
     * Cập nhật thông tin khách hàng
     */
    @PutMapping("/{id}")
    public ApiResponse<CustomerDTO> updateCustomer(
            @PathVariable Long id,
            @Valid @RequestBody Customer details
    ) {
        return customerRepository.findById(id).map(customer -> {
            customer.setName(details.getName());
            customer.setPhone(details.getPhone());
            customer.setEmail(details.getEmail());
            customer.setAddress(details.getAddress());
            customer.setType(details.getType());
            customer.setStatus(details.getStatus());
            customer.setTaxCode(details.getTaxCode());
            customer.setContactPerson(details.getContactPerson());
            customer.setNotes(details.getNotes());

            Customer updated = customerRepository.save(customer);
            return ApiResponse.success(convertToDTO(updated), "Cập nhật thành công");
        }).orElseGet(() -> ApiResponse.error(404, "Không tìm thấy khách hàng để cập nhật"));
    }

    /**
     * Xóa khách hàng
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteCustomer(@PathVariable Long id) {
        if (!customerRepository.existsById(id)) {
            return ApiResponse.error(404, "Khách hàng không tồn tại");
        }
        customerRepository.deleteById(id);
        return ApiResponse.success(null, "Xóa thành công");
    }

    /**
     * Helper method: Chuyển đổi từ Entity sang DTO để trả về Frontend sạch hơn
     */
    private CustomerDTO convertToDTO(Customer customer) {
        return CustomerDTO.builder()
                .id(customer.getId())
                .name(customer.getName())
                .phone(customer.getPhone())
                .email(customer.getEmail())
                .address(customer.getAddress())
                .taxCode(customer.getTaxCode())
                .contactPerson(customer.getContactPerson())
                .type(customer.getType() != null ? customer.getType().name() : null)
                .status(customer.getStatus() != null ? customer.getStatus().name() : null)
                .notes(customer.getNotes())
                .createdAt(customer.getCreatedAt())
                .updatedAt(customer.getUpdatedAt())
                .build();
    }
}