package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.presentation.dto.request.CreateCustomerRequest;
import com.bizflow.backend.presentation.dto.response.CustomerDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

/**
 * CustomerService: Customer management
 * 
 * RESPONSIBILITIES:
 * 1. CRUD operations on customers
 * 2. Search and filter by store
 * 3. Customer segment tracking
 * 4. Contact history
 * 
 * PATTERN:
 * - Validate input → Check business rules → Build entity → Persist → Return DTO
 * 
 * SECURITY:
 * - All operations enforce store_id isolation (UserContext)
 * - Only OWNER/EMPLOYEE can view/modify customers
 */
public interface CustomerService {

    /**
     * Create new customer
     * 
     * @param request Customer details
     * @return Created customer DTO
     * @throws BusinessException if validation fails
     */
    CustomerDTO createCustomer(CreateCustomerRequest request);

    /**
     * Get customer by ID (with store filter)
     * 
     * @param id Customer ID
     * @return Customer DTO or empty
     */
    Optional<Customer> getCustomerById(Long id);

    /**
     * Get customer by phone number (with store filter)
     * 
     * @param phone Phone number
     * @return Customer DTO or empty
     */
    Optional<Customer> getCustomerByPhone(String phone);

    /**
     * List customers by store (paginated)
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of customers
     */
    Page<CustomerDTO> getCustomersByStore(Long storeId, Pageable pageable);

    /**
     * Search customers by name/phone (with store filter)
     * 
     * @param keyword Search keyword
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of matching customers
     */
    Page<CustomerDTO> searchCustomers(String keyword, Long storeId, Pageable pageable);

    /**
     * Get customers by segment (with store filter)
     * 
     * @param segment Customer segment
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of customers
     */
    Page<CustomerDTO> getCustomersBySegment(String segment, Long storeId, Pageable pageable);

    /**
     * Update customer details
     * 
     * @param id Customer ID
     * @param request Update details
     * @return Updated customer DTO
     * @throws ResourceNotFoundException if customer not found
     */
    CustomerDTO updateCustomer(Long id, CreateCustomerRequest request);

    /**
     * Update customer segment
     * 
     * @param id Customer ID
     * @param segment New segment
     * @return Updated customer DTO
     */
    CustomerDTO updateSegment(Long id, String segment);

    /**
     * Delete customer (soft delete)
     * 
     * @param id Customer ID
     * @throws ResourceNotFoundException if customer not found
     */
    void deleteCustomer(Long id);

    /**
     * Get all active customers for store
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of active customers
     */
    Page<CustomerDTO> getAllActiveCustomers(Long storeId, Pageable pageable);
}
