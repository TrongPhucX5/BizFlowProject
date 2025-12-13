package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Payment;
import com.bizflow.backend.presentation.dto.response.OrderDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Map;

/**
 * PaymentService: Payment processing and reconciliation
 * 
 * RESPONSIBILITIES:
 * 1. Record customer payments
 * 2. Match payments to debts/invoices
 * 3. Track payment methods
 * 4. Generate payment reconciliation reports
 * 
 * PATTERN:
 * - Validate input → Check business rules → Build entity → Persist → Return DTO
 * 
 * SECURITY:
 * - All operations enforce store_id isolation (UserContext)
 * - Only OWNER/ACCOUNTANT/CASHIER can record payments
 * - Payment records are immutable (no edit after creation)
 */
public interface PaymentService {

    /**
     * Record new payment
     * 
     * @param payment Payment details
     * @return Created payment
     * @throws BusinessException if validation fails
     */
    Payment recordPayment(Payment payment);

    /**
     * Get payment by ID (with store filter)
     * 
     * @param id Payment ID
     * @return Payment or empty
     */
    Optional<Payment> getPaymentById(Long id);

    /**
     * List payments for customer (with store filter)
     * 
     * @param customerId Customer ID
     * @param pageable Pagination info
     * @return Page of payments
     */
    Page<OrderDTO> getPaymentsByCustomer(Long customerId, Pageable pageable);

    /**
     * List payments for store
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of payments
     */
    Page<OrderDTO> getPaymentsByStore(Long storeId, Pageable pageable);

    /**
     * List payments by date range (with store filter)
     * 
     * @param storeId Store ID
     * @param startDate Start date
     * @param endDate End date
     * @param pageable Pagination info
     * @return Page of payments in date range
     */
    Page<OrderDTO> getPaymentsByDateRange(Long storeId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    /**
     * List payments by method (with store filter)
     * 
     * @param storeId Store ID
     * @param method Payment method (CASH, CHECK, BANK_TRANSFER, etc)
     * @param pageable Pagination info
     * @return Page of payments
     */
    Page<OrderDTO> getPaymentsByMethod(Long storeId, String method, Pageable pageable);

    /**
     * Calculate total payments for customer
     * 
     * @param customerId Customer ID
     * @return Total paid amount
     */
    Double getTotalPayments(Long customerId);

    /**
     * Calculate total payments for store
     * 
     * @param storeId Store ID
     * @return Total paid amount
     */
    Double getTotalStorePayments(Long storeId);

    /**
     * Search payments by reference/customer
     * 
     * @param keyword Search keyword
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of matching payments
     */
    Page<OrderDTO> searchPayments(String keyword, Long storeId, Pageable pageable);

    /**
     * Get payment reconciliation summary (by method)
     * 
     * @param storeId Store ID
     * @param startDate Start date
     * @param endDate End date
     * @return Reconciliation summary grouped by payment method
     */
    java.util.Map<String, Double> getPaymentReconciliation(Long storeId, LocalDateTime startDate, LocalDateTime endDate);
}
