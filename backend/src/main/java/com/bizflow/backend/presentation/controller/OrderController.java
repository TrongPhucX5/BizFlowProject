package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.OrderService;
import com.bizflow.backend.presentation.dto.request.CreateOrderRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.OrderDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Page<OrderDTO>>> getAllOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Long customerId,
            Pageable pageable) {
        
        Page<OrderDTO> orders = orderService.getAllOrders(status, startDate, endDate, customerId, pageable);
        return ResponseEntity.ok(ApiResponse.success(orders, "Orders retrieved successfully"));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> getOrderById(@PathVariable Long id) {
        OrderDTO order = orderService.getOrderById(id);
        return ResponseEntity.ok(ApiResponse.success(order, "Order retrieved successfully"));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        OrderDTO order = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(order, "Order created successfully"));
    }

    // @PutMapping("/{id}")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    // public ResponseEntity<ApiResponse<OrderDTO>> updateOrder(
    //         @PathVariable Long id,
    //         @Valid @RequestBody CreateOrderRequest request) {
        
    //     OrderDTO order = orderService.updateOrder(id, request);
    //     return ResponseEntity.ok(ApiResponse.success(order, "Order updated successfully"));
    // }

    // @DeleteMapping("/{id}")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    // public ResponseEntity<ApiResponse<Void>> deleteOrder(@PathVariable Long id) {
    //     orderService.deleteOrder(id);
    //     return ResponseEntity.ok(ApiResponse.success(null, "Order deleted successfully"));
    // }

    // @PatchMapping("/{id}/status")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    // public ResponseEntity<ApiResponse<OrderDTO>> updateOrderStatus(
    //         @PathVariable Long id,
    //         @RequestParam String status) {
        
    //     OrderDTO order = orderService.updateOrderStatus(id, status);
    //     return ResponseEntity.ok(ApiResponse.success(order, "Order status updated successfully"));
    // }

    // @PostMapping("/{id}/pay")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    // public ResponseEntity<ApiResponse<OrderDTO>> makePayment(
    //         @PathVariable Long id,
    //         @RequestBody PaymentRequest paymentRequest) {
        
    //     OrderDTO order = orderService.makePayment(id, paymentRequest);
    //     return ResponseEntity.ok(ApiResponse.success(order, "Payment processed successfully"));
    // }

    // @GetMapping("/today")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    // public ResponseEntity<ApiResponse<Page<OrderDTO>>> getTodayOrders(Pageable pageable) {
    //     Page<OrderDTO> orders = orderService.getTodayOrders(pageable);
    //     return ResponseEntity.ok(ApiResponse.success(orders, "Today's orders retrieved successfully"));
    // }
}

// PaymentRequest DTO
record PaymentRequest(
    Double amount,
    String paymentMethod,
    String transactionId,
    String note
) {}
