package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.core.usecase.CustomerService;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.infrastructure.persistence.repository.DebtRepository;
import com.bizflow.backend.presentation.dto.request.CreateCustomerRequest;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import com.bizflow.backend.presentation.exception.BusinessException;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import com.bizflow.backend.core.common.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;
    private final DebtRepository debtRepository;

    @Override
    public Page<CustomerDTO> getCustomersByStore(Long storeId, String search, Pageable pageable) {
        String searchKey = (search != null) ? search.trim() : "";
        return customerRepository.findAllActiveWithSearch(storeId, searchKey, pageable)
                .map(this::mapToDTO);
    }

    @Override
    public Page<CustomerDTO> getAllActiveCustomers(Long storeId, Pageable pageable) {
        return customerRepository.findAllActiveWithSearch(storeId, "", pageable)
                .map(this::mapToDTO);
    }

    @Override
    @Transactional
    @CacheEvict(value = "customers_page", allEntries = true)
    @com.bizflow.backend.core.annotation.AuditAction(action = "CREATE_CUSTOMER", entityType = "CUSTOMER")
    public CustomerDTO createCustomer(CreateCustomerRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        if (storeId == null) storeId = 1L;

        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            Customer existing = customerRepository.findByStoreIdAndPhone(storeId, request.getPhone());
            if (existing != null) {
                throw new BusinessException(4009, "Số điện thoại này đã tồn tại");
            }
        }

        // Khởi tạo Entity với các giá trị từ request
        Customer customer = Customer.builder()
                .storeId(storeId)
                .name(request.getFullName())
                .phone(request.getPhone())
                .email(request.getEmail())
                .address(request.getAddress())
                .taxCode(request.getTaxCode())
                .contactPerson(request.getContactPerson())
                .notes(request.getNotes())
                .type(request.getType() != null ? Customer.CustomerType.valueOf(request.getType().toUpperCase())
                        : Customer.CustomerType.RETAIL)
                .status(Customer.CustomerStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .gender(request.getGender())
                .dob(request.getDob())
                .groupId(request.getGroupId())
                // Lưu nợ đầu kỳ vào DB
                .totalDebt(request.getTotalDebt() != null ? request.getTotalDebt() : BigDecimal.ZERO)
                .totalPurchaseAmount(
                        request.getTotalPurchaseAmount() != null ? request.getTotalPurchaseAmount() : BigDecimal.ZERO)
                .totalOrders(request.getTotalOrders() != null ? request.getTotalOrders() : 0)
                .build();

        // Lưu và map trả về DTO ngay lập tức
        return mapToDTO(customerRepository.save(customer));
    }

    @Override
    @Transactional
    @com.bizflow.backend.core.annotation.AuditAction(action = "UPDATE_CUSTOMER", entityType = "CUSTOMER")
    public CustomerDTO updateCustomer(Long id, CreateCustomerRequest request) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy khách hàng"));

        customer.setName(request.getFullName());
        customer.setPhone(request.getPhone());
        customer.setEmail(request.getEmail());
        customer.setAddress(request.getAddress());
        customer.setTaxCode(request.getTaxCode());
        customer.setContactPerson(request.getContactPerson());
        customer.setNotes(request.getNotes());
        customer.setGender(request.getGender());
        customer.setDob(request.getDob());

        if (request.getGroupId() != null) {
            customer.setGroupId(request.getGroupId());
        }

        customer.setUpdatedAt(LocalDateTime.now());

        // Cập nhật các trường tài chính nếu có trong request
        if (request.getTotalDebt() != null) customer.setTotalDebt(request.getTotalDebt());
        if (request.getTotalPurchaseAmount() != null) customer.setTotalPurchaseAmount(request.getTotalPurchaseAmount());
        if (request.getTotalOrders() != null) customer.setTotalOrders(request.getTotalOrders());

        if (request.getType() != null) {
            try {
                customer.setType(Customer.CustomerType.valueOf(request.getType().toUpperCase()));
            } catch (IllegalArgumentException e) {
                customer.setType(Customer.CustomerType.RETAIL);
            }
        }

        return mapToDTO(customerRepository.save(customer));
    }

    @Override
    @Transactional
    @Caching(evict = {
            @CacheEvict(value = "customers", key = "#id"),
            @CacheEvict(value = "customers_page", allEntries = true)
    })
    public void deleteCustomer(Long id) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy khách hàng"));
        customer.setStatus(Customer.CustomerStatus.INACTIVE);
        customer.setUpdatedAt(LocalDateTime.now());
        customerRepository.save(customer);
    }

    @Override
    public Optional<Customer> getCustomerById(Long id) {
        return customerRepository.findById(id);
    }

    @Override
    public Optional<Customer> getCustomerByPhone(String phone) {
        Long storeId = UserContext.getCurrentStoreId();
        return Optional.ofNullable(customerRepository.findByStoreIdAndPhone(storeId != null ? storeId : 1L, phone));
    }

    @Override
    public Page<CustomerDTO> searchCustomers(String keyword, Long storeId, Pageable pageable) {
        return getCustomersByStore(storeId, keyword, pageable);
    }

    @Override
    public Page<CustomerDTO> getCustomersBySegment(String segment, Long storeId, Pageable pageable) {
        return Page.empty(pageable);
    }

    @Override
    public CustomerDTO updateSegment(Long id, String segment) {
        return null;
    }

    /**
     * Chuyển đổi từ Entity sang DTO và xử lý logic hiển thị công nợ
     */
    private CustomerDTO mapToDTO(Customer customer) {
        // 1. Lấy nợ từ bảng chi tiết (debts) - nợ phát sinh từ hóa đơn
        BigDecimal dynamicDebt = debtRepository.sumUnpaidByCustomerId(customer.getId());

        // 2. Logic xử lý:
        // Nếu bảng nợ chi tiết chưa có gì (null/0) thì lấy nợ tĩnh trong bảng Customer (nợ đầu kỳ).
        // Nếu bảng chi tiết có dữ liệu, ưu tiên lấy số liệu chi tiết để đảm bảo chính xác.
        BigDecimal displayDebt = (dynamicDebt == null || dynamicDebt.compareTo(BigDecimal.ZERO) == 0)
                ? customer.getTotalDebt()
                : dynamicDebt;

        return CustomerDTO.builder()
                .id(customer.getId())
                .name(customer.getName())
                .fullName(customer.getName())
                .phone(customer.getPhone())
                .email(customer.getEmail())
                .address(customer.getAddress())
                .taxCode(customer.getTaxCode())
                .contactPerson(customer.getContactPerson())
                .notes(customer.getNotes())
                .status(customer.getStatus() != null ? customer.getStatus().toString() : "ACTIVE")
                .type(customer.getType() != null ? customer.getType().toString() : "RETAIL")
                .totalDebt(displayDebt != null ? displayDebt : BigDecimal.ZERO)
                .totalPurchaseAmount(customer.getTotalPurchaseAmount() != null ? customer.getTotalPurchaseAmount() : BigDecimal.ZERO)
                .totalOrders(customer.getTotalOrders() != null ? customer.getTotalOrders() : 0)
                .storeId(customer.getStoreId())
                .gender(customer.getGender())
                .dob(customer.getDob())
                .groupId(customer.getGroupId())
                .createdAt(customer.getCreatedAt())
                .updatedAt(customer.getUpdatedAt())
                .build();
    }
}