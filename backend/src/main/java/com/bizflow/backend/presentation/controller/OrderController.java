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

    /**
     * Lấy danh sách đơn hàng có phân trang và lọc
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Page<OrderDTO>>> getAllOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Long customerId,
            Pageable pageable) {

        Page<OrderDTO> orders = orderService.getAllOrders(status, startDate, endDate, customerId, pageable);
        return ResponseEntity.ok(ApiResponse.success(orders, "Lấy danh sách đơn hàng thành công"));
    }

    /**
     * Lấy chi tiết một đơn hàng theo ID
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> getOrderById(@PathVariable Long id) {
        OrderDTO order = orderService.getOrderById(id);
        return ResponseEntity.ok(ApiResponse.success(order, "Lấy thông tin đơn hàng thành công"));
    }

    /**
     * Tạo mới một đơn hàng
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        OrderDTO order = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(order, "Tạo đơn hàng thành công"));
    }

    /**
     * Chỉnh sửa đơn hàng (Hoàn kho cũ, trừ kho mới)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<OrderDTO>> updateOrder(
            @PathVariable Long id,
            @Valid @RequestBody CreateOrderRequest request) {

        OrderDTO order = orderService.updateOrder(id, request);
        return ResponseEntity.ok(ApiResponse.success(order, "Cập nhật đơn hàng thành công"));
    }

    /**
     * Hủy đơn hàng và hoàn trả tồn kho
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteOrder(@PathVariable Long id) {
        orderService.cancelOrder(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Hủy đơn hàng thành công"));
    }
}