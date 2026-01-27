package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.core.usecase.CustomerService;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.presentation.dto.request.CreateCustomerRequest;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import com.bizflow.backend.presentation.exception.BusinessException;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
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

    @Override
    @Transactional
    @CacheEvict(value = "customers_page", allEntries = true)
    public CustomerDTO createCustomer(CreateCustomerRequest request) {
        Long storeId = 1L;

        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            Customer existing = customerRepository.findByStoreIdAndPhone(storeId, request.getPhone());
            if (existing != null) {
                throw new BusinessException(4009, "Số điện thoại này đã tồn tại");
            }
        }

        Customer customer = Customer.builder()
                .storeId(storeId)
                .name(request.getFullName())
                .phone(request.getPhone())
                .email(request.getEmail())
                .address(request.getAddress())
                .type(request.getType() != null ? Customer.CustomerType.valueOf(request.getType().toUpperCase())
                        : Customer.CustomerType.RETAIL)
                .taxCode(request.getTaxCode())
                .contactPerson(request.getContactPerson())
                .status(Customer.CustomerStatus.ACTIVE)
                .notes(request.getNotes())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .totalDebt(BigDecimal.ZERO)
                .build();

        return mapToDTO(customerRepository.save(customer));
    }

    // --- ĐÃ SỬA: Thêm tham số String search để khớp với Interface ---
    @Override
    public Page<CustomerDTO> getCustomersByStore(Long storeId, String search, Pageable pageable) {
        if (storeId == null) return Page.empty(pageable);

        if (search != null && !search.trim().isEmpty()) {
            return customerRepository.findByStoreIdAndStatusWithSearch(
                            storeId, Customer.CustomerStatus.ACTIVE, search, pageable)
                    .map(this::mapToDTO);
        }
        return getAllActiveCustomers(storeId, pageable);
    }

    // Thêm hàm bổ trợ nếu interface yêu cầu 2 tham số ở chỗ khác
    public Page<CustomerDTO> getCustomersByStore(Long storeId, Pageable pageable) {
        return getCustomersByStore(storeId, null, pageable);
    }

    @Override
    @Transactional
    public CustomerDTO updateCustomer(Long id, CreateCustomerRequest request) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));

        customer.setName(request.getFullName());
        customer.setPhone(request.getPhone());
        customer.setEmail(request.getEmail());
        customer.setAddress(request.getAddress());

        if (request.getType() != null) {
            customer.setType(Customer.CustomerType.valueOf(request.getType().toUpperCase()));
        }

        customer.setTaxCode(request.getTaxCode());
        customer.setContactPerson(request.getContactPerson());
        customer.setNotes(request.getNotes());
        customer.setUpdatedAt(LocalDateTime.now());

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
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
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
        return Optional.ofNullable(customerRepository.findByStoreIdAndPhone(1L, phone));
    }

    @Override
    public Page<CustomerDTO> searchCustomers(String keyword, Long storeId, Pageable pageable) {
        return getCustomersByStore(storeId, keyword, pageable);
    }

    @Override
    public Page<CustomerDTO> getAllActiveCustomers(Long storeId, Pageable pageable) {
        return customerRepository.findByStoreIdAndStatus(
                        storeId, Customer.CustomerStatus.ACTIVE, pageable)
                .map(this::mapToDTO);
    }

    @Override
    public Page<CustomerDTO> getCustomersBySegment(String segment, Long storeId, Pageable pageable) {
        return Page.empty(pageable);
    }

    @Override
    public CustomerDTO updateSegment(Long id, String segment) {
        return null;
    }

    private CustomerDTO mapToDTO(Customer customer) {
        return CustomerDTO.builder()
                .id(customer.getId())
                .fullName(customer.getName())
                .phone(customer.getPhone())
                .email(customer.getEmail())
                .address(customer.getAddress())
                .type(customer.getType() != null ? customer.getType().toString() : "RETAIL")
                .status(customer.getStatus() != null ? customer.getStatus().toString() : "ACTIVE")
                .taxCode(customer.getTaxCode())
                .contactPerson(customer.getContactPerson())
                .notes(customer.getNotes())
                .totalDebt(customer.getTotalDebt() != null ? customer.getTotalDebt() : BigDecimal.ZERO)
                .totalPurchaseAmount(BigDecimal.ZERO)
                .totalOrders(0)
                .storeId(customer.getStoreId())
                .createdAt(customer.getCreatedAt())
                .updatedAt(customer.getUpdatedAt())
                .build();
    }
}