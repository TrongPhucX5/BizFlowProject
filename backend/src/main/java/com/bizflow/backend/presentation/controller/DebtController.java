package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Debt;
import com.bizflow.backend.core.usecase.DebtService;
import com.bizflow.backend.presentation.dto.request.PayDebtRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.presentation.dto.response.DebtResponse;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.function.Function;

@RestController
@RequestMapping("/v1/debts")
@RequiredArgsConstructor
public class DebtController {

    private final DebtService debtService;
    private final CustomerRepository customerRepository;

    /**
     * Lấy danh sách công nợ
     * GET /v1/debts?customerId=1
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<DebtResponse>>> getDebts(
            @RequestParam(required = false) Long customerId,
            Pageable pageable) {
        
        Long storeId = UserContext.getCurrentStoreId();
        Page<Debt> debts;
        
        if (customerId != null) {
            debts = debtService.getDebtsByCustomer(customerId, pageable);
        } else {
            debts = debtService.getUnpaidDebts(storeId, pageable);
        }

        // Fetch Customer Info
        Set<Long> customerIds = debts.getContent().stream()
                .map(Debt::getCustomerId)
                .collect(Collectors.toSet());

        Map<Long, Customer> customerMap = customerRepository.findAllById(customerIds).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));

        // Map to DTO
        Page<DebtResponse> response = debts.map(debt -> {
            Customer customer = customerMap.get(debt.getCustomerId());
            return DebtResponse.from(debt, 
                    customer != null ? customer.getName() : "Unknown", 
                    customer != null ? customer.getPhone() : "");
        });
        
        return ResponseEntity.ok(ApiResponse.success(response, "Lấy danh sách công nợ thành công"));
    }

    /**
     * Thanh toán công nợ
     * POST /v1/debts/{id}/pay
     */
    @PostMapping("/{id}/pay")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Debt>> payDebt(
            @PathVariable Long id,
            @Valid @RequestBody PayDebtRequest request) {
        
        Debt updatedDebt = debtService.payDebt(id, request);
        return ResponseEntity.ok(ApiResponse.success(updatedDebt, "Thanh toán công nợ thành công"));
    }
}
