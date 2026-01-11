package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Debt;
import com.bizflow.backend.presentation.dto.request.PayDebtRequest;
import com.bizflow.backend.presentation.dto.response.OrderDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

/**
 * DebtService: Customer receivables management
 * 
 * RESPONSIBILITIES:
 * 1. Track unpaid order amounts
 * 2. Calculate debt aging
 * 3. Mark debts as paid
 * 4. Generate debt reports
 * 
 * PATTERN:
 * - Validate input → Check business rules → Build entity → Persist → Return DTO
 * 
 * SECURITY:
 * - All operations enforce store_id isolation (UserContext)
 * - Only OWNER/ACCOUNTANT can manage debts
 * - Debt records are immutable (created via orders)
 */
public interface DebtService {

    /**
     * Get debt by ID (with store filter)
     * 
     * @param id Debt ID
     * @return Debt info or empty
     */
    Optional<Debt> getDebtById(Long id);

    /**
     * List debts by customer (with store filter)
     * 
     * @param customerId Customer ID
     * @param pageable Pagination info
     * @return Page of debts
     */
    Page<Debt> getDebtsByCustomer(Long customerId, Pageable pageable);

    /**
     * List unpaid debts for store (with store filter)
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of unpaid debts
     */
    Page<Debt> getUnpaidDebts(Long storeId, Pageable pageable);

    /**
     * List overdue debts (due_date < today)
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of overdue debts
     */
    Page<Debt> getOverdueDebts(Long storeId, Pageable pageable);

    /**
     * Get debt aging report (0-30, 30-60, 60-90, 90+ days)
     * Groups debts by aging bucket
     * 
     * @param storeId Store ID
     * @return Aging analysis by bucket
     */
    java.util.Map<String, java.util.List<Debt>> getDebtAging(Long storeId);

    /**
     * Calculate total outstanding debt
     * 
     * @param customerId Customer ID
     * @return Total outstanding amount
     */
    BigDecimal getTotalDebt(Long customerId);

    /**
     * Calculate total outstanding debt for store
     * 
     * @param storeId Store ID
     * @return Total outstanding amount
     */
    BigDecimal getTotalStoreDebt(Long storeId);

    /**
     * Pay debt (Trả nợ)
     * 
     * @param debtId Debt ID
     * @param request Payment details
     * @return Updated debt
     */
    Debt payDebt(Long debtId, PayDebtRequest request);

    /**
     * Search debts by customer name/phone
     * 
     * @param keyword Search keyword
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of matching debts
     */
    Page<Debt> searchDebts(String keyword, Long storeId, Pageable pageable);
}
