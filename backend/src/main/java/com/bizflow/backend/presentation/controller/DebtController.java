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

@RestController
@RequestMapping("/v1/debts")
@RequiredArgsConstructor
public class DebtController {

    private final DebtService debtService;

    /**
     * Lấy danh sách công nợ
     * GET /v1/debts?customerId=1
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<Debt>>> getDebts(
            @RequestParam(required = false) Long customerId,
            Pageable pageable) {
        
        Long storeId = UserContext.getCurrentStoreId();
        Page<Debt> debts;
        
        if (customerId != null) {
            debts = debtService.getDebtsByCustomer(customerId, pageable);
        } else {
            debts = debtService.getUnpaidDebts(storeId, pageable);
        }
        
        return ResponseEntity.ok(ApiResponse.success(debts, "Lấy danh sách công nợ thành công"));
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
