package com.bizflow.backend.infrastructure.service;

import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.core.usecase.CustomerService;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.presentation.dto.request.CreateCustomerRequest;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import com.bizflow.backend.presentation.exception.BusinessException;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
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
                .name(request.getName())
                .phone(request.getPhone())
                .email(request.getEmail())
                .address(request.getAddress())
                .type(request.getType() != null ? Customer.CustomerType.valueOf(request.getType()) : Customer.CustomerType.RETAIL)
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

    @Override
    public Page<CustomerDTO> getCustomersByStore(Long storeId, Pageable pageable) {
        if (storeId == null) {
            return Page.empty(pageable);
        }
        return customerRepository.findByStoreId(storeId, pageable).map(this::mapToDTO);
    }

    @Override
    @Transactional
    public CustomerDTO updateCustomer(Long id, CreateCustomerRequest request) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));

        customer.setName(request.getName());
        customer.setPhone(request.getPhone());
        customer.setEmail(request.getEmail());
        customer.setAddress(request.getAddress());

        if (request.getType() != null) {
            customer.setType(Customer.CustomerType.valueOf(request.getType()));
        }

        customer.setTaxCode(request.getTaxCode());
        customer.setContactPerson(request.getContactPerson());
        customer.setNotes(request.getNotes());
        customer.setUpdatedAt(LocalDateTime.now());

        return mapToDTO(customerRepository.save(customer));
    }

    @Override
    @Transactional
    public void deleteCustomer(Long id) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
        customer.setStatus(Customer.CustomerStatus.INACTIVE);
        customerRepository.save(customer);
    }

    @Override
    public Optional<Customer> getCustomerById(Long id) {
        return customerRepository.findById(id);
    }

    // --- HÀM MAP DỮ LIỆU ĐÃ SỬA LỖI ---
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

                // --- ĐÃ SỬA TỪ .totalSpent() THÀNH .totalPurchaseAmount() ---
                .totalPurchaseAmount(BigDecimal.ZERO)
                .totalOrders(0)
                // -----------------------------------------------------------

                .storeId(customer.getStoreId())
                .createdAt(customer.getCreatedAt())
                .updatedAt(customer.getUpdatedAt())
                .build();
    }

    // Placeholder methods
    @Override public Optional<Customer> getCustomerByPhone(String phone) { return Optional.empty(); }
    @Override public Page<CustomerDTO> searchCustomers(String k, Long s, Pageable p) { return Page.empty(); }
    @Override public Page<CustomerDTO> getCustomersBySegment(String s, Long st, Pageable p) { return Page.empty(); }
    @Override public CustomerDTO updateSegment(Long id, String s) { return null; }
    @Override public Page<CustomerDTO> getAllActiveCustomers(Long s, Pageable p) { return getCustomersByStore(s, p); }
}