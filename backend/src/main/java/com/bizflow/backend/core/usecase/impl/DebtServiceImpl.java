package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Debt;
import com.bizflow.backend.core.usecase.DebtService;
import com.bizflow.backend.infrastructure.persistence.repository.DebtRepository;
import com.bizflow.backend.presentation.dto.request.PayDebtRequest;
import com.bizflow.backend.presentation.exception.BusinessException;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DebtServiceImpl implements DebtService {

    private final DebtRepository debtRepository;

    @Override
    public Optional<Debt> getDebtById(Long id) {
        Long storeId = UserContext.getCurrentStoreId();
        return debtRepository.findById(id)
                .filter(d -> d.getStoreId().equals(storeId));
    }

    @Override
    public Page<Debt> getDebtsByCustomer(Long customerId, Pageable pageable) {
        // TODO: Verify customer belongs to store
        return debtRepository.findByCustomerId(customerId, pageable);
    }

    @Override
    public Page<Debt> getUnpaidDebts(Long storeId, Pageable pageable) {
        if (!storeId.equals(UserContext.getCurrentStoreId())) {
            throw new BusinessException(4003, "Access denied");
        }
        return debtRepository.findByStoreIdAndStatusIn(storeId, 
                Arrays.asList(Debt.DebtStatus.UNPAID, Debt.DebtStatus.PAID_PARTIAL), 
                pageable);
    }

    @Override
    public Page<Debt> getOverdueDebts(Long storeId, Pageable pageable) {
        // TODO: Implement overdue logic
        return Page.empty();
    }

    @Override
    public Map<String, List<Debt>> getDebtAging(Long storeId) {
        // TODO: Implement aging logic
        return Collections.emptyMap();
    }

    @Override
    public BigDecimal getTotalDebt(Long customerId) {
        // TODO: Implement sum query
        return BigDecimal.ZERO;
    }

    @Override
    public BigDecimal getTotalStoreDebt(Long storeId) {
        // TODO: Implement sum query
        return BigDecimal.ZERO;
    }

    @Override
    @Transactional
    public Debt payDebt(Long debtId, PayDebtRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        
        Debt debt = debtRepository.findById(debtId)
                .orElseThrow(() -> new ResourceNotFoundException("Debt record not found: " + debtId));

        if (!debt.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Debt record does not belong to your store");
        }

        if (request.getAmount().compareTo(debt.getUnpaidAmount()) > 0) {
            throw new BusinessException(4008, "Payment amount exceeds unpaid debt amount");
        }

        // Update amounts
        debt.setPaidAmount(debt.getPaidAmount().add(request.getAmount()));
        debt.setUnpaidAmount(debt.getUnpaidAmount().subtract(request.getAmount()));

        // Update status
        if (debt.getUnpaidAmount().compareTo(BigDecimal.ZERO) == 0) {
            debt.setStatus(Debt.DebtStatus.PAID);
        } else {
            debt.setStatus(Debt.DebtStatus.PAID_PARTIAL); // Fixed: PARTIAL -> PAID_PARTIAL
        }

        // TODO: Create Payment record history here

        return debtRepository.save(debt);
    }

    @Override
    public Page<Debt> searchDebts(String keyword, Long storeId, Pageable pageable) {
        // TODO: Implement search
        return getUnpaidDebts(storeId, pageable);
    }
}
