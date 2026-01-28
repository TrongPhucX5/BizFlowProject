package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Debt;
import com.bizflow.backend.core.domain.Payment;
import com.bizflow.backend.core.domain.Customer;
import com.bizflow.backend.infrastructure.persistence.repository.PaymentRepository;
import com.bizflow.backend.infrastructure.persistence.repository.DebtRepository;
import com.bizflow.backend.infrastructure.persistence.repository.CustomerRepository;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * PaymentController: API Thu tiền nhanh
 * Endpoint: /v1/payments
 */
@RestController
@RequestMapping("/v1/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentRepository paymentRepository;
    private final DebtRepository debtRepository;
    private final CustomerRepository customerRepository;

    /**
     * POST /v1/payments - Tạo thanh toán mới (Thu tiền)
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createPayment(
            @Valid @RequestBody CreatePaymentRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        String createdBy = UserContext.getCurrentUsername();

        // Validate customer exists
        Optional<Customer> customerOpt = customerRepository.findById(request.getCustomerId());
        if (customerOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(4001, "Khách hàng không tồn tại"));
        }

        // Find or create debt for this customer
        Debt debt = debtRepository.findByCustomerIdAndStoreIdAndStatusNot(
                request.getCustomerId(), storeId, Debt.DebtStatus.PAID).stream().findFirst().orElseGet(() -> {
                    // Create new debt record if none exists
                    Debt newDebt = Debt.builder()
                            .customerId(request.getCustomerId())
                            .storeId(storeId)
                            .originalAmount(BigDecimal.ZERO)
                            .paidAmount(BigDecimal.ZERO)
                            .unpaidAmount(BigDecimal.ZERO)
                            .status(Debt.DebtStatus.PAID)
                            .build();
                    return debtRepository.save(newDebt);
                });

        // Create payment record
        Payment payment = Payment.builder()
                .storeId(storeId)
                .debtId(debt.getId())
                .customerId(request.getCustomerId())
                .amount(BigDecimal.valueOf(request.getAmount()))
                .paymentMethod(Payment.PaymentMethod.valueOf(request.getPaymentMethod()))
                .notes(request.getNote())
                .createdBy(createdBy)
                .build();

        Payment savedPayment = paymentRepository.save(payment);

        // Update debt unpaid amount if applicable
        if (debt.getUnpaidAmount().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal amountPaid = BigDecimal.valueOf(request.getAmount());
            BigDecimal newUnpaid = debt.getUnpaidAmount().subtract(amountPaid);

            // Update paid amount as well
            BigDecimal currentPaid = debt.getPaidAmount() != null ? debt.getPaidAmount() : BigDecimal.ZERO;
            debt.setPaidAmount(currentPaid.add(amountPaid));

            if (newUnpaid.compareTo(BigDecimal.ZERO) <= 0) {
                debt.setUnpaidAmount(BigDecimal.ZERO);
                debt.setStatus(Debt.DebtStatus.PAID);
            } else {
                debt.setUnpaidAmount(newUnpaid);
                // Status could be PAID_PARTIAL if it was UNPAID, but here we just keep UNPAID
                // or existing status unless logic requires partial
                if (debt.getStatus() == Debt.DebtStatus.UNPAID) {
                    debt.setStatus(Debt.DebtStatus.PAID_PARTIAL);
                }
            }
            debtRepository.save(debt);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("paymentId", savedPayment.getId());
        response.put("amount", savedPayment.getAmount());
        response.put("customerName", customerOpt.get().getName());
        response.put("createdAt", savedPayment.getCreatedAt());

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Thu tiền thành công"));
    }

    /**
     * GET /v1/payments - Lấy danh sách thanh toán
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<Payment>>> getPayments(
            @RequestParam(required = false) Long customerId,
            Pageable pageable) {

        Page<Payment> payments;
        if (customerId != null) {
            payments = paymentRepository.findByCustomerId(customerId, pageable);
        } else {
            payments = paymentRepository.findAll(pageable);
        }

        return ResponseEntity.ok(ApiResponse.success(payments, "Lấy danh sách thanh toán thành công"));
    }
}

@Data
class CreatePaymentRequest {
    private Long customerId;
    private Double amount;
    private String paymentMethod = "CASH";
    private String note;
}
